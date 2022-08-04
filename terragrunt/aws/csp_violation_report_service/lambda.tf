module "purge_csp_reports_lambda" {
  source                 = "github.com/cds-snc/terraform-modules?ref=v3.0.5//lambda"
  name                   = "purge_stale_reports"
  billing_tag_value      = var.billing_tag_value
  ecr_arn                = aws_ecr_repository.purge_csp_reports.arn
  enable_lambda_insights = true
  image_uri              = "${aws_ecr_repository.purge_csp_reports.repository_url}:latest"
  memory                 = 512
  timeout                = 300

  vpc = {
    security_group_ids = [aws_security_group.csp_reports.id, module.csp_reports_db.proxy_security_group_id]
    subnet_ids         = var.vpc_private_subnet_ids
  }

  environment_variables = {
    DB_HOST_PARAM_NAME      = aws_ssm_parameter.db_host.name
    DB_USERNAME_PARAM_NAME  = aws_ssm_parameter.db_username.name
    DB_DATABASE_PARAM_NAME  = aws_ssm_parameter.db_database.name
    DB_PASSWORD_PARAM_NAME  = aws_ssm_parameter.db_password.name
    DB_PORT                 = 5432
    POWERTOOLS_SERVICE_NAME = "${var.product_name}"
  }

  policies = [
    data.aws_iam_policy_document.purge_csp_reports_lambda_policies.json,
  ]
}

# Delete CSP reports that are older than 90 days every 24 hours

resource "aws_lambda_permission" "allow_cloudwatch_to_call_lambda" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = module.purge_csp_reports_lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.purge_stale_csp_reports_every_24_hours.arn
}

resource "aws_cloudwatch_event_rule" "purge_stale_csp_reports_every_24_hours" {
  name                = "purge-stale-csp-reports-${var.tool_name}"
  description         = "Fires every 24 hours"
  schedule_expression = "cron(0 0 * * ? *)"

  tags = {
    (var.billing_tag_key) = var.billing_tag_value
    Terraform             = true
    Product               = "${var.product_name}-${var.tool_name}"
  }
}

resource "aws_cloudwatch_event_target" "trigger_api_lambda_to_purge_stale_reports" {
  rule      = aws_cloudwatch_event_rule.purge_stale_csp_reports_every_24_hours.name
  target_id = "${var.product_name}-${var.tool_name}-purge-stale"
  arn       = module.purge_csp_reports_lambda.function_arn
}
