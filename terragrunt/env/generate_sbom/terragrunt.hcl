locals {
  parent_vars = read_terragrunt_config("../terragrunt.hcl")
}

terraform {
  source = "../../aws//generate_sbom"
}

inputs = {
  tool_name = "generate_sbom"
}

include {
  path   = find_in_parent_folders()
  expose = true
}