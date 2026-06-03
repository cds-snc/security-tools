resource "aws_network_acl_rule" "http_egress" {
  network_acl_id = var.vpc_main_nacl_id
  rule_number    = 112
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 80
  to_port        = 80
}

resource "aws_network_acl_rule" "http_ingress" {
  network_acl_id = var.vpc_main_nacl_id
  rule_number    = 113
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 80
  to_port        = 80
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE A SECURITY GROUP TO ALLOW ACCESS TO POMERIUM SSO
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_security_group" "pomerium" {
  name        = "pomerium"
  description = "Allow inbound traffic to pomerium load balancer"
  vpc_id      = var.security_tools_vpc_id

  egress {
    description = "Access Cartography cidr"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = [var.cloud_asset_inventory_cidr]
  }

  egress {
    description = "Access to the internet"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Access to the http to https load balancer listener"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    self        = true
  }

  ingress {
    description = "Access to load balancer from the http to redirect to https"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Access to load balancer from the internet"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Access from proxy to pomerium auth"
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    self        = true
  }

  egress {
    description = "Allow API outbound connections to the proxy"
    from_port   = 8000
    to_port     = 8000
    protocol    = "TCP"
    cidr_blocks = var.vpc_private_subnet_cidrs
    self        = true
  }

  egress {
    description = "Outbound access to neo4j http"
    from_port   = 7474
    to_port     = 7474
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

  egress {
    description = "Outbound access to dependency track frontend"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = var.vpc_private_subnet_cidrs
    self        = true
  }

  egress {
    description = "Outbound access to dependency track api"
    from_port   = 8081
    to_port     = 8081
    protocol    = "tcp"
    cidr_blocks = var.vpc_private_subnet_cidrs
    self        = true
  }

  tags = {
    (var.billing_tag_key) = var.billing_tag_value
    Terraform             = true
    Product               = "${var.product_name}-${var.tool_name}"
  }
}
