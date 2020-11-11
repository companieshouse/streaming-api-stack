resource "aws_ecs_service" "streaming-api-ecs-service" {
  name            = "${var.environment}-${var.stack_name}"
  cluster         = var.ecs_cluster_id
  task_definition = aws_ecs_task_definition.streaming-api-task-definition.arn
  desired_count   = var.task_desired_count

  network_configuration {
    subnets         = flatten([split(",", var.application_ids)])
    security_groups = var.security_groups
  }
}

resource "aws_ecs_task_definition" "streaming-api-task-definition" {
  family             = "${var.environment}-${var.stack_name}"
  execution_role_arn = var.task_execution_role_arn

  container_definitions = templatefile(
    "./task-definition.tmpl", var.template_vars
  )
  
  network_mode = "awsvpc"
}
