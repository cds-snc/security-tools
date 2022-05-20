terraform {
  source = "../../aws//software_asset_inventory"
}

dependencies {
  paths = ["../base"]
}

dependency "base" {
  config_path = "../base"
}

inputs = {
  tool_name                          = "software-asset-inventory"
  dependencytrack_api_image          = "dependencytrack/apiserver"
  dependencytrack_api_image_tag      = "4.5.0@sha256:9365f306ac54eaf1216ad8f2846062b3fe538399d8fb10a11e82be20c8c8e797"
  dependencytrack_frontend_image     = "dependencytrack/frontend"
  dependencytrack_frontend_image_tag = "4.4.0@sha256:e0b6790c19cba4470468a5cbd8eaaf80c8b9cd4c3c9be5b993032fbec5ed0daa"
  security_tools_vpc_id              = dependency.base.outputs.security_tools_vpc_id
  vpc_private_subnet_cidrs           = dependency.base.outputs.vpc_private_subnet_cidrs
  vpc_public_subnet_cidrs            = dependency.base.outputs.vpc_public_subnet_cidrs
  vpc_private_subnet_ids             = dependency.base.outputs.vpc_private_subnet_ids
  vpc_public_subnet_ids              = dependency.base.outputs.vpc_public_subnet_ids
}

include {
  path   = find_in_parent_folders()
  expose = true
}