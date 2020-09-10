//---------------- START: Environment Secrets for services ---------------------

output "secrets_arn_map" {
  value = {
  for secret in aws_ssm_parameter.secret_parameters:
  secret.description => secret.arn
  }
  description = "The ARNs for all secrets"
}

//---------------- END: Environment Secrets for services ---------------------
