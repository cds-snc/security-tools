resource "aws_ecs_cluster" "sso_proxy" {
  name = "sso_proxy"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = {
    (var.billing_tag_key) = var.billing_tag_value
    Terraform             = true
    Product               = "${var.product_name}-${var.tool_name}"
  }
}

# ECS Service Connect namespace for internal service discovery
resource "aws_service_discovery_http_namespace" "internal_mesh" {
  name = "internal.mesh"

  tags = {
    (var.billing_tag_key) = var.billing_tag_value
    Terraform             = true
    Product               = "${var.product_name}-${var.tool_name}"
  }
}
