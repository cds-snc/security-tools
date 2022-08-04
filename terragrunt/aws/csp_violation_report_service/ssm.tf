resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "random_pet" "db_user" {
  length    = 2
  separator = "_"
}

resource "random_pet" "db_database" {
  length    = 2
  separator = "_"
}

resource "aws_ssm_parameter" "db_host" {
  name  = "/${var.ssm_prefix}/db_host"
  type  = "SecureString"
  value = module.csp_reports_db.proxy_endpoint

  tags = {
    (var.billing_tag_key) = var.billing_tag_value
    Terraform             = true
    Product               = "${var.product_name}-${var.tool_name}"
  }
}

resource "aws_ssm_parameter" "db_username" {
  name  = "/${var.ssm_prefix}/db_username"
  type  = "SecureString"
  value = random_pet.db_user.id

  tags = {
    (var.billing_tag_key) = var.billing_tag_value
    Terraform             = true
    Product               = "${var.product_name}-${var.tool_name}"
  }
}

resource "aws_ssm_parameter" "db_database" {
  name  = "/${var.ssm_prefix}/db_database"
  type  = "SecureString"
  value = random_pet.db_database.id

  tags = {
    (var.billing_tag_key) = var.billing_tag_value
    Terraform             = true
    Product               = "${var.product_name}-${var.tool_name}"
  }
}

resource "aws_ssm_parameter" "db_password" {
  name  = "/${var.ssm_prefix}/db_password"
  type  = "SecureString"
  value = random_password.password.result

  tags = {
    (var.billing_tag_key) = var.billing_tag_value
    Terraform             = true
    Product               = "${var.product_name}-${var.tool_name}"
  }
}
