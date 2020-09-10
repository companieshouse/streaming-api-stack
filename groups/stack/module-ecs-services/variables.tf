# Environment
variable "environment" {
  type        = string
  description = "The environment name, defined in envrionments vars."
}
variable "aws_region" {
  type        = string
  description = "The AWS region for deployment."
}

# Networking
variable "application_ids" {
  type        = string
  description = "Subnet IDs of application subnets from aws-mm-networks remote state."
}
variable "web_access_cidrs" {
  type        = list(string)
  description = "Subnet CIDRs for web ingress rules in the security group."
}
variable "vpc_id" {
  type        = string
  description = "The ID of the VPC for the target group and security group."
}

# DNS
variable "zone_id" {
  type        = string
  description = "The ID of the hosted zone to contain the Route 53 record."
}
variable "external_top_level_domain" {
  type        = string
  description = "The type levelel of the DNS domain for external access."
}
variable "internal_top_level_domain" {
  type        = string
  description = "The type levelel of the DNS domain for internal access."
}

# ECS Service
variable "stack_name" {
  type        = string
  description = "The name of the Stack / ECS Cluster."
}
variable "name_prefix" {
  type        = string
  description = "The name prefix to be used for stack / environment name spacing."
}
variable "ecs_cluster_id" {
  type        = string
  description = "The ARN of the ECS cluster to deploy the service to."
}

# Docker Container
variable "docker_registry" {
  type        = string
  description = "The FQDN of the Docker registry."
}
variable "streaming_api_version" {
  type        = string
  description = "The version of the streaming api service/container to run."
}
variable "eric_stream_version" {
  type        = string
  description = "The version of the eric stream service/container to run."
}
variable "task_execution_role_arn" {
  type        = string
  description = "The ARN of the task execution role that the container can assume."
}
variable "log_level" {
  type        = string
  description = "The log level to be set in the environment variables for the container."
}

# Certificates
variable "ssl_certificate_id" {
  type        = string
  description = "The ARN of the certificate for https access through the ALB."
}

# eric stream service config variables
variable "cache_url" {
  type = string
}
variable "cache_max_connections" {
  type = string
}
variable "cache_max_idle" {
  type = string
}
variable "cache_idle_timeout" {
  type = string
}
variable "cache_ttl" {
  type = string
}
variable "flush_interval" {
  type = string
}
variable "graceful_shutdown_period" {
  type = string
}
variable "default_stream_limit" {
  type = string
}
variable "stream_check_interval_seconds" {
  type = string
}

# Streaming API service configs
variable "heartbeat_interval" {
  type = string
}
variable "request_timeout" {
  type = string
}
variable "schema_registry_url" {
  type = string
}
variable "kafka_streaming_broker_addr" {
  type = string
}

# # Secrets
# variable "secrets_arn_map" {
#   type = map(string)
#   description = "The ARNs for all secrets"
# }
