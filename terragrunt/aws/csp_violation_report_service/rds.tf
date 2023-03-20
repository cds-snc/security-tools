module "csp_reports_db" {
  source = "github.com/cds-snc/terraform-modules?ref=v1.0.5//rds"
  name   = "csp-reports"

  database_name  = aws_ssm_parameter.db_database.value
  engine         = "aurora-postgresql"
  engine_version = "13.9"
  instances      = 2
  instance_class = "db.t3.medium"
  username       = aws_ssm_parameter.db_username.value
  password       = aws_ssm_parameter.db_password.value

  prevent_cluster_deletion = true
  skip_final_snapshot      = false

  backup_retention_period = 7
  preferred_backup_window = "01:00-03:00"

  vpc_id     = var.security_tools_vpc_id
  subnet_ids = var.vpc_private_subnet_ids

  billing_tag_key   = var.billing_tag_key
  billing_tag_value = var.billing_tag_value
}
