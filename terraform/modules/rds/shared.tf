# Subnet group used by both standard RDS and Aurora
resource "aws_db_subnet_group" "default" {
  name        = "${var.name}-subnet-group"
  description = "Database subnet group for ${var.name}"

  subnet_ids = var.publicly_accessible ? var.subnet_public_ids : var.subnet_private_ids

  tags = merge(
    var.tags,
    {
      Name = "${var.name}-subnet-group"
    }
  )

  lifecycle {
    precondition {
      condition = (
        !var.publicly_accessible
        || length(var.subnet_public_ids) >= 2
      )

      error_message = "At least two public subnets are required when publicly_accessible is true."
    }
  }
}

# Security group used by both standard RDS and Aurora
resource "aws_security_group" "rds" {
  name        = "${var.name}-sg"
  description = "Security group for ${var.name}"
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = length(var.allowed_cidr_blocks) > 0 ? [1] : []

    content {
      description = "Database access"
      from_port   = var.port
      to_port     = var.port
      protocol    = "tcp"
      cidr_blocks = var.allowed_cidr_blocks
    }
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.name}-sg"
    }
  )
}