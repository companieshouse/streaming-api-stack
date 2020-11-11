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

variable "container_port" {
  description = "The port which will be opened to inbound connections"
  type = number
  default = 10000
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

variable "vpc_id" {
  description = "The ID of the VPC for the target group and security group."
  type        = string
}

variable "security_groups" {
  description = "A list of security group IDs"
  type = list(string)
}

variable "application_ids" {
  description = "Subnet IDs of application subnets from aws-mm-networks remote state."
  type        = string
}

variable "ssl_certificate_id" {
  description = "The ARN of the certificate for https access through the ALB."
  type        = string
}

variable "zone_id" {
  description = "The ID of the hosted zone to contain the Route 53 record."
  type        = string
}

variable "external_top_level_domain" {
  description = "The type level of the DNS domain for external access."
  type        = string
}
