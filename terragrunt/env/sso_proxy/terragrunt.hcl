terraform {
  source = "../../aws//sso_proxy"
}

inputs = {
  tool_name = "sso_proxy"
}

include {
  path   = find_in_parent_folders()
  expose = true
}