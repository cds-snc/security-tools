# ---------------------------------------------------------------------------------------------------------------------
# CREATE SSO PROXY LOAD BALANCER
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_lb" "pomerium" {
  name               = "pomerium-sso"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.pomerium.id]
  subnets            = var.vpc_public_subnet_ids

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
    Product               = var.product_name
  }
}

resource "aws_lb_target_group" "sso_proxy" {
  name                 = "sso-proxy"
  port                 = 443
  protocol             = "HTTP"
  target_type          = "ip"
  deregistration_delay = 30
  vpc_id               = var.security_tools_vpc_id

  health_check {
    protocol            = "HTTP"
    path                = "/ping"
    port                = "traffic-port"
    timeout             = 10
    healthy_threshold   = 2
    unhealthy_threshold = 10
    interval            = 30
    matcher             = "200-399"
  }

  stickiness {
    type            = "lb_cookie"
    cookie_duration = 60
  }

  tags = {
    (var.billing_tag_key) = var.billing_tag_value
    Terraform             = true
    Product               = var.product_name
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.pomerium.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }

  tags = {
    (var.billing_tag_key) = var.billing_tag_value
    Terraform             = true
    Product               = var.product_name
  }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.pomerium.arn

  port            = 443
  protocol        = "HTTPS"
  ssl_policy      = "ELBSecurityPolicy-FS-1-2-Res-2020-10"
  certificate_arn = aws_acm_certificate.internal_domain.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.sso_proxy.arn
  }

  tags = {
    (var.billing_tag_key) = var.billing_tag_value
    Terraform             = true
    Product               = var.product_name
  }
}

resource "aws_lb_listener_certificate" "https_sni" {
  listener_arn    = aws_lb_listener.https.arn
  certificate_arn = aws_acm_certificate.internal_domain.arn
}
