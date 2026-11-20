resource "aws_route53_record" "sso_proxy_subdomains" {
  for_each = toset([
    "auth.${var.security_tools_domain_name}",
    "neo4j.${var.security_tools_domain_name}",
    "bolt.${var.security_tools_domain_name}"
  ])

  zone_id = var.hosted_zone_id
  name    = each.value
  type    = "A"

  alias {
    name                   = aws_lb.sso_proxy.dns_name
    zone_id                = aws_lb.sso_proxy.zone_id
    evaluate_target_health = true
  }
}
