module "security_tools_binaries" {
  source            = "github.com/cds-snc/terraform-modules//S3?ref=v10.11.0"
  bucket_name       = "cds-security-tools-binaries"
  billing_tag_value = var.billing_tag_value

  versioning = {
    enabled = true
  }
}