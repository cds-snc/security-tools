resource "aws_acm_certificate" "internal_domain" {
  domain_name = var.domain_name
  subject_alternative_names = [
    "*.${var.domain_name}",
    "*.dependencies.${var.domain_name}",
  ]
  validation_method = "DNS"

  tags = {
    (var.billing_tag_key) = var.billing_tag_value
    Terraform             = true
    Product               = "${var.product_name}-${var.tool_name}"
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
    Product               = "${var.product_name}-${var.tool_name}"
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

###
# SES Domain Identity
###
resource "aws_ses_domain_identity" "security_tools" {
  domain = var.domain_name
}

resource "aws_route53_record" "security_tools_amazonses_verification_record" {
  zone_id = aws_route53_zone.internal_domain.zone_id
  name    = "_amazonses.${aws_ses_domain_identity.security_tools.id}"
  type    = "TXT"
  ttl     = "600"
  records = [aws_ses_domain_identity.security_tools.verification_token]
}

resource "aws_ses_domain_identity_verification" "security_tools_verification" {
  domain = aws_ses_domain_identity.security_tools.id

  depends_on = [aws_route53_record.security_tools_amazonses_verification_record]
}

### DKIM
resource "aws_ses_domain_dkim" "security_tools" {
  domain = aws_ses_domain_identity.security_tools.domain
}

resource "aws_route53_record" "security_tools_amazonses_dkim_record" {
  count   = 3
  zone_id = aws_route53_zone.internal_domain.zone_id
  name    = "${element(aws_ses_domain_dkim.security_tools.dkim_tokens, count.index)}._domainkey"
  type    = "CNAME"
  ttl     = "600"
  records = ["${element(aws_ses_domain_dkim.security_tools.dkim_tokens, count.index)}.dkim.amazonses.com"]
}

## DMARC

resource "aws_route53_record" "security_tools_route_53_dmarc_txt" {
  zone_id = aws_route53_zone.internal_domain.id
  name    = "_dmarc.${aws_ses_domain_identity.security_tools.domain}"
  type    = "TXT"
  ttl     = "300"
  records = [
    "v=DMARC1;p=quarantine;pct=75;rua=mailto:security@cds-snc.ca"
  ]
}

### SES email from
resource "aws_ses_domain_mail_from" "security_tools" {
  domain           = aws_ses_domain_identity.security_tools.domain
  mail_from_domain = "bounce.${aws_ses_domain_identity.security_tools.domain}"
}

resource "aws_route53_record" "security_tools_ses_domain_mail_from_mx" {
  zone_id = aws_route53_zone.internal_domain.id
  name    = aws_ses_domain_mail_from.security_tools.mail_from_domain
  type    = "MX"
  ttl     = "600"
  records = ["10 feedback-smtp.${var.region}.amazonses.com"]
}

resource "aws_route53_record" "security_tools_ses_domain_mail_from_txt" {
  zone_id = aws_route53_zone.internal_domain.id
  name    = aws_ses_domain_mail_from.security_tools.mail_from_domain
  type    = "TXT"
  ttl     = "600"
  records = ["v=spf1 include:amazonses.com -all"]
}
