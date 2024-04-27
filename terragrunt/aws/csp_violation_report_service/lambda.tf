module "csp_reports" {
  source    = "github.com/cds-snc/terraform-modules//lambda?ref=v9.3.9"
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
