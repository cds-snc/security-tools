locals {
  parent_vars = read_terragrunt_config("../root.hcl")
}

terraform {
  source = "../../aws//sso_proxy"
}

dependencies {
  paths = ["../base"]
}

dependency "base" {
  config_path                             = "../base"
  mock_outputs_allowed_terraform_commands = ["init", "fmt", "validate", "plan", "show"]
  mock_outputs_merge_with_state           = true
  mock_outputs = {
    hosted_zone_id                         = "1234567890"
    hosted_zone_certificate_arn            = "arn:aws:acm:ca-central-1:123456789012:certificate/abcdefg-1234-5678-abcd-1234567890ab"
    security_tools_vpc_id                  = "vpc-1234567890"
    vpc_main_nacl_id                       = "acl-1234567890"
    vpc_private_subnet_cidrs               = ["10.0.0.0/24", "10.0.1.0/24"]
    vpc_public_subnet_cidrs                = ["10.0.2.0/24", "10.0.3.0/24"]
    vpc_private_subnet_ids                 = ["subnet-1234567890", "subnet-0987654321"]
    vpc_public_subnet_ids                  = ["subnet-1122334455", "subnet-5544332211"]
    service_discovery_namespace_arn        = "arn:aws:servicediscovery:ca-central-1:123456789012:namespace/ns-1234567890"
    pomerium_sso_proxy_repository_url      = "123456789.012.dkr.ecr.ca-central-1.amazonaws.com/pomerium-sso-proxy"
    pomerium_sso_proxy_auth_repository_url = "123456789.012.dkr.ecr.ca-central-1.amazonaws.com/pomerium-sso-proxy-auth"
  }

}

inputs = {
  tool_name                       = "sso-proxy"
  hosted_zone_id                  = dependency.base.outputs.hosted_zone_id
  hosted_zone_certificate_arn     = dependency.base.outputs.hosted_zone_certificate_arn
  service_discovery_namespace_arn = dependency.base.outputs.service_discovery_namespace_arn
  security_tools_domain_name      = "security.cdssandbox.xyz"
  pomerium_image                  = dependency.base.outputs.pomerium_sso_proxy_repository_url
  pomerium_image_tag              = "latest"
  pomerium_verify_image           = dependency.base.outputs.pomerium_sso_proxy_auth_repository_url
  pomerium_verify_image_tag       = "latest"
  session_cookie_expires_in       = "8h"
  security_tools_vpc_id           = dependency.base.outputs.security_tools_vpc_id
  vpc_main_nacl_id                = dependency.base.outputs.vpc_main_nacl_id
  vpc_private_subnet_cidrs        = dependency.base.outputs.vpc_private_subnet_cidrs
  vpc_public_subnet_cidrs         = dependency.base.outputs.vpc_public_subnet_cidrs
  vpc_private_subnet_ids          = dependency.base.outputs.vpc_private_subnet_ids
  vpc_public_subnet_ids           = dependency.base.outputs.vpc_public_subnet_ids

}



include {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}