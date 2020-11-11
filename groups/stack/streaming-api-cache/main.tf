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
  backend = "s3"
  config = {
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
  stack_name       = "streaming-api-cache"
  name_prefix      = "${local.stack_name}-${var.environment}"
  template_vars    = {
    aws_region = var.aws_region
    docker_registry = var.docker_registry
    bind_address = var.server_port
    log_level = var.log_level
    name_prefix = local.name_prefix
    streaming_api_backend_url = var.streaming_api_backend_url
    redis_url = var.redis_url
    redis_pool_size = var.redis_pool_size
    cache_expiry_seconds = var.cache_expiry_seconds
    streaming_api_cache_version = var.streaming_api_cache_version
    stream_backend_filings_path = var.stream_backend_filings_path
    stream_backend_companies_path = var.stream_backend_companies_path
    stream_backend_insolvency_path = var.stream_backend_insolvency_path
    stream_backend_charges_path = var.stream_backend_charges_path
    stream_backend_officers_path = var.stream_backend_officers_path
    stream_backend_pscs_path = var.stream_backend_pscs_path
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

    environment = var.environment
    vpc_id = local.vpc_id
    web_access_cidrs = concat(local.internal_cidrs,local.vpn_cidrs,split(",",local.application_cidrs))
    name_prefix = local.name_prefix
    inbound_start_port = var.server_port
    inbound_end_port = var.server_port
}

module "ecs-service" {
    source = "../module-ecs-service"

    stack_name = local.stack_name
    environment = var.environment
    task_desired_count = var.task_desired_count
    ecs_cluster_id = module.ecs-cluster.ecs_cluster_id
    task_execution_role_arn = module.ecs-cluster.ecs_task_execution_role_arn
    template_vars = local.template_vars
    application_ids = local.application_ids
    security_groups = ["${module.ecs-security-group.security_group_id}"]
}