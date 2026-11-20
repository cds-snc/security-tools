mock_provider "aws" {
  override_during = plan

  mock_data "aws_iam_policy_document" {
    defaults = {
      json = "{\"Version\":\"2012-10-17\",\"Statement\":[]}"
    }
  }

  mock_resource "aws_lb" {
    defaults = {
      arn = "arn:aws:elasticloadbalancing:ca-central-1:123456789012:loadbalancer/app/test/1234567890123456"
    }
  }

  mock_resource "aws_lb_listener" {
    defaults = {
      arn = "arn:aws:elasticloadbalancing:ca-central-1:123456789012:listener/app/test/1234567890123456/1234567890123456"
    }
  }

  mock_resource "aws_lb_target_group" {
    defaults = {
      arn = "arn:aws:elasticloadbalancing:ca-central-1:123456789012:targetgroup/test/1234567890123456"
    }
  }

  mock_resource "aws_ssm_parameter" {
    defaults = {
      arn = "arn:aws:ssm:ca-central-1:123456789012:parameter/test"
    }
  }

  mock_resource "aws_security_group" {
    defaults = {
      id = "sg-12345678"
    }
  }
}

override_resource {
  target          = aws_lb_target_group.oauth2_proxy["neo4j"]
  override_during = plan
  values = {
    arn = "arn:aws:elasticloadbalancing:ca-central-1:123456789012:targetgroup/neo4j/1234567890123456"
  }
}

override_resource {
  target          = aws_lb_target_group.oauth2_proxy["bolt"]
  override_during = plan
  values = {
    arn = "arn:aws:elasticloadbalancing:ca-central-1:123456789012:targetgroup/bolt/2345678901234567"
  }
}

override_resource {
  target          = aws_ssm_parameter.oauth2_proxy_cookie_secret
  override_during = plan
  values = {
    arn = "arn:aws:ssm:ca-central-1:123456789012:parameter/cookie"
  }
}

override_resource {
  target          = aws_security_group.pomerium
  override_during = plan
  values = {
    id = "sg-23456789"
  }
}

variables {
  account_id                      = "123456789012"
  billing_tag_key                 = "CostCentre"
  billing_tag_value               = "test"
  cbs_satellite_bucket_name       = "test-satellite"
  cloud_asset_inventory_cidr      = "10.0.8.0/22"
  domain_name                     = "security.example.com"
  internal_domain_name            = "internal.example.com"
  product_name                    = "security-tools"
  tool_name                       = "sso-proxy"
  sso_proxy_cidr                  = "10.0.0.0/21"
  hosted_zone_id                  = "Z1234567890"
  hosted_zone_certificate_arn     = "arn:aws:acm:ca-central-1:123456789012:certificate/12345678-1234-1234-1234-123456789012"
  service_discovery_namespace_arn = "arn:aws:servicediscovery:ca-central-1:123456789012:namespace/ns-test"
  security_tools_vpc_id           = "vpc-12345678"
  security_tools_domain_name      = "security.example.com"
  oauth2_proxy_image              = "123456789012.dkr.ecr.ca-central-1.amazonaws.com/security-tools/sso_proxy_pomerium"
  oauth2_proxy_image_digest       = "sha256:c3415e8660af553f5e18f5d90db050614c02493c0ac6260ac59442f6d9b12048"
  google_client_id                = "test-client"
  google_client_secret            = "test-client-secret"
  oauth2_proxy_cookie_secret      = "MDEyMzQ1Njc4OWFiY2RlZjAxMjM0NTY3ODlhYmNkZWY="
  session_cookie_expires_in       = "8h"
  vpc_main_nacl_id                = "acl-12345678"
  vpc_private_subnet_cidrs        = ["10.0.0.0/24", "10.0.1.0/24"]
  vpc_public_subnet_cidrs         = ["10.0.2.0/24", "10.0.3.0/24"]
  vpc_private_subnet_ids          = ["subnet-12345678", "subnet-23456789"]
  vpc_public_subnet_ids           = ["subnet-34567890", "subnet-45678901"]
}

