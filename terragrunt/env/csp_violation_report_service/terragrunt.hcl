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
  tool_name = "csp_violation_report_service"
}

include {
  path   = find_in_parent_folders()
  expose = true
}