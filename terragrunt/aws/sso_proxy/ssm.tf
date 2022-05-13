resource "aws_ssm_parameter" "pomerium_google_client_id" {
  name  = "/${var.ssm_prefix}/pomerium_google_client_id"
  type  = "SecureString"
  value = var.pomerium_google_client_id

  tags = {
    (var.billing_tag_key) = var.billing_tag_value
    Terraform             = true
    Product               = var.product_name
  }
}

resource "aws_ssm_parameter" "pomerium_google_client_secret" {
  name  = "/${var.ssm_prefix}/pomerium_google_client_secret"
  type  = "SecureString"
  value = var.pomerium_google_client_secret

  tags = {
    (var.billing_tag_key) = var.billing_tag_value
    Terraform             = true
    Product               = var.product_name
  }
}

resource "aws_ssm_parameter" "session_cookie_secret" {
  name  = "/${var.ssm_prefix}/session_cookie_secret"
  type  = "SecureString"
  value = var.session_cookie_secret

  tags = {
    (var.billing_tag_key) = var.billing_tag_value
    Terraform             = true
    Product               = var.product_name
  }
}

resource "aws_ssm_parameter" "session_key" {
  name  = "/${var.ssm_prefix}/session_key"
  type  = "SecureString"
  value = var.session_key

  tags = {
    (var.billing_tag_key) = var.billing_tag_value
    Terraform             = true
    Product               = var.product_name
  }
}

resource "aws_ssm_parameter" "pomerium_client_id" {
  name  = "/${var.ssm_prefix}/pomerium_client_id"
  type  = "SecureString"
  value = var.pomerium_client_id

  tags = {
    (var.billing_tag_key) = var.billing_tag_value
    Terraform             = true
    Product               = var.product_name
  }
}

resource "aws_ssm_parameter" "pomerium_client_secret" {
  name  = "/${var.ssm_prefix}/pomerium_client_secret"
  type  = "SecureString"
  value = var.pomerium_client_secret

  tags = {
    (var.billing_tag_key) = var.billing_tag_value
    Terraform             = true
    Product               = var.product_name
  }
}
