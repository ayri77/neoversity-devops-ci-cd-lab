# Aurora cluster parameter group
resource "aws_rds_cluster_parameter_group" "aurora" {
  count = var.use_aurora ? 1 : 0

  name_prefix = "${var.name}-aurora-params-"
  family      = var.parameter_group_family_aurora
  description = "Aurora cluster parameter group for ${var.name}"

  dynamic "parameter" {
    for_each = var.parameters

    content {
      name         = parameter.key
      value        = parameter.value
      apply_method = "pending-reboot"
    }
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = var.tags
}

# Aurora cluster
resource "aws_rds_cluster" "aurora" {
  count = var.use_aurora ? 1 : 0

  cluster_identifier              = "${var.name}-cluster"
  engine                          = var.engine_cluster
  engine_version                  = var.engine_version_cluster
  database_name                   = var.db_name
  master_username                 = var.username
  master_password                 = var.password
  port                            = var.port
  db_subnet_group_name            = aws_db_subnet_group.default.name
  vpc_security_group_ids          = [aws_security_group.rds.id]
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.aurora[0].name
  backup_retention_period         = var.backup_retention_period
  storage_encrypted               = var.storage_encrypted
  deletion_protection             = var.deletion_protection
  skip_final_snapshot             = var.skip_final_snapshot
  final_snapshot_identifier       = var.skip_final_snapshot ? null : "${var.name}-aurora-final-snapshot"
  copy_tags_to_snapshot           = true

  tags = var.tags
}

# Aurora writer
resource "aws_rds_cluster_instance" "aurora_writer" {
  count = var.use_aurora ? 1 : 0

  identifier           = "${var.name}-writer"
  cluster_identifier   = aws_rds_cluster.aurora[0].id
  instance_class       = var.instance_class
  engine               = var.engine_cluster
  engine_version       = var.engine_version_cluster
  db_subnet_group_name = aws_db_subnet_group.default.name
  publicly_accessible  = var.publicly_accessible
  promotion_tier       = 0

  tags = var.tags
}

# Aurora reader instances
resource "aws_rds_cluster_instance" "aurora_readers" {
  count = var.use_aurora ? max(var.aurora_instance_count - 1, 0) : 0

  identifier           = "${var.name}-reader-${count.index + 1}"
  cluster_identifier   = aws_rds_cluster.aurora[0].id
  instance_class       = var.instance_class
  engine               = var.engine_cluster
  engine_version       = var.engine_version_cluster
  db_subnet_group_name = aws_db_subnet_group.default.name
  publicly_accessible  = var.publicly_accessible
  promotion_tier       = count.index + 1

  depends_on = [
    aws_rds_cluster_instance.aurora_writer
  ]

  tags = var.tags
}