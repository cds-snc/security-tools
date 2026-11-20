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
# SSO PROXY LOAD BALANCER SECURITY GROUP
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_security_group" "sso_proxy" {
  name        = "sso-proxy"
  description = "Allow inbound traffic to the SSO proxy load balancer"
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
    description     = "Access to oauth2-proxy listeners"
    from_port       = 4180
    to_port         = 4181
    protocol        = "tcp"
    security_groups = [aws_security_group.oauth2_proxy.id]
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

resource "aws_security_group" "oauth2_proxy" {
  name        = "oauth2-proxy"
  description = "Private oauth2-proxy tasks, reachable only through the SSO ALB"
  vpc_id      = var.security_tools_vpc_id

  tags = {
    (var.billing_tag_key) = var.billing_tag_value
    Terraform             = true
    Product               = "${var.product_name}-${var.tool_name}"
  }
}

resource "aws_security_group_rule" "oauth2_proxy_ingress" {
  type                     = "ingress"
  description              = "SSO ALB to oauth2-proxy"
  security_group_id        = aws_security_group.oauth2_proxy.id
  source_security_group_id = aws_security_group.sso_proxy.id
  from_port                = 4180
  to_port                  = 4181
  protocol                 = "tcp"
}

resource "aws_security_group_rule" "oauth2_proxy_https_egress" {
  type              = "egress"
  description       = "Google authentication and AWS endpoints"
  security_group_id = aws_security_group.oauth2_proxy.id
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
}

resource "aws_security_group_rule" "oauth2_proxy_neo4j_egress" {
  for_each = toset(["7474", "7687"])

  type              = "egress"
  description       = "Internal Neo4j upstream"
  security_group_id = aws_security_group.oauth2_proxy.id
  cidr_blocks       = var.vpc_private_subnet_cidrs
  from_port         = tonumber(each.value)
  to_port           = tonumber(each.value)
  protocol          = "tcp"
}
