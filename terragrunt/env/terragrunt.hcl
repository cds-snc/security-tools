inputs = {
  account_id                = "${get_aws_account_id()}"
  billing_tag_key           = "CostCentre"
  billing_tag_value         = "security-tools-${get_aws_account_id()}"
  cbs_satellite_bucket_name = "cbs-satellite-${get_aws_account_id()}"
  domain_name               = "security.cdssandbox.xyz"
  product_name              = "security-tools"
  region                    = "ca-central-1"
}

remote_state {
  backend = "s3"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
  config = {
    encrypt        = true
    bucket         = "security-tools-${get_aws_account_id()}-tfstate"
    dynamodb_table = "tfstate-lock"
    region         = "ca-central-1"
    key            = "${path_relative_to_include()}/terraform.tfstate"
  }
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents  = file("./common/provider.tf")
}

generate "common_variables" {
  path      = "common_variables.tf"
  if_exists = "overwrite"
  contents  = file("./common/common_variables.tf")
}
