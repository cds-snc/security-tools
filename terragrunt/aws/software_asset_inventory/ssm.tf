resource "random_password" "dependencytrack_db_password" {
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

resource "random_string" "dependencytrack_db_user" {
  length  = 10
  special = false
}

resource "aws_ssm_parameter" "dependencytrack_db_password" {
  name  = "/${var.ssm_prefix}/dependencytrack_db_password"
  type  = "SecureString"
  value = random_password.dependencytrack_db_password[var.password_change_id].result

  tags = {
    (var.billing_tag_key) = var.billing_tag_value
    Terraform             = true
    Product               = var.product_name
  }
}

resource "aws_ssm_parameter" "dependencytrack_db_user" {
  name  = "/${var.ssm_prefix}/dependencytrack_db_user"
  type  = "SecureString"
  value = random_string.dependencytrack_db_user.id

  tags = {
    (var.billing_tag_key) = var.billing_tag_value
    Terraform             = true
    Product               = var.product_name
  }
}
