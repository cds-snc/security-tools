locals {
  oauth2_proxy_service_name = "oauth2_proxy"
  oauth2_proxy_routes = {
    neo4j = {
      port     = 4180
      upstream = "http://neo4j-ui.internal.mesh:7474/"
    }
    bolt = {
      port     = 4181
      upstream = "http://neo4j-bolt.internal.mesh:7687/"
    }
  }

  oauth2_proxy_common_args = [
    "--provider=google",
    "--email-domain=cds-snc.ca",
    "--redirect-url=https://auth.${var.security_tools_domain_name}/oauth2/callback",
    "--whitelist-domain=neo4j.${var.security_tools_domain_name}",
    "--whitelist-domain=bolt.${var.security_tools_domain_name}",
    "--cookie-name=__Secure-security_tools_oauth2",
    "--cookie-domain=${var.security_tools_domain_name}",
    "--cookie-path=/",
    "--cookie-expire=${var.session_cookie_expires_in}",
    "--cookie-refresh=1h",
    "--cookie-secure=true",
    "--cookie-httponly=true",
    "--cookie-samesite=lax",
    "--cookie-csrf-per-request=true",
    "--cookie-csrf-per-request-limit=5",
    "--reverse-proxy=true",
    "--real-client-ip-header=X-Forwarded-For",
    "--pass-host-header=true",
    "--proxy-websockets=true",
    "--skip-auth-preflight=true",
    # Preserve Neo4j's own Authorization header; do not inject Google tokens.
    "--pass-basic-auth=false",
    "--pass-access-token=false",
    "--pass-authorization-header=false",
    "--silence-ping-logging=true",
  ]

  oauth2_proxy_container_definitions = [
    for route, config in local.oauth2_proxy_routes : {
      name      = "oauth2_proxy_${route}"
      essential = true
      image     = "${var.oauth2_proxy_image}@${var.oauth2_proxy_image_digest}"
      command = concat(
        local.oauth2_proxy_common_args,
        [for cidr in var.vpc_public_subnet_cidrs : "--trusted-proxy-ip=${cidr}"],
        [
          "--http-address=0.0.0.0:${config.port}",
          "--upstream=${config.upstream}",
        ],
        route == "bolt" ? ["--api-route=^/"] : [],
      )
      portMappings = [{
        containerPort = config.port
        hostPort      = config.port
        protocol      = "tcp"
      }]
      secrets = [
        {
          name      = "OAUTH2_PROXY_CLIENT_ID"
          valueFrom = aws_ssm_parameter.google_client_id.arn
        },
        {
          name      = "OAUTH2_PROXY_CLIENT_SECRET"
          valueFrom = aws_ssm_parameter.google_client_secret.arn
        },
        {
          name      = "OAUTH2_PROXY_COOKIE_SECRET"
          valueFrom = aws_ssm_parameter.oauth2_proxy_cookie_secret.arn
        },
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.oauth2_proxy.name
          awslogs-region        = var.region
          awslogs-stream-prefix = route
        }
      }
    }
  ]
}

resource "aws_ecs_service" "oauth2_proxy" {
  name                              = local.oauth2_proxy_service_name
  cluster                           = aws_ecs_cluster.sso_proxy.id
  task_definition                   = aws_ecs_task_definition.oauth2_proxy.arn
  desired_count                     = 1
  launch_type                       = "FARGATE"
  health_check_grace_period_seconds = 60

  dynamic "load_balancer" {
    for_each = local.oauth2_proxy_routes
    content {
      target_group_arn = aws_lb_target_group.oauth2_proxy[load_balancer.key].arn
      container_name   = "oauth2_proxy_${load_balancer.key}"
      container_port   = load_balancer.value.port
    }
  }

  network_configuration {
    security_groups = [aws_security_group.oauth2_proxy.id]
    subnets         = var.vpc_private_subnet_ids
  }

  service_connect_configuration {
    enabled   = true
    namespace = var.service_discovery_namespace_arn
  }

  depends_on = [
    aws_lb_listener_rule.neo4j,
    aws_lb_listener_rule.bolt,
    aws_lb_listener_rule.auth,
  ]

  tags = {
    (var.billing_tag_key) = var.billing_tag_value
    Terraform             = true
    Product               = "${var.product_name}-${var.tool_name}"
  }
}

resource "aws_ecs_task_definition" "oauth2_proxy" {
  family                   = local.oauth2_proxy_service_name
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]

  cpu    = 2048
  memory = 4096

  execution_role_arn = aws_iam_role.sso_proxy_container_execution_role.arn
  task_role_arn      = aws_iam_role.sso_proxy_task_execution_role.arn

  container_definitions = jsonencode(local.oauth2_proxy_container_definitions)

  tags = {
    (var.billing_tag_key) = var.billing_tag_value
    Terraform             = true
    Product               = "${var.product_name}-${var.tool_name}"
  }
}

resource "aws_cloudwatch_log_group" "oauth2_proxy" {
  name              = "/aws/ecs/${local.oauth2_proxy_service_name}"
  retention_in_days = 14

  tags = {
    (var.billing_tag_key) = var.billing_tag_value
    Terraform             = true
    Product               = "${var.product_name}-${var.tool_name}"
  }
}
