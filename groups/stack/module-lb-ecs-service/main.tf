resource "aws_ecs_service" "streaming-api-ecs-service" {
  name            = "${var.environment}-${var.stack_name}"
  cluster         = var.ecs_cluster_id
  task_definition = aws_ecs_task_definition.streaming-api-task-definition.arn
  desired_count   = var.task_desired_count

  depends_on = [
    aws_lb_target_group.streaming-api-target_group,
    aws_lb.streaming-api-lb
  ]

  load_balancer {
    target_group_arn = aws_lb_target_group.streaming-api-target_group.arn
    container_port   = var.container_port
    container_name   = "eric-stream"
  }
}

resource "aws_ecs_task_definition" "streaming-api-task-definition" {
  family             = "${var.environment}-${var.stack_name}"
  execution_role_arn = var.task_execution_role_arn

  container_definitions = templatefile(
    "./task-definition.tmpl", var.template_vars
  )
  network_mode = "host"
}

resource "aws_lb_target_group" "streaming-api-target_group" {
  name     = "${var.environment}-${var.stack_name}"
  port     = var.container_port
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    healthy_threshold   = "5"
    unhealthy_threshold = "2"
    interval            = "30"
    matcher             = "200"
    path                = "/healthcheck"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = "5"
  }
}

resource "aws_lb" "streaming-api-lb" {
  name            = "${var.stack_name}-${var.environment}-lb"
  security_groups = var.security_groups
  subnets         = flatten([split(",", var.application_ids)])
  internal        = true
}

resource "aws_lb_listener" "streaming-api-lb-listener" {
  load_balancer_arn = aws_lb.streaming-api-lb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.ssl_certificate_id

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.streaming-api-target_group.arn
  }
}

resource "aws_route53_record" "streaming-api-r53-record" {
  count   = "${var.zone_id == "" ? 0 : 1}" # zone_id defaults to empty string giving count = 0 i.e. not route 53 record

  zone_id = var.zone_id
  name    = "stream-ecs${var.external_top_level_domain}"
  type    = "A"
  alias {
    name                   = aws_lb.streaming-api-lb.dns_name
    zone_id                = aws_lb.streaming-api-lb.zone_id
    evaluate_target_health = false
  }
}
