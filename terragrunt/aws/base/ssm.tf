resource "aws_ssm_parameter" "smtp_username" {
  name  = "/${var.ssm_prefix}/smtp_username"
  type  = "SecureString"
  value = aws_iam_access_key.security_tools.id

  tags = {
    (var.billing_tag_key) = var.billing_tag_value
    Terraform             = true
    Product               = "${var.product_name}"
  }
}

resource "aws_ssm_parameter" "smtp_password" {
  name  = "/${var.ssm_prefix}/smtp_password"
  type  = "SecureString"
  value = aws_iam_access_key.security_tools.ses_smtp_password_v4

  tags = {
    (var.billing_tag_key) = var.billing_tag_value
    Terraform             = true
    Product               = "${var.product_name}"
  }
}
