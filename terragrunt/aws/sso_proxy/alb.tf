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
  preserve_host_header       = true

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

resource "aws_lb_target_group" "oauth2_proxy" {
  for_each = local.oauth2_proxy_routes

  name                 = "oauth2-proxy-${each.key}"
  port                 = each.value.port
  protocol             = "HTTP"
  target_type          = "ip"
  deregistration_delay = 30
  vpc_id               = var.security_tools_vpc_id

  health_check {
    protocol            = "HTTP"
    path                = "/ready"
    port                = "traffic-port"
    timeout             = 10
    healthy_threshold   = 2
    unhealthy_threshold = 3
    interval            = 30
    matcher             = "200"
  }

  tags = {
    (var.billing_tag_key) = var.billing_tag_value
    Terraform             = true
    Product               = "${var.product_name}-${var.tool_name}"
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
    Product               = "${var.product_name}-${var.tool_name}"
  }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.pomerium.arn

  port                                                           = 443
  protocol                                                       = "HTTPS"
  ssl_policy                                                     = "ELBSecurityPolicy-FS-1-2-Res-2020-10"
  certificate_arn                                                = var.hosted_zone_certificate_arn
  routing_http_response_access_control_allow_origin_header_value = "https://neo4j.${var.security_tools_domain_name}"

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "Not found"
      status_code  = "404"
    }
  }

  tags = {
    (var.billing_tag_key) = var.billing_tag_value
    Terraform             = true
    Product               = "${var.product_name}-${var.tool_name}"
  }
}

resource "aws_lb_listener_rule" "neo4j" {
  listener_arn = aws_lb_listener.https.arn
  priority     = 10

  condition {
    host_header {
      values = ["neo4j.${var.security_tools_domain_name}"]
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.oauth2_proxy["neo4j"].arn
  }
}

resource "aws_lb_listener_rule" "bolt" {
  listener_arn = aws_lb_listener.https.arn
  priority     = 20

  condition {
    host_header {
      values = ["bolt.${var.security_tools_domain_name}"]
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.oauth2_proxy["bolt"].arn
  }
}

resource "aws_lb_listener_rule" "auth" {
  listener_arn = aws_lb_listener.https.arn
  priority     = 30

  condition {
    host_header {
      values = ["auth.${var.security_tools_domain_name}"]
    }
  }
  condition {
    path_pattern {
      values = ["/oauth2/callback", "/oauth2/start", "/oauth2/sign_in", "/oauth2/sign_out"]
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.oauth2_proxy["neo4j"].arn
  }
}

resource "aws_lb_listener_certificate" "https_sni" {
  listener_arn    = aws_lb_listener.https.arn
  certificate_arn = var.hosted_zone_certificate_arn
}
