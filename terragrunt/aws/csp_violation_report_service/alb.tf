#
# Load balancer
#
resource "aws_lb" "csp_reports" {
  #checkov:skip=CKV2_AWS_20:HTTPS served upstream by the SSO proxy load balancer
  #checkov:skip=CKV_AWS_103:HTTPS served upstream by the SSO proxy load balancer
  name               = "csp-reports"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.csp_reports.id]
  subnets            = var.vpc_private_subnet_ids

  drop_invalid_header_fields = true
  enable_deletion_protection = true

  access_logs {
    bucket  = var.cbs_satellite_bucket_name
    prefix  = "lb_logs"
    enabled = true
  }

  tags = {
    (var.billing_tag_key) = var.billing_tag_value
    Terraform             = true
    Product               = "${var.product_name}-${var.tool_name}"
  }
}
resource "aws_lb_target_group" "csp_reports" {
  name                 = "csp-reports"
  port                 = 8000
  protocol             = "HTTP"
  target_type          = "ip"
  deregistration_delay = 30
  vpc_id               = var.security_tools_vpc_id

  health_check {
    protocol            = "HTTP"
    path                = "/healthcheck"
    port                = "traffic-port"
    timeout             = 10
    healthy_threshold   = 2
    unhealthy_threshold = 10
    interval            = 15
    matcher             = "200-399"
  }

  tags = {
    (var.billing_tag_key) = var.billing_tag_value
    Terraform             = true
    Product               = "${var.product_name}-${var.tool_name}"
  }
}

resource "aws_lb_listener" "csp_reports" {
  #checkov:skip=CKV_AWS_2:HTTPS served upstream by the SSO proxy load balancer
  #checkov:skip=CKV_AWS_103:HTTPS served upstream by the SSO proxy load balancer
  load_balancer_arn = aws_lb.csp_reports.arn

  port     = 8000
  protocol = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.csp_reports.arn
  }

  tags = {
    (var.billing_tag_key) = var.billing_tag_value
    Terraform             = true
    Product               = "${var.product_name}-${var.tool_name}"
  }
}
