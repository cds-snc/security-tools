resource "aws_security_group" "dependencytrack" {
  name        = "dependencytrack"
  description = "Allow inbound traffic to dependencytrack load balancer"
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
    description = "Access to RDS Postgresql"
    from_port   = 5432
    to_port     = 5432
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
    description = "Outbound access to dependency track api"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = var.vpc_private_subnet_cidrs
    self        = true
  }

  ingress {
    description = "Inbound access to dependency track api"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = concat(var.vpc_private_subnet_cidrs, var.vpc_public_subnet_cidrs)
    self        = true
  }

  egress {
    description = "Outbound access to dependency track frontend"
    from_port   = 8081
    to_port     = 8081
    protocol    = "tcp"
    cidr_blocks = var.vpc_private_subnet_cidrs
    self        = true
  }

  ingress {
    description = "Access to dependency track frontend"
    from_port   = 8081
    to_port     = 8081
    protocol    = "tcp"
    cidr_blocks = concat(var.vpc_private_subnet_cidrs, var.vpc_public_subnet_cidrs)
    self        = true
  }

  tags = {
    (var.billing_tag_key) = var.billing_tag_value
    Terraform             = true
    Product               = "${var.product_name}-${var.tool_name}"
  }
}
