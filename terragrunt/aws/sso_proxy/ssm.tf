resource "aws_ssm_parameter" "google_client_id" {
  name  = "/${var.ssm_prefix}/pomerium_google_client_id"
  type  = "SecureString"
  value = var.google_client_id

  tags = {
    (var.billing_tag_key) = var.billing_tag_value
    Terraform             = true
    Product               = "${var.product_name}-${var.tool_name}"
  }
}

resource "aws_ssm_parameter" "google_client_secret" {
  name  = "/${var.ssm_prefix}/pomerium_google_client_secret"
  type  = "SecureString"
  value = var.google_client_secret

  tags = {
    (var.billing_tag_key) = var.billing_tag_value
    Terraform             = true
    Product               = "${var.product_name}-${var.tool_name}"
  }
}

resource "aws_ssm_parameter" "oauth2_proxy_cookie_secret" {
  name  = "/${var.ssm_prefix}/oauth2_proxy_cookie_secret"
  type  = "SecureString"
  value = var.oauth2_proxy_cookie_secret

  tags = {
    (var.billing_tag_key) = var.billing_tag_value
    Terraform             = true
    Product               = "${var.product_name}-${var.tool_name}"
  }
}

moved {
  from = aws_ssm_parameter.pomerium_google_client_id
  to   = aws_ssm_parameter.google_client_id
}

moved {
  from = aws_ssm_parameter.pomerium_google_client_secret
  to   = aws_ssm_parameter.google_client_secret
}
