resource "aws_cloudwatch_log_metric_filter" "csp_report_error" {
  name           = "CSPReportError"
  pattern        = "?ERROR ?Error"
  log_group_name = local.csp_reports_log_group_name

  metric_transformation {
    name      = "CSPReportError"
    namespace = "CSPReportError"
    value     = "1"
  }
}

resource "aws_cloudwatch_metric_alarm" "csp_report_error" {
  alarm_name          = "CSP Report Error"
  alarm_description   = "Error logged by the service's lambda function"
  comparison_operator = "GreaterThanOrEqualToThreshold"

  metric_name        = aws_cloudwatch_log_metric_filter.csp_report_error.metric_transformation[0].name
  namespace          = aws_cloudwatch_log_metric_filter.csp_report_error.metric_transformation[0].namespace
  period             = "60"
  evaluation_periods = "1"
  statistic          = "Sum"
  threshold          = 1
  treat_missing_data = "notBreaching"

  alarm_actions = [local.sns_alarm_topic_arn]
  ok_actions    = [local.sns_alarm_topic_arn]
}
