variable "environment" {
  description = "The name of the environment the target service will be deployed to"
  type        = string
}

variable "remote_state_bucket" {
  description = "Alternative bucket used to store the remote state files from ch-service-terraform"
  type        = string
}

variable "state_prefix" {
  description = "The bucket prefix used with the remote_state_bucket files."
  type        = string
}

variable "deploy_to" {
  description = "Bucket namespace used with remote_state_bucket and state_prefix."
  type        = string
}

variable "aws_region" {
  description = "The AWS region for deployment."
  type        = string
  default     = "eu-west-2"
}

variable "aws_profile" {
  description = "The AWS profile to use for deployment."
  type        = string
  default     = "development-eu-west-2"
}

variable "aws_bucket" {
  description = "The bucket used to store the current terraform state files"
  type        = string
}

variable "task_desired_count" {
  description = "Number of task instances that will be run"
  type = number
  default = 1
}

# Configuration vars

variable "server_port" {
    description = "The port from which the service will be accessed"
    type = number
    default = 18581
}

variable "docker_registry" {
  description = "The host of the Docker registry instance that the container image will be downloaded from"
  type = string
}

variable "streaming_api_backend_version" {
  description = "The version of streaming API backend that will be deployed"
  type = string
}

# Runtime vars

variable "kafka_broker_url" {
  description = "The URL of the Kafka broker that the backend will connect to"
  type = string
}

variable "schema_registry_url" {
  description = "The URL of the schema registry instance schema definitions will be fetched from"
  type = string
}

variable "log_level" {
  description = "The threshold from which logs will be output"
  type = string
}

# EC2
variable "ec2_key_pair_name" {
  description = "The key pair for SSH access to ec2 instances in the clusters."
  type        = string
}

variable "ec2_instance_type" {
  description = "The instance type for ec2 instances in the clusters."
  type        = string
  default     = "t3.medium"
}

variable "ec2_image_id" {
  description = "The machine image name for the ECS cluster launch configuration."
  type        = string
  default     = "ami-007ef488b3574da6b" # ECS optimized Linux in London created 16/10/2019
}

# Auto-scaling Group
variable "asg_max_instance_count" {
  description = "The maximum allowed number of instances in the autoscaling group for the cluster."
  type        = number
  default     = 1
}

variable "asg_min_instance_count" {
  description = "The minimum allowed number of instances in the autoscaling group for the cluster."
  type        = number
  default     = 1
}

variable "asg_desired_instance_count" {
  description = "The desired number of instances in the autoscaling group for the cluster. Must fall within the min/max instance count range."
  type        = number
  default     = 1
}