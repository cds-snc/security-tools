module "csp_reports" {
  source    = "github.com/cds-snc/terraform-modules//lambda?ref=v7.0.1"
  name      = var.tool_name
  ecr_arn   = aws_ecr_repository.csp_reports.arn
  image_uri = "${aws_ecr_repository.csp_reports.repository_url}:latest"

  memory                 = 1024
  timeout                = 120
  enable_lambda_insights = true

  billing_tag_value = var.tool_name
}

resource "aws_lambda_function_url" "csp_reports" {
  function_name      = module.csp_reports.function_name
  authorization_type = "NONE"
}
