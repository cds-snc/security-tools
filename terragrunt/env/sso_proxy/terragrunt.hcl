terraform {
  source = "../../aws//sso_proxy"
}

dependencies {
  paths = ["../base", "../cloud_asset_inventory", "../csp_violation_report_service"]
}

dependency "base" {
  config_path = "../base"
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

  csp_violation_report_service_load_balancer_dns = dependency.csp_violation_report_service.outputs.csp_violation_report_service_load_balancer_dns
}



include {
  path   = find_in_parent_folders()
  expose = true
}