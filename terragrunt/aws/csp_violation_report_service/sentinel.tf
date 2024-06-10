module "sentinel_forwarder" {
  source            = "github.com/cds-snc/terraform-modules//sentinel_forwarder?ref=v9.4.8"
  function_name     = "${var.tool_name}_sentinel"
  billing_tag_value = var.tool_name

  layer_arn = "arn:aws:lambda:ca-central-1:283582579564:layer:aws-sentinel-connector-layer:125"

  customer_id = var.log_analytics_workspace_id
  shared_key  = var.log_analytics_workspace_key

  cloudwatch_log_arns = [
    local.csp_reports_log_group_arn
  ]
}

resource "aws_cloudwatch_log_subscription_filter" "csp_report" {
  name            = "CSP report"
  log_group_name  = local.csp_reports_log_group_name
  filter_pattern  = "[w1=\"*csp-report*\"]"
  destination_arn = module.sentinel_forwarder.lambda_arn
  distribution    = "Random"
}
