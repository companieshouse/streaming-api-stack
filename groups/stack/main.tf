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

# # Remote state data source for Ireland, required for Concourse management CIDRs
# data "terraform_remote_state" "networks_common_infra_ireland" {
#   backend = "s3"
#   config = {
#     bucket = "development-eu-west-1.terraform-state.ch.gov.uk"
#     key    = "aws-common-infrastructure-terraform/common-${var.aws_region}/networking.tfstate"
#     region = "eu-west-1"
#   }
# }
# locals {
#   management_private_subnet_cidrs = values(data.terraform_remote_state.networks_common_infra_ireland.outputs.management_private_subnet_cidrs)
# }

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

# provider "vault" {
#   auth_login {
#     path = "auth/userpass/login/${var.vault_username}"
#     parameters = {
#       password = var.vault_password
#     }
#   }
# }

# data "vault_generic_secret" "secrets" {
#   for_each = toset(var.vault_secrets)
#   path = "applications/${var.aws_profile}/${var.environment}/${local.stack_name}/${each.value}"
# }

locals {
  # stack name is hardcoded here in main.tf for this stack. It should not be overridden per env
  stack_name       = "streaming-api"
  name_prefix      = "${local.stack_name}-${var.environment}"
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

# module "secrets" {
#   source = "./module-secrets"

#   stack_name  = local.stack_name
#   name_prefix = local.name_prefix
#   environment = var.environment
#   kms_key_id  = data.terraform_remote_state.services-stack-configs.outputs.services_stack_configs_kms_key_id
#   secrets     = data.vault_generic_secret.secrets
# }

module "ecs-services" {
  source = "./module-ecs-services"

  stack_name  = local.stack_name
  name_prefix = local.name_prefix
  environment = var.environment

  vpc_id                           = local.vpc_id
  aws_region                       = var.aws_region
  ssl_certificate_id               = var.ssl_certificate_id
  zone_id                          = var.zone_id
  external_top_level_domain        = var.external_top_level_domain
  internal_top_level_domain        = var.internal_top_level_domain
  application_ids                  = local.application_ids
  # web_access_cidrs                 = concat(local.internal_cidrs,local.vpn_cidrs,local.management_private_subnet_cidrs,split(",",local.application_cidrs))
  web_access_cidrs                 = concat(local.internal_cidrs,local.vpn_cidrs,split(",",local.application_cidrs))
  ecs_cluster_id                   = module.ecs-cluster.ecs_cluster_id
  task_execution_role_arn          = module.ecs-cluster.ecs_task_execution_role_arn
  docker_registry                  = var.docker_registry
  streaming_api_version            = var.streaming_api_version
  eric_stream_version              = var.eric_stream_version
  streaming_api_task_desired_count = var.streaming_api_task_desired_count

  log_level                        = var.log_level
  cache_url                        = var.cache_url
  cache_max_connections            = var.cache_max_connections
  cache_max_idle                   = var.cache_max_idle
  cache_idle_timeout               = var.cache_idle_timeout
  cache_ttl                        = var.cache_ttl
  flush_interval                   = var.flush_interval
  graceful_shutdown_period         = var.graceful_shutdown_period
  default_stream_limit             = var.default_stream_limit
  stream_check_interval_seconds    = var.stream_check_interval_seconds
  heartbeat_interval               = var.heartbeat_interval
  request_timeout                  = var.request_timeout
  schema_registry_url              = var.schema_registry_url
  kafka_streaming_broker_addr      = var.kafka_streaming_broker_addr

  # secrets_arn_map = module.secrets.secrets_arn_map
}
