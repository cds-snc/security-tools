resource "aws_security_group" "csp_reports" {
  #checkov:skip=CKV2_AWS_5:This security group is used by the CSP Reports ECS tasks.
  name        = "csp_reports"
  description = "Allow inbound traffic to csp reports load balancer"
  vpc_id      = var.security_tools_vpc_id

  tags = {
    (var.billing_tag_key) = var.billing_tag_value
    Terraform             = true
    Product               = "${var.product_name}-${var.tool_name}"
  }
}

resource "aws_security_group_rule" "port_443_egress" {
  description       = "Security group rule for egress to port 443"
  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.csp_reports.id
}

resource "aws_security_group_rule" "port_443_ingress" {
  description       = "Security group rule for ingress to port 443"
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.csp_reports.id
}

resource "aws_security_group_rule" "port_8000_ingress" {
  description       = "Security group rule for ingress to port 8000 (CSP Report app)"
  type              = "ingress"
  from_port         = 8000
  to_port           = 8000
  protocol          = "tcp"
  cidr_blocks       = concat(var.vpc_private_subnet_cidrs, var.vpc_public_subnet_cidrs)
  security_group_id = aws_security_group.csp_reports.id
}

resource "aws_security_group_rule" "port_8000_egress" {
  description              = "Security group rule for egress to port 8000 (CSP Report app)"
  type                     = "egress"
  from_port                = 8000
  to_port                  = 8000
  protocol                 = "tcp"
  security_group_id        = aws_security_group.csp_reports.id
  source_security_group_id = aws_security_group.csp_reports.id
}

resource "aws_security_group_rule" "port_5432_egress" {
  description              = "Security group rule for egress to port 5432 (postgres)"
  type                     = "egress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  security_group_id        = aws_security_group.csp_reports.id
  source_security_group_id = aws_security_group.csp_reports.id
}

resource "aws_security_group_rule" "port_5432_ingress" {
  description              = "Security group rule for ingress to port 5432 (postgres)"
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  security_group_id        = aws_security_group.csp_reports.id
  source_security_group_id = aws_security_group.csp_reports.id
}
