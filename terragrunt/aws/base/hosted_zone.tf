resource "aws_route53_zone" "base_hosted_zone" {
  name = var.domain_name

  tags = {
    CostCentre = var.billing_tag_value
    Terraform  = true
  }
}