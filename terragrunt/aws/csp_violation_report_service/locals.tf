locals {
  csp_reports_log_group_name = "/aws/lambda/${module.csp_reports.function_name}"
  csp_reports_log_group_arn  = "arn:aws:logs:${var.region}:${var.account_id}:log-group:${local.csp_reports_log_group_name}"
  sns_alarm_topic_arn        = "arn:aws:sns:${var.region}:${var.account_id}:internal-sre-alert"
}