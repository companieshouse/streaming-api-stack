locals {
  backend_port = 18581
  backend_name_prefix = "${var.environment}-streaming-api-frontend"
}

resource "aws_security_group" "streaming-api-backend-sg" {
  description = "Security group for streaming-api-backend"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = local.backend_port
    to_port     = local.backend_port
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
    Name        = "streaming-api-backend-internal-service-sg"
  }
}

resource "aws_ecs_service" "streaming-api-backend-ecs-service" {
  name            = local.backend_name_prefix
  cluster         = var.ecs_cluster_id
  task_definition = aws_ecs_task_definition.streaming-api-backend-task-definition.arn
  desired_count   = var.streaming_api_backend_task_desired_count

  network_configuration {
    subnets         = flatten([split(",", var.application_ids)])
    security_groups = [aws_security_group.streaming-api-backend-sg.id]
  }
}

resource "aws_ecs_task_definition" "streaming-api-backend-task-definition" {
  family             = "${var.environment}-streaming-api-backend"
  execution_role_arn = var.task_execution_role_arn

  container_definitions = templatefile(
"${path.module}/streaming-api-backend-task-definition.tmpl", {
    aws_region = var.aws_region
    docker_registry = var.docker_registry
    bind_address = local.backend_port
    log_level = var.log_level
    name_prefix = local.backend_name_prefix
    streaming_api_backend_version = var.streaming_api_backend_version
    schema_registry_url = var.backend_schema_registry_url
    kafka_broker_url = var.backend_kafka_broker_url
  })

  network_mode = "awsvpc"
}