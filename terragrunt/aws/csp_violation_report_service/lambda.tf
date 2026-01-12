module "csp_reports" {
  source    = "github.com/cds-snc/terraform-modules//lambda?ref=v10.10.2"
  name      = var.tool_name
  ecr_arn   = aws_ecr_repository.csp_reports.arn
  image_uri = "${aws_ecr_repository.csp_reports.repository_url}:latest"

  memory                         = 256
  timeout                        = 15
  enable_lambda_insights         = true
  reserved_concurrent_executions = 10

  billing_tag_value = var.tool_name
}

resource "aws_lambda_function_url" "csp_reports" {
  function_name      = module.csp_reports.function_name
  authorization_type = "NONE"
}

resource "aws_lambda_permission" "csp_reports_invoke_function_url" {
  statement_id           = "AllowInvokeFunctionUrl"
  action                 = "lambda:InvokeFunctionUrl"
  function_name          = module.csp_reports.function_name
  function_url_auth_type = "NONE"
  principal              = "*"
}

resource "aws_lambda_permission" "csp_reports_invoke_function" {
  statement_id  = "AllowInvokeFunction"
  action        = "lambda:InvokeFunction"
  function_name = module.csp_reports.function_name
  principal     = "*"
}
