terraform {
  source = "../../aws//cloud_asset_inventory"
}

dependencies {
  paths = ["../base"]
}

dependency "base" {
  config_path = "../base"
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
  path   = find_in_parent_folders()
  expose = true
}