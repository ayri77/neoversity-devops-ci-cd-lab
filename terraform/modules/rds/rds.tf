# Parameter group for a standard RDS instance
resource "aws_db_parameter_group" "standard" {
  count = var.use_aurora ? 0 : 1

  name_prefix = "${var.name}-rds-params-"
  family      = var.parameter_group_family_rds
  description = "Standard RDS parameter group for ${var.name}"

  dynamic "parameter" {
    for_each = var.parameters

    content {
      name         = parameter.key
      value        = parameter.value
      apply_method = "pending-reboot"
    }
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.name}-rds-params"
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

# Standard RDS instance
resource "aws_db_instance" "standard" {
  count = var.use_aurora ? 0 : 1

  identifier        = var.name
  engine            = var.engine
  engine_version    = var.engine_version
  instance_class    = var.instance_class
  allocated_storage = var.allocated_storage

  db_name             = var.db_name
  username            = var.username
  password_wo         = var.password
  password_wo_version = var.password_revision
  port                = var.port

  db_subnet_group_name   = aws_db_subnet_group.default.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  parameter_group_name   = aws_db_parameter_group.standard[0].name

  publicly_accessible     = var.publicly_accessible
  multi_az                = var.multi_az
  backup_retention_period = var.backup_retention_period

  storage_encrypted   = var.storage_encrypted
  deletion_protection = var.deletion_protection
  skip_final_snapshot = var.skip_final_snapshot

  final_snapshot_identifier = (
    var.skip_final_snapshot
    ? null
    : "${var.name}-final-snapshot"
  )

  copy_tags_to_snapshot = true

  tags = merge(
    var.tags,
    {
      Name = var.name
    }
  )
}