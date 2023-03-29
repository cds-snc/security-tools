#
# Load balancer
#
resource "aws_lb" "cloudquery" {
  #checkov:skip=CKV_AWS_152:Load Balancer: Not running in high availability mode
  name               = "cloudquery"
  internal           = true
  load_balancer_type = "network"
  subnets            = var.vpc_private_subnet_ids

  access_logs {
    bucket  = var.cbs_satellite_bucket_name
    prefix  = "lb_logs"
    enabled = true
  }

  drop_invalid_header_fields = true
  enable_deletion_protection = true

  tags = {
    (var.billing_tag_key) = var.billing_tag_value
    Terraform             = true
    Product               = "${var.product_name}-${var.tool_name}"
  }
}
