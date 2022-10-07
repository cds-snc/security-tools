resource "random_password" "dependencytrack_db_password" {
  for_each = toset([var.password_change_id])
  length   = 30
  special  = false

  min_lower   = 1
  min_upper   = 1
  min_numeric = 1
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
    Product               = "${var.product_name}-${var.tool_name}"
  }
}

resource "aws_ssm_parameter" "dependencytrack_db_user" {
  name  = "/${var.ssm_prefix}/dependencytrack_db_user"
  type  = "SecureString"
  value = random_string.dependencytrack_db_user.id

  tags = {
    (var.billing_tag_key) = var.billing_tag_value
    Terraform             = true
    Product               = "${var.product_name}-${var.tool_name}"
  }
}

resource "aws_ssm_parameter" "dependencytrack_db_url" {
  name  = "/${var.ssm_prefix}/dependencytrack_db_url"
  type  = "SecureString"
  value = "jdbc:postgresql://${module.dependencytrack_db.proxy_endpoint}:5432/dtrack?user=${aws_ssm_parameter.dependencytrack_db_user.value}&password=${aws_ssm_parameter.dependencytrack_db_password.value}"

  tags = {
    (var.billing_tag_key) = var.billing_tag_value
    Terraform             = true
    Product               = "${var.product_name}-${var.tool_name}"
  }
}
