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
    hosted_zone_id                  = "1234567890"
    security_tools_vpc_id           = "vpc-1234567890"
    vpc_private_subnet_cidrs        = ["10.0.0.0/24", "10.0.1.0/24"]
    vpc_public_subnet_cidrs         = ["10.0.2.0/24", "10.0.3.0/24"]
    vpc_private_subnet_ids          = ["subnet-1234567890", "subnet-0987654321"]
    vpc_public_subnet_ids           = ["subnet-1122334455", "subnet-5544332211"]
    service_discovery_namespace_arn = "arn:aws:servicediscovery:ca-central-1:123456789012:namespace/ns-1234567890"
    cartography_repository_url      = "123456789012.dkr.ecr.ca-central-1.amazonaws.com/cartography"
    neo4j_repository_url            = "123456789012.dkr.ecr.ca-central-1.amazonaws.com/neo4j"
  }
}

inputs = {
  tool_name                                       = "cloud-asset-inventory"
  cartography_image                               = dependency.base.outputs.cartography_repository_url
  cartography_image_tag                           = "latest"
  neo4j_image                                     = dependency.base.outputs.neo4j_repository_url
  neo4j_image_tag                                 = "latest"
  neo4j_password                                  = "neo4j-password"
  password_change_id                              = "change-me-to-trigger-password-change"
  cloud_asset_inventory_vpc_peering_connection_id = "pcx-0771c54d393000439"
  organization_management_account_id              = "0123456789012"
  service_discovery_namespace_arn                 = dependency.base.outputs.service_discovery_namespace_arn
  security_tools_vpc_id                           = dependency.base.outputs.security_tools_vpc_id
  vpc_private_subnet_cidrs                        = dependency.base.outputs.vpc_private_subnet_cidrs
  vpc_public_subnet_cidrs                         = dependency.base.outputs.vpc_public_subnet_cidrs
  vpc_private_subnet_ids                          = dependency.base.outputs.vpc_private_subnet_ids
  vpc_public_subnet_ids                           = dependency.base.outputs.vpc_public_subnet_ids
  customer_id                                     = "fake-customer-id-for-testing"
  shared_key                                      = "fake-shared-key-for-testing"
}

include {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}