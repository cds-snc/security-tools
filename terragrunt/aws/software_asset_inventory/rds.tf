module "dependencytrack_db" {
  source = "github.com/cds-snc/terraform-modules?ref=v1.0.5//rds"
  name   = "dependency-track"

  database_name  = "dtrack"
  engine         = "aurora-postgresql"
  engine_version = "13.6"
  instances      = 2
  instance_class = "db.t3.medium"
  username       = aws_ssm_parameter.dependencytrack_db_user.value
  password       = aws_ssm_parameter.dependencytrack_db_password.value

  prevent_cluster_deletion = false
  skip_final_snapshot      = true

  backup_retention_period = 1
  preferred_backup_window = "01:00-03:00"

  vpc_id     = var.security_tools_vpc_id
  subnet_ids = var.vpc_private_subnet_ids

  billing_tag_key   = var.billing_tag_key
  billing_tag_value = var.billing_tag_value
}
