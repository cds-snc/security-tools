resource "aws_security_group" "cloudquery" {
  #checkov:skip=CKV2_AWS_5:This security group is used by the Cloudquery ECS tasks.
  name        = "cloudquery"
  description = "Allow inbound traffic to cloudquery load balancer"
  vpc_id      = var.security_tools_vpc_id

  egress {
    description = "Outbound access to internet"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Access to services running on https"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = concat(var.vpc_private_subnet_cidrs, var.vpc_public_subnet_cidrs)
  }

  tags = {
    (var.billing_tag_key) = var.billing_tag_value
    Terraform             = true
    Product               = "${var.product_name}-${var.tool_name}"
  }
}
