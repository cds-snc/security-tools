terraform {
  source = "../../aws//software_asset_inventory"
}

dependencies {
  paths = ["../base"]
}

dependency "base" {
  config_path = "../base"

  mock_outputs_allowed_terraform_commands = ["init", "fmt", "validate", "plan", "show"]
  mock_outputs = {
    cartography_repository_url = "https://12345678910.dkr.ecr.region.amazonaws.com/foo"
  }
}

inputs = {
  product_name                       = "security-tools-software-asset-inventory"
  dependencytrack_api_image          = "dependencytrack/apiserver"
  dependencytrack_api_image_tag      = "4.4.2@sha256:584cfd2349ec93cfde2528b8f34bd5d3a9f0a393fa38806128d646743fa649ee"
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