locals {
  dependencytrack_frontend_service_name = "dependencytrack_frontend"
}

resource "aws_ecs_service" "dependencytrack_frontend" {
  name                              = local.dependencytrack_frontend_service_name
  cluster                           = aws_ecs_cluster.software_asset_tracking.id
  task_definition                   = aws_ecs_task_definition.dependencytrack_frontend.arn
  desired_count                     = 1
  launch_type                       = "FARGATE"
  health_check_grace_period_seconds = 600

  load_balancer {
    target_group_arn = aws_lb_target_group.dependencytrack_frontend.arn
    container_name   = local.dependencytrack_frontend_service_name
    container_port   = 8080
  }

  network_configuration {
    security_groups  = [aws_security_group.dependencytrack.id, module.dependencytrack_db.proxy_security_group_id]
    subnets          = var.vpc_private_subnet_ids
    assign_public_ip = true
  }

  tags = {
    (var.billing_tag_key) = var.billing_tag_value
    Terraform             = true
    Product               = var.product_name
  }
}

data "template_file" "dependencytrack_frontend_container_definition" {
  template = file("container-definitions/dependencytrack_frontend.json.tmpl")

  vars = {
    AWS_LOGS_GROUP                        = aws_cloudwatch_log_group.dependencytrack_frontend.name
    AWS_LOGS_REGION                       = var.region
    AWS_LOGS_STREAM_PREFIX                = "${local.dependencytrack_frontend_service_name}-task"
    DEPENDENCYTRACK_FRONTEND_IMAGE        = "${var.dependencytrack_frontend_image}:${var.dependencytrack_frontend_image_tag}"
    DEPENDENCYTRACK_FRONTEND_SERVICE_NAME = local.dependencytrack_frontend_service_name
  }
}

resource "aws_ecs_task_definition" "dependencytrack_frontend" {
  family                   = local.dependencytrack_frontend_service_name
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]

  cpu    = 2048
  memory = 4096

  execution_role_arn = aws_iam_role.dependencytrack_frontend_container_execution_role.arn
  task_role_arn      = aws_iam_role.dependencytrack_task_execution_role.arn

  container_definitions = data.template_file.dependencytrack_frontend_container_definition.rendered

  tags = {
    (var.billing_tag_key) = var.billing_tag_value
    Terraform             = true
    Product               = var.product_name
  }
}

resource "aws_cloudwatch_log_group" "dependencytrack_frontend" {
  name              = "/aws/ecs/${local.dependencytrack_frontend_service_name}"
  retention_in_days = 14

  tags = {
    (var.billing_tag_key) = var.billing_tag_value
    Terraform             = true
    Product               = var.product_name
  }
}
