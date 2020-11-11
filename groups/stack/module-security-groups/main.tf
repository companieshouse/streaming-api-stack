locals {
  tcp_protocol = "tcp"
  any_port = 0
  any_protocol = "-1"
  all_ips = ["0.0.0.0/0"]
}

resource "aws_security_group" "internal-service-sg" {
  description = "Security group for internal service albs"
  vpc_id      = var.vpc_id

  tags = {
    Environment = var.environment
    Name        = "${var.name_prefix}-internal-service-sg"
  }
}

resource "aws_security_group_rule" "inbound" {
  type = "ingress"
  security_group_id = aws_security_group.internal-service-sg.id

  from_port = var.inbound_start_port
  to_port = var.inbound_end_port
  protocol = local.tcp_protocol
  cidr_blocks = var.web_access_cidrs

}

resource "aws_security_group_rule" "outbound" {
  type = "egress"
  security_group_id = aws_security_group.internal-service-sg.id

  from_port = local.any_port
  to_port = local.any_port
  protocol = local.any_protocol
  cidr_blocks = local.all_ips
}
