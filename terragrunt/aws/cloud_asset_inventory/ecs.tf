resource "aws_ecs_cluster" "cloud_asset_discovery" {
  name = "cloud_asset_discovery"

  # capacity_providers = ["FARGATE"]

  # default_capacity_provider_strategy {
  #   capacity_provider = "FARGATE"
  # }

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


module "neo4j" {
  source = "github.com/cds-snc/terraform-modules//ecs?ref=v11.3.0"

  name               = "neo4j"
  cluster_arn        = aws_ecs_cluster.cloud_asset_discovery.arn
  container_image    = "neo4j:5-community@sha256:0b5d3ab6ec1b866890dbfb53bf4fe1cf039f9e03c96165599a403005b7e7bcc3"
  container_port     = 7474
  desired_count      = 1
  cpu                = 1024
  memory             = 2048
  assign_public_ip   = false
  subnet_ids         = var.private_subnets
  security_group_ids = [aws_security_group.ecs_service.id]
  load_balancer = {
    target_group_arn = aws_lb_target_group.neo4j.arn
    container_port   = 7474
  }
  environment = [
    { name = "NEO4J_AUTH", value = "neo4j/${var.neo4j_password}" }
  ]
  mount_points = [
    {
      sourceVolume  = "neo4j-data"
      containerPath = "/data"
    }
  ]
  volumes = [
    {
      name = "neo4j-data"
      efs_volume_configuration = {
        file_system_id = aws_efs_file_system.neo4j.id
        root_directory = "/"
      }
    }
  ]
  log_group_name = "/ecs/neo4j"
}

module "cartography" {
  source = "github.com/cds-snc/terraform-modules//ecs?ref=v11.3.0"

  name               = "cartography"
  cluster_arn        = aws_ecs_cluster.cloud_asset_discovery.arn
  container_image    = "ghcr.io/cartography-cncf/cartography:0.136@sha256:bf34b2ca0aac8831c4fa859f51be3c26f2364e09d831ce8ed00ae42ff141e7c4"
  container_port     = 8080 # Not exposed, but required by module
  desired_count      = 1
  cpu                = 1024
  memory             = 2048
  assign_public_ip   = false
  subnet_ids         = var.private_subnets
  security_group_ids = [aws_security_group.ecs_service.id]
  environment = [
    { name = "NEO4J_URI", value = "bolt://neo4j:7687" },
    { name = "NEO4J_USER", value = "neo4j" },
    { name = "NEO4J_PASSWORD", value = var.neo4j_password }
    # Add AWS config env vars as needed
  ]
  command = [
    "--neo4j-uri", "bolt://neo4j:7687",
    "--neo4j-user", "neo4j",
    "--neo4j-password", var.neo4j_password,
    "--aws-sync-all-profiles",
    "--aws-organization-account-ids", var.hub_account_id
  ]
  log_group_name = "/ecs/cartography"
}