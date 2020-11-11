variable "environment" {
  type = string
}

variable "vpc_id" {
  description = "The ID of the VPC for the target group and security group."
  type        = string
}

variable "web_access_cidrs" {
  description = "Subnet CIDRs for web ingress rules in the security group."
  type        = list(string)
}

variable "name_prefix" {
  description = "The name prefix to be used for stack / environment name spacing."
  type        = string
}

variable "inbound_start_port" {
    description = "The starting port number of the inbound port range that will be opened."
    type = number
}

variable "inbound_end_port" {
    description = "The end port number of the inbound port range that will be opened."
    type = number
}
