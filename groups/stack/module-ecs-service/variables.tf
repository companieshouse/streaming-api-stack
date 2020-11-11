variable "environment" {
  description = "The name of the environment the target service will be deployed to"
  type        = string
}

variable "stack_name" {
    description = "The name of the stack that will be deployed"
    type = string
}

variable "ecs_cluster_id" {
  description = "The name of the ECS cluster associated to the service"
  type = string
}

variable "task_desired_count" {
  description = "Number of task instances that will be run"
  type = number
}

variable "task_execution_role_arn" {
  description = "The ARN of the task execution role that the container can assume."
  type = string
}

variable "template_vars" {
  description = "Template variables that will be rendered in the container definitions file"
  type = map(string)
}

variable "application_ids" {
  description = "Subnet IDs of application subnets from aws-mm-networks remote state"
  type = string
}

variable "security_groups" {
  description = "Security groups associated with the service"
  type = list(string)
}