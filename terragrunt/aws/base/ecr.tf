#
# ECR
#
resource "aws_ecr_repository" "cartography" {
  name                 = "${var.product_name}/cloud_asset_inventory/cartography"
  image_tag_mutability = "MUTABLE"

  encryption_configuration {
    encryption_type = "KMS"
  }

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    (var.billing_tag_key) = var.billing_tag_value
    Terraform             = true
    Product               = var.product_name
  }
}
