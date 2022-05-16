terraform {
  source = "../../aws//base"
}

inputs = {
  tool_name = "base"
}

include {
  path   = find_in_parent_folders()
  expose = true
}