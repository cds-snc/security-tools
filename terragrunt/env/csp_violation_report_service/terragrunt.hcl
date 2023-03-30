terraform {
  source = "../../aws//csp_violation_report_service"
}

dependencies {
  paths = ["../base"]
}

dependency "base" {
  config_path = "../base"
}

inputs = {
  tool_name                = "csp-violation-report-service"
  security_tools_vpc_id    = dependency.base.outputs.security_tools_vpc_id
  vpc_private_subnet_cidrs = dependency.base.outputs.vpc_private_subnet_cidrs
  vpc_public_subnet_cidrs  = dependency.base.outputs.vpc_public_subnet_cidrs
  vpc_private_subnet_ids   = dependency.base.outputs.vpc_private_subnet_ids
  vpc_public_subnet_ids    = dependency.base.outputs.vpc_public_subnet_ids
}

include {
  path   = find_in_parent_folders()
  expose = true
}