run "protected_routes" {
  command = plan

  assert {
    condition = alltrue([
      for container in jsondecode(aws_ecs_task_definition.oauth2_proxy.container_definitions) :
      container.image == "${var.oauth2_proxy_image}@${var.oauth2_proxy_image_digest}"
    ])
    error_message = "Every deployed proxy container must reference the mirrored image by digest, never by tag."
  }

  assert {
    condition = alltrue([
      for container in local.oauth2_proxy_container_definitions :
      contains(container.command, "--email-domain=cds-snc.ca") &&
      contains(container.command, "--redirect-url=https://auth.security.example.com/oauth2/callback") &&
      contains(container.command, "--cookie-domain=security.example.com") &&
      contains(container.command, "--pass-basic-auth=false") &&
      contains(container.command, "--pass-authorization-header=false") &&
      contains(container.command, "--proxy-websockets=true")
    ])
    error_message = "Both routes must share authentication settings without replacing Neo4j credentials."
  }

  assert {
    condition = alltrue([
      for container in local.oauth2_proxy_container_definitions :
      [for secret in container.secrets : secret.valueFrom if secret.name == "OAUTH2_PROXY_COOKIE_SECRET"] == [aws_ssm_parameter.oauth2_proxy_cookie_secret.arn]
    ])
    error_message = "Both containers must load the same cookie secret from SSM."
  }

  assert {
    condition = alltrue([
      for route, config in local.oauth2_proxy_routes :
      one([for container in local.oauth2_proxy_container_definitions : container if container.name == "oauth2_proxy_${route}"]).portMappings[0].containerPort == aws_lb_target_group.oauth2_proxy[route].port &&
      contains(one([for container in local.oauth2_proxy_container_definitions : container if container.name == "oauth2_proxy_${route}"]).command, "--upstream=${config.upstream}")
    ])
    error_message = "Each target group must select the proxy port serving its intended upstream."
  }

  assert {
    condition = (
      one(aws_lb_listener_rule.neo4j.action).target_group_arn == aws_lb_target_group.oauth2_proxy["neo4j"].arn &&
      one(aws_lb_listener_rule.bolt.action).target_group_arn == aws_lb_target_group.oauth2_proxy["bolt"].arn &&
      one(aws_lb_listener_rule.auth.action).target_group_arn == aws_lb_target_group.oauth2_proxy["neo4j"].arn &&
      one(aws_lb_listener.https.default_action).type == "fixed-response" &&
      one(one(aws_lb_listener.https.default_action).fixed_response).status_code == "404"
    )
    error_message = "ALB rules must route known hosts through authentication and reject other hosts."
  }

  assert {
    condition = (
      length([for condition in aws_lb_listener_rule.auth.condition : condition if length(condition.path_pattern) > 0]) == 1 &&
      contains(one([for condition in aws_lb_listener_rule.auth.condition : one(condition.path_pattern).values if length(condition.path_pattern) > 0]), "/oauth2/callback") &&
      !contains(one([for condition in aws_lb_listener_rule.auth.condition : one(condition.path_pattern).values if length(condition.path_pattern) > 0]), "/oauth2/*")
    )
    error_message = "The authentication host must expose explicit OAuth endpoints, not an upstream catch-all."
  }

  assert {
    condition = (
      contains(one([for container in local.oauth2_proxy_container_definitions : container if container.name == "oauth2_proxy_bolt"]).command, "--api-route=^/") &&
      !contains(one([for container in local.oauth2_proxy_container_definitions : container if container.name == "oauth2_proxy_neo4j"]).command, "--api-route=^/")
    )
    error_message = "Unauthenticated Bolt requests must fail instead of redirecting a WebSocket to Google."
  }

  assert {
    condition = (
      aws_security_group_rule.oauth2_proxy_ingress.source_security_group_id == aws_security_group.pomerium.id &&
      aws_security_group_rule.oauth2_proxy_ingress.from_port == min([for config in local.oauth2_proxy_routes : config.port]...) &&
      aws_security_group_rule.oauth2_proxy_ingress.to_port == max([for config in local.oauth2_proxy_routes : config.port]...)
    )
    error_message = "Only the ALB security group may reach the proxy listener ports."
  }
}

run "reject_invalid_cookie_secret" {
  command = plan
  variables {
    oauth2_proxy_cookie_secret = "invalid"
  }
  expect_failures = [var.oauth2_proxy_cookie_secret]
}

run "reject_image_tag" {
  command = plan
  variables {
    oauth2_proxy_image_digest = "v7.15.6"
  }
  expect_failures = [var.oauth2_proxy_image_digest]
}
