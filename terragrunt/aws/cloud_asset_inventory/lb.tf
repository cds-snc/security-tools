#
# Load balancer
#
resource "aws_lb" "cartography" {
  #checkov:skip=CKV_AWS_152:Load Balancer: Not running in high availability mode
  name               = "cartography"
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

resource "aws_lb_target_group" "neo4j" {
  name                 = "neo4j"
  port                 = 7474
  protocol             = "TCP"
  target_type          = "ip"
  deregistration_delay = 30
  vpc_id               = var.security_tools_vpc_id

  tags = {
    (var.billing_tag_key) = var.billing_tag_value
    Terraform             = true
    Product               = "${var.product_name}-${var.tool_name}"
  }
}

resource "aws_lb_target_group" "bolt" {
  name                 = "bolt"
  port                 = 7687
  protocol             = "TCP"
  target_type          = "ip"
  deregistration_delay = 30
  vpc_id               = var.security_tools_vpc_id

  tags = {
    (var.billing_tag_key) = var.billing_tag_value
    Terraform             = true
    Product               = "${var.product_name}-${var.tool_name}"
  }
}


resource "aws_lb_listener" "neo4j" {
  load_balancer_arn = aws_lb.cartography.arn

  port     = 7474
  protocol = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.neo4j.arn
  }

  tags = {
    (var.billing_tag_key) = var.billing_tag_value
    Terraform             = true
    Product               = "${var.product_name}-${var.tool_name}"
  }
}

resource "aws_lb_listener" "bolt" {
  load_balancer_arn = aws_lb.cartography.arn

  port     = 7687
  protocol = "TCP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.bolt.arn
  }

  tags = {
    (var.billing_tag_key) = var.billing_tag_value
    Terraform             = true
    Product               = "${var.product_name}-${var.tool_name}"
  }
}
