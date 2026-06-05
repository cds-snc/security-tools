# Persistent EFS storage for the Pomerium file-based databroker, so sessions survive task recycles.

locals {
  databroker_efs_volume_name = "pomerium-databroker-efs-volume"
  databroker_mount_path      = "/var/pomerium/databroker"
}

resource "aws_efs_file_system" "databroker" {
  encrypted = true

  tags = {
    (var.billing_tag_key) = var.billing_tag_value
    Terraform             = true
    Product               = "${var.product_name}-${var.tool_name}"
  }
}

resource "aws_efs_mount_target" "databroker" {
  count           = length(var.vpc_private_subnet_ids)
  file_system_id  = aws_efs_file_system.databroker.id
  subnet_id       = element(var.vpc_private_subnet_ids, count.index)
  security_groups = [aws_security_group.pomerium.id]
}

resource "aws_efs_backup_policy" "databroker" {
  file_system_id = aws_efs_file_system.databroker.id

  backup_policy {
    status = "ENABLED"
  }
}

resource "aws_efs_access_point" "databroker" {
  file_system_id = aws_efs_file_system.databroker.id

  root_directory {
    path = "/databroker"
    creation_info {
      owner_gid   = 1000
      owner_uid   = 1000
      permissions = "755"
    }
  }

  posix_user {
    gid = 1000
    uid = 1000
  }

  tags = {
    (var.billing_tag_key) = var.billing_tag_value
    Terraform             = true
    Product               = "${var.product_name}-${var.tool_name}"
  }
}
