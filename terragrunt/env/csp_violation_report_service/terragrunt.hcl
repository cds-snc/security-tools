locals {
  parent_vars = read_terragrunt_config("../terragrunt.hcl")
}

terraform {
  source = "../../aws//csp_violation_report_service"
}

dependencies {
  paths = ["../base"]
}

dependency "base" {
  config_path                             = "../base"
  mock_outputs_allowed_terraform_commands = ["init", "fmt", "validate", "plan", "show"]
  mock_outputs_merge_with_state           = true
  mock_outputs = {
    hosted_zone_id = "1234567890"
  }
}

inputs = {
  hosted_zone_id   = dependency.base.outputs.hosted_zone_id
  tool_name        = "csp_violation_report_service"
  tool_domain_name = "csp-report-to.${local.parent_vars.inputs.domain_name}"
}

include {
  path   = find_in_parent_folders()
  expose = true
}