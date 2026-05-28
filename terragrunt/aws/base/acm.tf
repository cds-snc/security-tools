
resource "aws_acm_certificate" "base_hosted_zone" {
  provider = aws.us-east-1

  domain_name               = var.domain_name
  subject_alternative_names = ["*.${var.domain_name}"]
  validation_method         = "DNS"

  tags = {
    CostCentre = var.tool_name
    Terraform  = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "base_hosted_zone" {
  zone_id = aws_route53_zone.base_hosted_zone.id

  for_each = {
    for dvo in aws_acm_certificate.base_hosted_zone.domain_validation_options : dvo.domain_name => {
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

resource "aws_acm_certificate_validation" "base_hosted_zone" {
  provider                = aws.us-east-1
  certificate_arn         = aws_acm_certificate.base_hosted_zone.arn
  validation_record_fqdns = [for record in aws_route53_record.base_hosted_zone : record.fqdn]
}
