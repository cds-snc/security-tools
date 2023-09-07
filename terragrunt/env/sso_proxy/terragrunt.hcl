terraform {
  source = "../../aws//sso_proxy"
}

inputs = {}

include {
  path   = find_in_parent_folders()
  expose = true
}