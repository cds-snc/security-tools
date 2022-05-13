terraform {
  source = "../../aws//base"
}

inputs = {
}

include {
  path   = find_in_parent_folders()
  expose = true
}