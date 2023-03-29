resource "aws_ecs_cluster" "cloud_asset_discovery" {
  name = "cloud_asset_discovery"

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

resource "aws_ecs_cluster_capacity_providers" "cloud_asset_discovery" {
  cluster_name = aws_ecs_cluster.cloud_asset_discovery.name

  capacity_providers = [
    "FARGATE"
  ]

  default_capacity_provider_strategy {
    capacity_provider = "FARGATE"
    weight            = 1
    base              = 0
  }

}