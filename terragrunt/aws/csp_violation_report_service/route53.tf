resource "aws_route53_record" "csp_reports_A" {
  zone_id = var.hosted_zone_id
  name    = var.tool_domain_name
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.csp_reports.domain_name
    zone_id                = aws_cloudfront_distribution.csp_reports.hosted_zone_id
    evaluate_target_health = false
  }
}
