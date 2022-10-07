locals {
  dependencytrack_api_service_name = "dependencytrack_api"
}

resource "aws_ecs_service" "dependencytrack_api" {
  name                              = local.dependencytrack_api_service_name
  cluster                           = aws_ecs_cluster.software_asset_tracking.id
  task_definition                   = aws_ecs_task_definition.dependencytrack_api.arn
  desired_count                     = 1
  launch_type                       = "FARGATE"
  health_check_grace_period_seconds = 600

  load_balancer {
    target_group_arn = aws_lb_target_group.dependencytrack_api.arn
    container_name   = local.dependencytrack_api_service_name
    container_port   = 8080
  }

  network_configuration {
    security_groups = [aws_security_group.dependencytrack.id, module.dependencytrack_db.proxy_security_group_id]
    subnets         = var.vpc_private_subnet_ids
  }

  tags = {
    (var.billing_tag_key) = var.billing_tag_value
    Terraform             = true
    Product               = "${var.product_name}-${var.tool_name}"
  }
}

data "template_file" "dependencytrack_api_container_definition" {
  template = file("container-definitions/dependencytrack_api.json.tmpl")

  vars = {
    ALPINE_DATABASE_URL          = aws_ssm_parameter.dependencytrack_db_url.arn
    AWS_LOGS_GROUP               = aws_cloudwatch_log_group.dependencytrack_api.name
    AWS_LOGS_REGION              = var.region
    AWS_LOGS_STREAM_PREFIX       = "${local.dependencytrack_api_service_name}-task"
    DEPENDENCYTRACK_API_IMAGE    = "${var.dependencytrack_api_image}:${var.dependencytrack_api_image_tag}"
    DEPENDENCYTRACK_SERVICE_NAME = local.dependencytrack_api_service_name
  }
}

resource "aws_ecs_task_definition" "dependencytrack_api" {
  family                   = local.dependencytrack_api_service_name
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]

  cpu    = 4096
  memory = 16384

  execution_role_arn = aws_iam_role.dependencytrack_api_container_execution_role.arn
  task_role_arn      = aws_iam_role.dependencytrack_task_execution_role.arn

  container_definitions = data.template_file.dependencytrack_api_container_definition.rendered

  volume {
    name = local.dependencytrack_api_service_name
    efs_volume_configuration {
      file_system_id     = aws_efs_file_system.dependencytrack.id
      root_directory     = "/"
      transit_encryption = "ENABLED"

      authorization_config {
        access_point_id = aws_efs_access_point.dependencytrack.id
        iam             = "DISABLED"
      }
    }
  }

  tags = {
    (var.billing_tag_key) = var.billing_tag_value
    Terraform             = true
    Product               = "${var.product_name}-${var.tool_name}"
  }
}

resource "aws_cloudwatch_log_group" "dependencytrack_api" {
  name              = "/aws/ecs/${local.dependencytrack_api_service_name}"
  retention_in_days = 14

  tags = {
    (var.billing_tag_key) = var.billing_tag_value
    Terraform             = true
    Product               = "${var.product_name}-${var.tool_name}"
  }
}
