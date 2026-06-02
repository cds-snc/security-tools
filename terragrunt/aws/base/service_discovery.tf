# Shared by all security services (sso_proxy, cloud_asset_inventory, etc.)
resource "aws_service_discovery_http_namespace" "internal_mesh" {
  name = "internal.mesh"

  tags = {
    (var.billing_tag_key) = var.billing_tag_value
    Terraform             = true
    Product               = "${var.product_name}-${var.tool_name}"
  }
}
