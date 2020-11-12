
locals {
  eric_stream_port   = "10000"
  frontend_port = "18583"
  frontend_name_prefix = "${var.environment}-streaming-api-frontend"
}

resource "aws_security_group" "streaming-api-frontend-sg" {
  description = "Security group for streaming-api-frontend"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = var.web_access_cidrs
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.web_access_cidrs
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Environment = var.environment
    Name        = "${local.frontend_name_prefix}-internal-service-sg"
  }
}

resource "aws_ecs_service" "streaming-api-frontend-ecs-service" {
  name            = local.frontend_name_prefix
  cluster         = var.ecs_cluster_id
  task_definition = aws_ecs_task_definition.streaming-api-frontend-task-definition.arn
  desired_count   = var.streaming_api_frontend_task_desired_count

  depends_on = [
    aws_lb_target_group.streaming-api-frontend-target_group,
    aws_lb.streaming-api-frontend-lb
  ]

  load_balancer {
    target_group_arn = aws_lb_target_group.streaming-api-frontend-target_group.arn
    container_port   = local.eric_stream_port
    container_name   = "eric-stream"
  }
}

resource "aws_ecs_task_definition" "streaming-api-frontend-task-definition" {
  family             = local.frontend_name_prefix
  execution_role_arn = var.task_execution_role_arn

  container_definitions = templatefile(
    "${path.module}/streaming-api-frontend-task-definition.tmpl", {
    aws_region                     = var.aws_region
    name_prefix                    = local.frontend_name_prefix
    docker_registry                = var.docker_registry
    external_top_level_domain      = var.external_top_level_domain
    docker_registry                = var.docker_registry
    log_level                      = var.log_level
    eric_stream_version            = var.eric_stream_version
    eric_stream_port               = local.eric_stream_port
    streaming_api_frontend_version = var.streaming_api_frontend_version
    cache_url                      = var.eric_cache_url
    cache_max_connections          = var.cache_max_connections
    cache_max_idle                 = var.cache_max_idle
    cache_idle_timeout             = var.cache_idle_timeout
    cache_ttl                      = var.cache_ttl
    flush_interval                 = var.flush_interval
    graceful_shutdown_period       = var.graceful_shutdown_period
    default_stream_limit           = var.default_stream_limit
    stream_check_interval_seconds  = var.stream_check_interval_seconds
    bind_address                   = local.frontend_port
    cache_broker_url               = var.frontend_cache_broker_url
    heartbeat_interval             = var.frontend_heartbeat_interval
    request_timeout                = var.frontend_request_timeout
  })
  network_mode = "host"
}

resource "aws_lb_target_group" "streaming-api-frontend-target_group" {
  name     = "${var.environment}-streaming-api-frontend"
  port     = local.eric_stream_port
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

resource "aws_lb" "streaming-api-frontend-lb" {
  name            = "streaming-api-frontend-${var.environment}-lb"
  security_groups = [aws_security_group.streaming-api-frontend-sg.id]
  subnets         = flatten([split(",", var.application_ids)])
  internal        = true
}

resource "aws_lb_listener" "streaming-api-frontend-lb-listener" {
  load_balancer_arn = aws_lb.streaming-api-frontend-lb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.ssl_certificate_id

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.streaming-api-frontend-target_group.arn
  }
}

resource "aws_route53_record" "streaming-api-frontend-r53-record" {
  count   = "${var.zone_id == "" ? 0 : 1}" # zone_id defaults to empty string giving count = 0 i.e. not route 53 record

  zone_id = var.zone_id
  name    = "stream-ecs${var.external_top_level_domain}" #TODO remove "-ecs"
  type    = "A"
  alias {
    name                   = aws_lb.streaming-api-frontend-lb.dns_name
    zone_id                = aws_lb.streaming-api-frontend-lb.zone_id
    evaluate_target_health = false
  }
}
