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
  dependencytrack_api_image_tag      = "4.6.1@sha256:54a44aab50129bcf0ae3dbeea2508870b48af132969a6929f0a75c772db7079b"
  dependencytrack_frontend_image     = "dependencytrack/frontend"
  dependencytrack_frontend_image_tag = "4.6.0@sha256:a525d909ecf6cecf4a0302a95b406e494ae155a9a148be019ab93f1d5f7c415d"
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