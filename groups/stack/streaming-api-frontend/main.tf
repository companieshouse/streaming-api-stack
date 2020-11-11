provider "aws" {
  region  = var.aws_region
  version = "~> 2.32.0"
}

terraform {
  backend "s3" {
  }
}

# Configure the remote state data source to acquire configuration
# created through the code in ch-service-terraform/aws-mm-networks.
data "terraform_remote_state" "networks" {
  backend  = "s3"
  config   = {
    bucket = var.remote_state_bucket
    key    = "${var.state_prefix}/${var.deploy_to}/${var.deploy_to}.tfstate"
    region = var.aws_region
  }
}
locals {
  vpc_id            = data.terraform_remote_state.networks.outputs.vpc_id
  application_ids   = data.terraform_remote_state.networks.outputs.application_ids
  application_cidrs = data.terraform_remote_state.networks.outputs.application_cidrs
}

# Configure the remote state data source to acquire configuration created
# through the code in aws-common-infrastructure-terraform/groups/networking.
data "terraform_remote_state" "networks_common_infra" {
  backend = "s3"
  config = {
    bucket = var.aws_bucket
    key    = "aws-common-infrastructure-terraform/common-${var.aws_region}/networking.tfstate"
    region = var.aws_region
  }
}
locals {
  internal_cidrs = values(data.terraform_remote_state.networks_common_infra.outputs.internal_cidrs)
  vpn_cidrs      = values(data.terraform_remote_state.networks_common_infra.outputs.vpn_cidrs)
}

# Configure the remote state data source to acquire configuration
# created through the code in the services-stack-configs stack in the
# aws-common-infrastructure-terraform repo.
data "terraform_remote_state" "services-stack-configs" {
  backend = "s3"
  config = {
    bucket = var.aws_bucket # aws-common-infrastructure-terraform repo uses the same remote state bucket
    key    = "aws-common-infrastructure-terraform/common-${var.aws_region}/services-stack-configs.tfstate"
    region = var.aws_region
  }
}

locals {
  stack_name       = "streaming-api-frontend"
  name_prefix      = "${local.stack_name}-${var.environment}"
  ssl_port         = 443
  tcp_protocol     = "tcp"
  eric_stream_port = "10000"
  template_vars    = {
    aws_region                     = var.aws_region
    name_prefix                    = local.name_prefix
    docker_registry                = var.docker_registry
    bind_address                   = var.server_port
    external_top_level_domain      = var.external_top_level_domain
    docker_registry                = var.docker_registry
    log_level                      = var.log_level
    cache_broker_url               = var.cache_broker_url
    eric_stream_version            = var.eric_stream_version
    eric_stream_port               = local.eric_stream_port
    streaming_api_frontend_version = var.streaming_api_frontend_version
    cache_url                      = var.cache_url
    cache_max_connections          = var.cache_max_connections
    cache_max_idle                 = var.cache_max_idle
    cache_idle_timeout             = var.cache_idle_timeout
    cache_ttl                      = var.cache_ttl
    flush_interval                 = var.flush_interval
    graceful_shutdown_period       = var.graceful_shutdown_period
    default_stream_limit           = var.default_stream_limit
    stream_check_interval_seconds  = var.stream_check_interval_seconds
    heartbeat_interval             = var.heartbeat_interval
    request_timeout                = var.request_timeout
  }
}

module "ecs-cluster" {
  source = "git::git@github.com:companieshouse/terraform-library-ecs-cluster.git?ref=1.1.1"

  stack_name  = local.stack_name
  name_prefix = local.name_prefix
  environment = var.environment

  vpc_id                     = local.vpc_id
  subnet_ids                 = local.application_ids
  ec2_key_pair_name          = var.ec2_key_pair_name
  ec2_instance_type          = var.ec2_instance_type
  ec2_image_id               = var.ec2_image_id
  asg_max_instance_count     = var.asg_max_instance_count
  asg_min_instance_count     = var.asg_min_instance_count
  asg_desired_instance_count = var.asg_desired_instance_count
}

module "ecs-security-group" {
  source = "../module-security-groups"

  environment        = var.environment
  vpc_id             = local.vpc_id
  web_access_cidrs   = concat(local.internal_cidrs,local.vpn_cidrs,split(",",local.application_cidrs))
  name_prefix        = local.name_prefix
  inbound_start_port = var.server_port
  inbound_end_port   = var.server_port
}

resource "aws_security_group_rule" "inbound" {
  type = "ingress"

  security_group_id = module.ecs-security-group.security_group_id

  from_port   = local.ssl_port
  to_port     = local.ssl_port
  protocol    = local.tcp_protocol
  cidr_blocks = concat(local.internal_cidrs,local.vpn_cidrs,split(",",local.application_cidrs))
}

module "ecs-service" {
  source  = "../module-lb-ecs-service"

  stack_name                = local.stack_name
  environment               = var.environment
  task_desired_count        = var.task_desired_count
  ecs_cluster_id            = module.ecs-cluster.ecs_cluster_id
  container_port            = var.server_port
  template_vars             = local.template_vars
  task_execution_role_arn   = module.ecs-cluster.ecs_task_execution_role_arn
  security_groups           = ["${module.ecs-security-group.security_group_id}"]
  vpc_id                    = local.vpc_id
  application_ids           = local.application_ids
  ssl_certificate_id        = var.ssl_certificate_id
  external_top_level_domain = var.external_top_level_domain
  zone_id                   = var.zone_id
}