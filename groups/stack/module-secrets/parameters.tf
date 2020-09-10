# ----------------------------------------------------------------------------------------------------------------------

locals {
  vault_secrets = {
    for secret in var.secrets:
    reverse(split("/",secret.path))[0] => secret.data["value"]
  }
}

resource "aws_ssm_parameter" "secret_parameters" {
  for_each = local.vault_secrets
    name  = "/${var.name_prefix}/${each.key}"
    key_id = var.kms_key_id
    description = each.key
    type  = "SecureString"
    overwrite = "true"
    value = each.value
}
