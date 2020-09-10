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
variable "workspace_key_prefix" {
  type        = string
  description = "The bucket prefix used with the aws_bucket files."
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
variable "streaming_api_version" {
  type        = string
  description = "The version of the streaming api service/container to run."
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
variable "internal_top_level_domain" {
  type        = string
  description = "The type levelel of the DNS domain for internal access."
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
variable "cache_url" {
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
  default = "0"
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

# Streaming API service configs
variable "heartbeat_interval" {
  type = string
  default = "30"
}
variable "request_timeout" {
  type = string
  default = "86400"
}
variable "schema_registry_url" {
  type = string
}
variable "kafka_streaming_broker_addr" {
  type = string
}
