
locals {
  eric_stream_port   = "10000"
  streaming_api_port = "10001"
}

resource "aws_ecs_service" "streaming-api-ecs-service" {
  name            = "${var.environment}-streaming-api"
  cluster         = var.ecs_cluster_id
  task_definition = aws_ecs_task_definition.streaming-api-task-definition.arn
  desired_count   = 1

  depends_on = [
    aws_lb_target_group.streaming-api-target_group,
    aws_lb.streaming-api-lb
  ]

  load_balancer {
    target_group_arn = aws_lb_target_group.streaming-api-target_group.arn
    container_port   = local.eric_stream_port
    container_name   = "eric-stream"
  }
}

locals {
  definition = merge(
    {
      environment                     : var.environment
      name_prefix                     : var.name_prefix
      aws_region                      : var.aws_region
      external_top_level_domain       : var.external_top_level_domain
      log_level                       : var.log_level
      docker_registry                 : var.docker_registry
      eric_stream_version             : var.eric_stream_version
      eric_stream_port                : local.eric_stream_port
      streaming_api_version           : var.streaming_api_version
      streaming_api_port              : local.streaming_api_port
      cache_url                       : var.cache_url
      cache_max_connections           : var.cache_max_connections
      cache_max_idle                  : var.cache_max_idle
      cache_idle_timeout              : var.cache_idle_timeout
      cache_ttl                       : var.cache_ttl
      flush_interval                  : var.flush_interval
      graceful_shutdown_period        : var.graceful_shutdown_period
      default_stream_limit            : var.default_stream_limit
      stream_check_interval_seconds   : var.stream_check_interval_seconds
      heartbeat_interval              : var.heartbeat_interval
      request_timeout                 : var.request_timeout
      schema_registry_url             : var.schema_registry_url
      kafka_streaming_broker_addr     : var.kafka_streaming_broker_addr
    },
    {
      blah : "placeholder"
    }#var.secrets_arn_map
  )
}

resource "aws_ecs_task_definition" "streaming-api-task-definition" {
  family             = "${var.environment}-streaming-api"
  execution_role_arn = var.task_execution_role_arn

  container_definitions = templatefile(
    "${path.module}/streaming-api-task-definition.tmpl", local.definition
  )
  # network_mode = "awsvpc"
  network_mode = "host"
}

resource "aws_lb_target_group" "streaming-api-target_group" {
  name     = "${var.environment}-streaming-api"
  port     = local.eric_stream_port
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  # target_type = "ip"

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
  name            = "streaming-api-${var.environment}-lb"
  security_groups = [aws_security_group.internal-service-sg.id]
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
  name    = "stream-ecs${var.external_top_level_domain}" #TODO remove "-ecs"
  type    = "A"
  alias {
    name                   = aws_lb.streaming-api-lb.dns_name
    zone_id                = aws_lb.streaming-api-lb.zone_id
    evaluate_target_health = false
  }
}
