# ----------------------------------------------------------------#
# Sentinel Forwarder ECR Repository
# NOTE: To be enabled once we finished the refactoring of the forwarder
# ----------------------------------------------------------------#

# resource "aws_ecr_repository" "sentinel_neo4j_forwarder" {
#   name                 = "${var.product_name}/cloud_asset_inventory/sentinel_neo4j_forwarder"
#   image_tag_mutability = "MUTABLE"

#   encryption_configuration {
#     encryption_type = "KMS"
#   }

#   image_scanning_configuration {
#     scan_on_push = true
#   }

#   tags = {
#     (var.billing_tag_key) = var.billing_tag_value
#     Terraform             = true
#     Product               = var.product_name
#   }
# }


# ----------------------------------------------------------------#
# Cloud asset inventory ECR Repositories
# ----------------------------------------------------------------#

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


resource "aws_ecr_repository" "neo4j" {
  name                 = "${var.product_name}/cloud_asset_inventory/neo4j"
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

# ----------------------------------------------------------------#
# SSO Proxy ECR Repositories
# ----------------------------------------------------------------#

resource "aws_ecr_repository" "sso_proxy_pomerium" {
  name                 = "${var.product_name}/sso_proxy_pomerium"
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


resource "aws_ecr_repository" "sso_proxy_verify" {
  name                 = "${var.product_name}/sso_proxy_verify"
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
