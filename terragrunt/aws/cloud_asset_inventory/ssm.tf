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