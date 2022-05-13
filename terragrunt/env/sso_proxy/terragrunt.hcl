terraform {
  source = "../../aws//sso_proxy"
}

dependencies {
  paths = ["../base", "../cloud_asset_inventory", "../software_asset_inventory"]
}

dependency "base" {
  config_path = "../base"

  mock_outputs_allowed_terraform_commands = ["init", "fmt", "validate", "plan", "show"]
  mock_outputs = {
    cartography_repository_url = "https://12345678910.dkr.ecr.region.amazonaws.com/foo"
  }
}

dependency "cloud_asset_inventory" {
  config_path = "../cloud_asset_inventory"

  mock_outputs_allowed_terraform_commands = ["init", "fmt", "validate", "plan", "show"]
  mock_outputs = {
    cloud_asset_inventory_load_balancer_dns = "my-loadbalancer-1234567890.ca-central-1.elb.amazonaws.com"
  }
}

dependency "software_asset_inventory" {
  config_path = "../software_asset_inventory"

  mock_outputs_allowed_terraform_commands = ["init", "fmt", "validate", "plan", "show"]
  mock_outputs = {
    software_asset_inventory_load_balancer_dns = "my-loadbalancer-1234567890.ca-central-1.elb.amazonaws.com"
  }
}

inputs = {
  product_name              = "security-tools-sso-proxy"
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

  cloud_asset_inventory_load_balancer_dns    = dependency.cloud_asset_inventory.outputs.cloud_asset_inventory_load_balancer_dns
  software_asset_inventory_load_balancer_dns = dependency.software_asset_inventory.outputs.software_inventory_load_balancer_dns
}


include {
  path   = find_in_parent_folders()
  expose = true
}