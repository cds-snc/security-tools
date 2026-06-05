locals {
  pomerium_sso_proxy_service_name = "pomerium_sso_proxy"
}

resource "aws_ecs_service" "pomerium_sso_proxy" {
  name                              = local.pomerium_sso_proxy_service_name
  cluster                           = aws_ecs_cluster.sso_proxy.id
  task_definition                   = aws_ecs_task_definition.pomerium_sso_proxy.arn
  desired_count                     = 1
  launch_type                       = "FARGATE"
  health_check_grace_period_seconds = 600

  # The databroker EFS volume is single-writer; the old task must stop before the new one starts.
  deployment_minimum_healthy_percent = 0
  deployment_maximum_percent         = 100

  load_balancer {
    target_group_arn = aws_lb_target_group.sso_proxy.arn
    container_name   = "pomerium_sso_proxy"
    container_port   = 443
  }

  network_configuration {
    security_groups = [aws_security_group.pomerium.id]
    subnets         = var.vpc_private_subnet_ids
  }

  service_connect_configuration {
    enabled   = true
    namespace = var.service_discovery_namespace_arn
  }

  tags = {
    (var.billing_tag_key) = var.billing_tag_value
    Terraform             = true
    Product               = "${var.product_name}-${var.tool_name}"
  }
}

data "template_file" "pomerium_sso_proxy_routes_policy" {
  template = file("configs/routes.yml.tmpl")
}

data "template_file" "pomerium_sso_proxy_container_definition" {
  template = file("container-definitions/pomerium_sso_proxy.json.tmpl")

  vars = {
    AUTHENTICATE_SERVICE_URL      = "https://auth.${var.security_tools_domain_name}"
    AWS_LOGS_GROUP                = aws_cloudwatch_log_group.pomerium_sso_proxy.name
    AWS_LOGS_REGION               = var.region
    AWS_LOGS_STREAM_PREFIX        = "${local.pomerium_sso_proxy_service_name}-task"
    COOKIE_DOMAIN                 = var.security_tools_domain_name
    COOKIE_EXPIRE                 = var.session_cookie_expires_in
    DATABROKER_STORAGE_TYPE       = "file"
    DATABROKER_STORAGE_CONNECTION = "file://${local.databroker_mount_path}"
    DATABROKER_MOUNT_PATH         = local.databroker_mount_path
    DATABROKER_VOLUME_NAME        = local.databroker_efs_volume_name
    ROUTES_FILE                   = base64encode(data.template_file.pomerium_sso_proxy_routes_policy.rendered)
    SESSION_KEY                   = aws_ssm_parameter.session_key.arn
    SESSION_COOKIE_SECRET         = aws_ssm_parameter.session_cookie_secret.arn
    POMERIUM_GOOGLE_CLIENT_ID     = aws_ssm_parameter.pomerium_google_client_id.arn
    POMERIUM_GOOGLE_CLIENT_SECRET = aws_ssm_parameter.pomerium_google_client_secret.arn
    POMERIUM_IMAGE                = "${var.pomerium_image}:${var.pomerium_image_tag}"
  }
}

resource "aws_ecs_task_definition" "pomerium_sso_proxy" {
  family                   = local.pomerium_sso_proxy_service_name
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]

  cpu    = 2048
  memory = 4096

  execution_role_arn = aws_iam_role.pomerium_container_execution_role.arn
  task_role_arn      = aws_iam_role.pomerium_task_execution_role.arn

  container_definitions = data.template_file.pomerium_sso_proxy_container_definition.rendered

  volume {
    name = local.databroker_efs_volume_name
    efs_volume_configuration {
      file_system_id          = aws_efs_file_system.databroker.id
      transit_encryption      = "ENABLED"
      transit_encryption_port = 3049
      authorization_config {
        access_point_id = aws_efs_access_point.databroker.id
      }
    }
  }

  tags = {
    (var.billing_tag_key) = var.billing_tag_value
    Terraform             = true
    Product               = "${var.product_name}-${var.tool_name}"
  }
}

resource "aws_cloudwatch_log_group" "pomerium_sso_proxy" {
  name              = "/aws/ecs/${local.pomerium_sso_proxy_service_name}"
  retention_in_days = 14

  tags = {
    (var.billing_tag_key) = var.billing_tag_value
    Terraform             = true
    Product               = "${var.product_name}-${var.tool_name}"
  }
}
