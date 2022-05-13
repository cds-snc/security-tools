resource "aws_acm_certificate" "internal_domain" {
  domain_name = var.domain_name
  subject_alternative_names = [
    "*.${var.domain_name}",
  ]
  validation_method = "DNS"

  tags = {
    (var.billing_tag_key) = var.billing_tag_value
    Terraform             = true
    Product               = var.product_name
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_zone" "internal_domain" {
  name = var.domain_name

  tags = {
    (var.billing_tag_key) = var.billing_tag_value
    Terraform             = true
    Product               = var.product_name
  }
}

resource "aws_route53_record" "internal_domain_dns_validation" {
  zone_id = aws_route53_zone.internal_domain.zone_id

  for_each = {
    for dvo in aws_acm_certificate.internal_domain.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      type   = dvo.resource_record_type
      record = dvo.resource_record_value
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  type            = each.value.type

  ttl = 60
}

resource "aws_route53_record" "wildcard" {
  zone_id = aws_route53_zone.internal_domain.zone_id
  name    = "*.${var.domain_name}"
  type    = "A"

  alias {
    name                   = aws_lb.pomerium.dns_name
    zone_id                = aws_lb.pomerium.zone_id
    evaluate_target_health = false
  }
}

resource "aws_acm_certificate_validation" "internal_domain_certificate_validation" {
  certificate_arn         = aws_acm_certificate.internal_domain.arn
  validation_record_fqdns = [for record in aws_route53_record.internal_domain_dns_validation : record.fqdn]
}
