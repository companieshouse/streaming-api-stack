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

variable "streaming_api_backend_task_desired_count" {
  type        = number
  description = "Desired number of streaming api backend tasks"
  default = 1
}

variable "streaming_api_cache_task_desired_count" {
  type        = number
  description = "Desired number of streaming api cache tasks"
  default = 1
}

variable "streaming_api_frontend_task_desired_count" {
  type        = number
  description = "Desired number of streaming api frontend tasks"
  default = 1
}

# Certificates
variable "ssl_certificate_id" {
  type        = string
  description = "The ARN of the certificate for https access through the ALB."
}

# eric stream service config variables
variable "eric_cache_url" {
  type = string
}
variable "cache_max_connections" {
  type = string
  default = "10"
}
variable "cache_max_idle" {
  type = string
  default = "3"
}
variable "cache_idle_timeout" {
  type = string
  default = "240"
}
variable "cache_ttl" {
  type = string
  default = "600"
}
variable "flush_interval" {
  type = string
  default = "10"
}
variable "graceful_shutdown_period" {
  type = string
  default = "2"
}
variable "default_stream_limit" {
  type = string
  default = "2"
}
variable "stream_check_interval_seconds" {
  type = string
  default = "30"
}

# Backend configuration

variable "streaming_api_backend_version" {
  description = "The version of streaming API backend that will be deployed"
  type = string
}

variable "backend_kafka_broker_url" {
  description = "The URL of the Kafka broker that the backend will connect to"
  type = string
}

variable "backend_schema_registry_url" {
  description = "The URL of the schema registry instance schema definitions will be fetched from"
  type = string
}

# Cache configuration

variable "streaming_api_cache_version" {
  type = string
  description = "The build version of streaming API cache that will be deployed"
}

variable "cache_streaming_api_backend_url" {
  description = "The URL at which a streaming API backend instance is hosted"
  type = string
}

variable "cache_redis_url" {
  description = "The URL at which a Redis cluster is hosted"
  type = string
}

variable "cache_redis_pool_size" {
  description = "The maximum number of Redis connections held by a connection pool"
  type = number
  default = 10
}

variable "cache_cache_expiry_seconds" {
  description = "The elapsed time after which Redis cache entries will be removed"
  type = number
}

variable "cache_stream_backend_filings_path" {
  description = "The path at which new filings will be retrieved"
  type = string
  default = "/filings"
}

variable "cache_stream_backend_companies_path" {
  description = "The path at which new companies will be retrieved"
  type = string
  default = "/companies"
}

variable "cache_stream_backend_insolvency_path" {
  description = "The path at which new insolvencies will be retrieved"
  type = string
  default = "/company-insolvencies"
}

variable "cache_stream_backend_charges_path" {
  description = "The path at which new charges will be retrieved"
  type = string
  default = "/company-charges"
}

variable "cache_stream_backend_officers_path" {
  type = string
  description = "The path at which new officers will be retrieved"
  default = "/company-officers"
}

variable "cache_stream_backend_pscs_path" {
  type = string
  description = "The path at which new PSCs will be retrieved"
  default = "/persons-with-significant-control"
}

# Frontend configuration

variable "streaming_api_frontend_version" {
  type = string
  description = "The build version of streaming API frontend that will be deployed"
}

variable "frontend_cache_broker_url" {
  type = string
  description = "The location of a running streaming API cache broker service"
}

variable "frontend_heartbeat_interval" {
  type = string
  default = "30"
}

variable "frontend_request_timeout" {
  type = string
  default = "86400"
}
