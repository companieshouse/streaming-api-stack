
locals {
  cache_port = 18582
  cache_name_prefix = "${var.environment}-streaming-api-cache"
}

resource "aws_security_group" "streaming-api-cache-sg" {
  description = "Security group for streaming-api-cache"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = local.cache_port
    to_port     = local.cache_port
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
    Name        = "streaming-api-cache-internal-service-sg"
  }
}

resource "aws_ecs_service" "streaming-api-cache-ecs-service" {
  name            = local.cache_name_prefix
  cluster         = var.ecs_cluster_id
  task_definition = aws_ecs_task_definition.streaming-api-cache-task-definition.arn
  desired_count   = var.streaming_api_cache_task_desired_count

  network_configuration {
    subnets         = flatten([split(",", var.application_ids)])
    security_groups = [aws_security_group.streaming-api-cache-sg.id]
  }
}

resource "aws_ecs_task_definition" "streaming-api-cache-task-definition" {
  family             = "${var.environment}-streaming-api-cache"
  execution_role_arn = var.task_execution_role_arn

  container_definitions = templatefile(
    "${path.module}/streaming-api-cache-task-definition.tmpl", {
    aws_region = var.aws_region
    docker_registry = var.docker_registry
    bind_address = local.cache_port
    log_level = var.log_level
    name_prefix = local.cache_name_prefix
    streaming_api_backend_url = var.cache_streaming_api_backend_url
    redis_url = var.cache_redis_url
    redis_pool_size = var.cache_redis_pool_size
    cache_expiry_seconds = var.cache_cache_expiry_seconds
    streaming_api_cache_version = var.streaming_api_cache_version
    stream_backend_filings_path = var.cache_stream_backend_filings_path
    stream_backend_companies_path = var.cache_stream_backend_companies_path
    stream_backend_insolvency_path = var.cache_stream_backend_insolvency_path
    stream_backend_charges_path = var.cache_stream_backend_charges_path
    stream_backend_officers_path = var.cache_stream_backend_officers_path
    stream_backend_pscs_path = var.cache_stream_backend_pscs_path
  })

  network_mode = "awsvpc"
}
