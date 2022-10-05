resource "aws_efs_file_system" "neo4j" {
  encrypted = true

  tags = {
    (var.billing_tag_key) = var.billing_tag_value
    Terraform             = true
    Product               = "${var.product_name}-${var.tool_name}"
  }
}

resource "aws_efs_mount_target" "neo4j" {
  count           = length(var.vpc_private_subnet_ids)
  file_system_id  = aws_efs_file_system.neo4j.id
  subnet_id       = element(var.vpc_private_subnet_ids, count.index)
  security_groups = [aws_security_group.cartography.id]
}

resource "aws_efs_backup_policy" "neo4j" {
  file_system_id = aws_efs_file_system.neo4j.id

  backup_policy {
    status = "ENABLED"
  }
}
