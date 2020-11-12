# Environment
variable "environment" {
  type        = string
  description = "The environment name, defined in envrionments vars."
}
variable "aws_region" {
  default     = "eu-west-2"
  type        = string
  description = "The AWS region for deployment."
}
variable "aws_profile" {
  default     = "development-eu-west-2"
  type        = string
  description = "The AWS profile to use for deployment."
}

# Terraform
variable "aws_bucket" {
  type        = string
  description = "The bucket used to store the current terraform state files"
}
variable "remote_state_bucket" {
  type        = string
  description = "Alternative bucket used to store the remote state files from ch-service-terraform"
}
variable "state_prefix" {
  type        = string
  description = "The bucket prefix used with the remote_state_bucket files."
}
variable "deploy_to" {
  type        = string
  description = "Bucket namespace used with remote_state_bucket and state_prefix."
}

# Docker Container
variable "docker_registry" {
  type        = string
  description = "The FQDN of the Docker registry e.g. 169942020521.dkr.ecr.eu-west-2.amazonaws.com"
}
variable "eric_stream_version" {
  type        = string
  description = "The version of the eric stream service/container to run."
}
variable "log_level" {
  default     = "INFO"
  type        = string
  description = "The log level for services to use: TRACE, DEBUG, INFO or ERROR"
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

# EC2
variable "ec2_key_pair_name" {
  type        = string
  description = "The key pair for SSH access to ec2 instances in the clusters."
}
variable "ec2_instance_type" {
  default     = "t3.medium"
  type        = string
  description = "The instance type for ec2 instances in the clusters."
}
variable "ec2_image_id" {
  default     = "ami-007ef488b3574da6b" # ECS optimized Linux in London created 16/10/2019
  type        = string
  description = "The machine image name for the ECS cluster launch configuration."
}

# Auto-scaling Group
variable "asg_max_instance_count" {
  default     = 1
  type        = number
  description = "The maximum allowed number of instances in the autoscaling group for the cluster."
}
variable "asg_min_instance_count" {
  default     = 1
  type        = number
  description = "The minimum allowed number of instances in the autoscaling group for the cluster."
}
variable "asg_desired_instance_count" {
  default     = 1
  type        = number
  description = "The desired number of instances in the autoscaling group for the cluster. Must fall within the min/max instance count range."
}

# Certificates
variable "ssl_certificate_id" {
  type        = string
  description = "The ARN of the certificate for https access through the ALB."
}

# DNS
variable "zone_id" {
  default = "" # default of empty string is used as conditional when creating route53 records i.e. if no zone_id provided then no route53
  type        = string
  description = "The ID of the hosted zone to contain the Route 53 record."
}
variable "external_top_level_domain" {
  type        = string
  description = "The type levelel of the DNS domain for external access."
}

# # Vault
# variable "vault_username" {
#   type        = string
#   description = "The username used by the Vault provider."
# }
# variable "vault_password" {
#   type        = string
#   description = "The password used by the Vault provider."
# }

# # Secrets
# variable "vault_secrets" {
#   type = list(string)
#   description = "A list of the secrets to be added to Parameter Store."
#   default = [ "secret-mongo-url" ]
# }

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
