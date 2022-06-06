resource "aws_ssm_parameter" "neo4j_password" {
  name  = "/${var.ssm_prefix}/neo4j_password"
  type  = "SecureString"
  value = var.neo4j_password

  tags = {
    (var.billing_tag_key) = var.billing_tag_value
    Terraform             = true
    Product               = "${var.product_name}-${var.tool_name}"
  }
}

resource "aws_ssm_parameter" "customer_id" {
  name  = "/${var.ssm_prefix}/customer_id"
  type  = "SecureString"
  value = var.customer_id

  tags = {
    (var.billing_tag_key) = var.billing_tag_value
    Terraform             = true
    Product               = "${var.product_name}-${var.tool_name}"
  }
}

resource "aws_ssm_parameter" "shared_key" {
  name  = "/${var.ssm_prefix}/shared_key"
  type  = "SecureString"
  value = var.shared_key

  tags = {
    (var.billing_tag_key) = var.billing_tag_value
    Terraform             = true
    Product               = "${var.product_name}-${var.tool_name}"
  }
}

# This only sets the initial password. To change the password you need to
# login to the neo4j console and change the password using the :server change-password command.
# Ensure you update the Github secret so that other services can connect to the database
resource "aws_ssm_parameter" "neo4j_auth" {
  name  = "/${var.ssm_prefix}/neo4j_auth"
  type  = "SecureString"
  value = "neo4j/${var.neo4j_password}"

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

