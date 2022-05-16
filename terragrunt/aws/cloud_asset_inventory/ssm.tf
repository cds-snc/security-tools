# All passwords in this file are set to rotate automatically every month.
# Inspired by https://www.daringway.com/how-to-rotate-random-passwords-in-terraform/
resource "random_password" "neo4j_password" {
  for_each         = toset([var.password_change_id])
  length           = 32
  lower            = true
  upper            = true
  special          = true
  override_special = "%*()-_{}<>" # Allowed special characters that dont overlap with ip address and http RFC's

  min_lower   = 1
  min_upper   = 1
  min_numeric = 1
  min_special = 1
}

resource "aws_ssm_parameter" "neo4j_password" {
  name  = "/${var.ssm_prefix}/neo4j_password"
  type  = "SecureString"
  value = random_password.neo4j_password[var.password_change_id].result

  tags = {
    (var.billing_tag_key) = var.billing_tag_value
    Terraform             = true
    Product               = "${var.product_name}-${var.tool_name}"
  }
}

resource "aws_ssm_parameter" "neo4j_auth" {
  name  = "/${var.ssm_prefix}/neo4j_auth"
  type  = "SecureString"
  value = "neo4j/${random_password.neo4j_password[var.password_change_id].result}"

  tags = {
    (var.billing_tag_key) = var.billing_tag_value
    Terraform             = true
    Product               = "${var.product_name}-${var.tool_name}"
  }
}

resource "aws_ssm_parameter" "asset_inventory_account_list" {
  #checkov:skip=CKV2_AWS_34:Encryption: Not required
  name  = "/${var.ssm_prefix}/asset_inventory_account_list"
  type  = "StringList"
  value = jsonencode(var.asset_inventory_managed_accounts)

  tags = {
    (var.billing_tag_key) = var.billing_tag_value
    Terraform             = true
    Product               = "${var.product_name}-${var.tool_name}"
  }
}

