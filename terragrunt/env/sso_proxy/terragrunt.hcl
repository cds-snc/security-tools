locals {
  parent_vars = read_terragrunt_config("../root.hcl")
}

terraform {
  source = "../../aws//sso_proxy"
}

dependencies {
  paths = ["../base", "../cloud_asset_inventory"]
}

dependency "base" {
  config_path                             = "../base"
  mock_outputs_allowed_terraform_commands = ["init", "fmt", "validate", "plan", "show"]
  mock_outputs_merge_with_state           = true
  mock_outputs = {
    hosted_zone_id                  = "1234567890"
    hosted_zone_certificate_arn     = "arn:aws:acm:ca-central-1:123456789012:certificate/abcdefg-1234-5678-abcd-1234567890ab"
    security_tools_vpc_id           = "vpc-1234567890"
    vpc_main_nacl_id                = "acl-1234567890"
    vpc_private_subnet_cidrs        = ["10.0.0.0/24", "10.0.1.0/24"]
    vpc_public_subnet_cidrs         = ["10.0.2.0/24", "10.0.3.0/24"]
    vpc_private_subnet_ids          = ["subnet-1234567890", "subnet-0987654321"]
    vpc_public_subnet_ids           = ["subnet-1122334455", "subnet-5544332211"]
    service_discovery_namespace_arn = "arn:aws:servicediscovery:ca-central-1:123456789012:namespace/ns-1234567890"
  }

}

dependency "cloud_asset_inventory" {
  config_path = "../cloud_asset_inventory"

  mock_outputs_allowed_terraform_commands = ["init", "fmt", "validate", "plan", "show"]
  mock_outputs = {
    cloud_asset_inventory_load_balancer_dns = "my-loadbalancer-1234567890.ca-central-1.elb.amazonaws.com"
  }
}

inputs = {
  tool_name                       = "sso-proxy"
  hosted_zone_id                  = dependency.base.outputs.hosted_zone_id
  hosted_zone_certificate_arn     = dependency.base.outputs.hosted_zone_certificate_arn
  service_discovery_namespace_arn = dependency.base.outputs.service_discovery_namespace_arn
  security_tools_domain_name      = "security.cdssandbox.xyz"
  pomerium_image                  = "pomerium/pomerium"
  pomerium_image_tag              = "git-1ef21ae9@sha256:b1d0366ab16ed610c676e9d428cb21ac31c5d3ffa6362a7511a32adec8d6dae0"
  pomerium_verify_image           = "pomerium/verify"
  pomerium_verify_image_tag       = "latest@sha256:0e52cfc1a9252a9b5158a8e20d6c6a96e34994a805abbb4211a0294036f24af0"
  session_cookie_expires_in       = "8h"
  security_tools_vpc_id           = dependency.base.outputs.security_tools_vpc_id
  vpc_main_nacl_id                = dependency.base.outputs.vpc_main_nacl_id
  vpc_private_subnet_cidrs        = dependency.base.outputs.vpc_private_subnet_cidrs
  vpc_public_subnet_cidrs         = dependency.base.outputs.vpc_public_subnet_cidrs
  vpc_private_subnet_ids          = dependency.base.outputs.vpc_private_subnet_ids
  vpc_public_subnet_ids           = dependency.base.outputs.vpc_public_subnet_ids

  cloud_asset_inventory_load_balancer_dns = dependency.cloud_asset_inventory.outputs.cloud_asset_inventory_load_balancer_dns
}



include {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}