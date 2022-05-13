resource "aws_security_group" "cartography" {
  #checkov:skip=CKV2_AWS_5:This security group is used by the Cartography ECS tasks.
  name        = "cartography"
  description = "Allow inbound traffic to cartography load balancer"
  vpc_id      = var.security_tools_vpc_id

  ingress {
    description = "Allow EFS traffic out from ECS to mount target"
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = var.vpc_private_subnet_cidrs
  }

  egress {
    description = "Allow EFS traffic into mount target from ECS"
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = var.vpc_private_subnet_cidrs
  }

  egress {
    description = "Outbound access to internet & elasticsearch"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Access to services running on https"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = concat(var.vpc_private_subnet_cidrs, var.vpc_public_subnet_cidrs)
  }

  egress {
    description = "Outbound access to neo4j http"
    from_port   = 7474
    to_port     = 7474
    protocol    = "tcp"
    cidr_blocks = var.vpc_private_subnet_cidrs
    self        = true
  }

  ingress {
    description = "Inbound access to neo4j http"
    from_port   = 7474
    to_port     = 7474
    protocol    = "tcp"
    cidr_blocks = var.vpc_private_subnet_cidrs
    self        = true
  }

  ingress {
    description = "Access to neo4j https"
    from_port   = 7473
    to_port     = 7473
    protocol    = "tcp"
    cidr_blocks = var.vpc_private_subnet_cidrs
    self        = true
  }

  egress {
    description = "Outbound access to neo4j bolt"
    from_port   = 7687
    to_port     = 7687
    protocol    = "tcp"
    cidr_blocks = var.vpc_private_subnet_cidrs
    self        = true
  }

  ingress {
    description = "Inbound access to neo4j bolt"
    from_port   = 7687
    to_port     = 7687
    protocol    = "tcp"
    cidr_blocks = var.vpc_private_subnet_cidrs
    self        = true
  }

  tags = {
    (var.billing_tag_key) = var.billing_tag_value
    Terraform             = true
    Product               = var.product_name
  }
}
