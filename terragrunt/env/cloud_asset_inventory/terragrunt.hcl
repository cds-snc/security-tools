locals {
  parent_vars = read_terragrunt_config("../root.hcl")
}

terraform {
  source = "../../aws//cloud_asset_inventory"
}

dependencies {
  paths = ["../base"]
}

dependency "base" {
  config_path                             = "../base"
  mock_outputs_allowed_terraform_commands = ["init", "fmt", "validate", "plan", "show"]
  mock_outputs_merge_with_state           = true
  mock_outputs = {
    hosted_zone_id           = "1234567890"
    security_tools_vpc_id    = "vpc-1234567890"
    vpc_private_subnet_cidrs = ["10.0.0.0/24", "10.0.1.0/24"]
    vpc_public_subnet_cidrs  = ["10.0.2.0/24", "10.0.3.0/24"]
    vpc_private_subnet_ids   = ["subnet-1234567890", "subnet-0987654321"]
    vpc_public_subnet_ids    = ["subnet-1122334455", "subnet-5544332211"]
  }
}

inputs = {
  tool_name                                       = "cloud-asset-inventory"
  asset_inventory_managed_accounts                = split("\n", chomp(replace(file("configs/accounts.txt"), "\"", "")))
  neo4j_image                                     = "neo4j"
  neo4j_image_tag                                 = "4.4.10@sha256:8e3dabe4b3d21c3ffa94dac6750c748b29f93b38d24182c3609ee0cbf293d4cf"
  cloud_asset_inventory_vpc_peering_connection_id = "pcx-0771c54d393000439"
  security_tools_vpc_id                           = dependency.base.outputs.security_tools_vpc_id
  vpc_private_subnet_cidrs                        = dependency.base.outputs.vpc_private_subnet_cidrs
  vpc_public_subnet_cidrs                         = dependency.base.outputs.vpc_public_subnet_cidrs
  vpc_private_subnet_ids                          = dependency.base.outputs.vpc_private_subnet_ids
  vpc_public_subnet_ids                           = dependency.base.outputs.vpc_public_subnet_ids
}

include {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}