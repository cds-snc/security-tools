locals {
  parent_vars = read_terragrunt_config("../root.hcl")
}

terraform {
  source = "../../aws//sso_proxy"
}

dependencies {
  paths = ["../base", "../cloud_asset_inventory", "../csp_violation_report_service"]
}

dependency "base" {
  config_path                             = "../base"
  mock_outputs_allowed_terraform_commands = ["init", "fmt", "validate", "plan", "show"]
  mock_outputs_merge_with_state           = true
  mock_outputs = {
    hosted_zone_id           = "1234567890"
    security_tools_vpc_id    = "vpc-1234567890"
    vpc_main_nacl_id         = "acl-1234567890"
    vpc_private_subnet_cidrs = ["10.0.0.0/24", "10.0.1.0/24"]
    vpc_public_subnet_cidrs  = ["10.0.2.0/24", "10.0.3.0/24"]
    vpc_private_subnet_ids   = ["subnet-1234567890", "subnet-0987654321"]
    vpc_public_subnet_ids    = ["subnet-1122334455", "subnet-5544332211"]
  }

}

dependency "cloud_asset_inventory" {
  config_path = "../cloud_asset_inventory"

  mock_outputs_allowed_terraform_commands = ["init", "fmt", "validate", "plan", "show"]
  mock_outputs = {
    cloud_asset_inventory_load_balancer_dns = "my-loadbalancer-1234567890.ca-central-1.elb.amazonaws.com"
  }
}

dependency "csp_violation_report_service" {
  config_path = "../csp_violation_report_service"

  mock_outputs_allowed_terraform_commands = ["init", "fmt", "validate", "plan", "show"]
  mock_outputs = {
    csp_violation_report_service_load_balancer_dns = "my-loadbalancer-1234567890.ca-central-1.elb.amazonaws.com"
  }
}

inputs = {
  tool_name                 = "sso-proxy"
  pomerium_image            = "pomerium/pomerium"
  pomerium_image_tag        = "git-74310b3d"
  pomerium_verify_image     = "pomerium/verify"
  pomerium_verify_image_tag = "sha-6b38dd5"
  session_cookie_expires_in = "8h"
  security_tools_vpc_id     = dependency.base.outputs.security_tools_vpc_id
  vpc_main_nacl_id          = dependency.base.outputs.vpc_main_nacl_id
  vpc_private_subnet_cidrs  = dependency.base.outputs.vpc_private_subnet_cidrs
  vpc_public_subnet_cidrs   = dependency.base.outputs.vpc_public_subnet_cidrs
  vpc_private_subnet_ids    = dependency.base.outputs.vpc_private_subnet_ids
  vpc_public_subnet_ids     = dependency.base.outputs.vpc_public_subnet_ids

  cloud_asset_inventory_load_balancer_dns = dependency.cloud_asset_inventory.outputs.cloud_asset_inventory_load_balancer_dns
}



include {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}