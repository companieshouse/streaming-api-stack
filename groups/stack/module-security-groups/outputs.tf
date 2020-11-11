output "security_group_id" {
    description = "The ID of the security group that has been created"
    value = aws_security_group.internal-service-sg.id
}