variable "name" {
  description = "Name of the RDS instance or Aurora cluster"
  type        = string
}

variable "use_aurora" {
  description = "Whether to create an Aurora cluster instead of a standard RDS instance"
  type        = bool
  default     = false
}

variable "engine" {
  description = "Database engine for the standard RDS instance"
  type        = string
  default     = "postgres"

  validation {
    condition     = contains(["postgres", "mysql"], var.engine)
    error_message = "The engine must be either postgres or mysql."
  }
}

variable "engine_version" {
  description = "Database engine version for the standard RDS instance"
  type        = string
  default     = "17.10"
}

variable "parameter_group_family_rds" {
  description = "Parameter group family compatible with the selected RDS engine version"
  type        = string
  default     = "postgres17"
}

variable "instance_class" {
  description = "Instance class used by the database"
  type        = string
  default     = "db.t3.micro"
}

variable "allocated_storage" {
  description = "Allocated storage in GiB for the standard RDS instance"
  type        = number
  default     = 20

  validation {
    condition     = var.allocated_storage >= 20
    error_message = "Allocated storage must be at least 20 GiB."
  }
}

variable "db_name" {
  description = "Name of the initial database"
  type        = string
}

variable "username" {
  description = "Master database username"
  type        = string
}

variable "password" {
  description = "Master database password"
  type        = string
  sensitive   = true
  ephemeral   = true

  validation {
    condition     = length(var.password) >= 8
    error_message = "The database password must contain at least 8 characters."
  }
}

variable "password_revision" {
  description = "Revision used to rotate the database password"
  type        = number
  default     = 1
}

variable "vpc_id" {
  description = "ID of the VPC where the database will be created"
  type        = string
}

variable "subnet_private_ids" {
  description = "Private subnet IDs used when the database is not publicly accessible"
  type        = list(string)

  validation {
    condition     = length(var.subnet_private_ids) >= 2
    error_message = "At least two private subnets are required."
  }
}

variable "subnet_public_ids" {
  description = "Public subnet IDs used when publicly_accessible is enabled"
  type        = list(string)
  default     = []
}

variable "publicly_accessible" {
  description = "Whether the database receives a publicly accessible endpoint"
  type        = bool
  default     = false
}

variable "port" {
  description = "Database port, for example 5432 for PostgreSQL or 3306 for MySQL"
  type        = number
  default     = 5432

  validation {
    condition     = var.port >= 1 && var.port <= 65535
    error_message = "The database port must be between 1 and 65535."
  }
}

variable "allowed_cidr_blocks" {
  description = "CIDR blocks allowed to connect to the database port"
  type        = list(string)
  default     = []
}

variable "multi_az" {
  description = "Whether to enable a Multi-AZ deployment for the standard RDS instance"
  type        = bool
  default     = false
}

variable "backup_retention_period" {
  description = "Number of days to retain automated backups"
  type        = number
  default     = 7

  validation {
    condition     = var.backup_retention_period >= 0 && var.backup_retention_period <= 35
    error_message = "Backup retention period must be between 0 and 35 days."
  }
}

variable "parameters" {
  description = "Database parameters added to the parameter group for the selected database type"
  type        = map(string)
  default     = {}
}

variable "storage_encrypted" {
  description = "Whether to encrypt database storage"
  type        = bool
  default     = true
}

variable "deletion_protection" {
  description = "Whether to protect the database from deletion"
  type        = bool
  default     = false
}

variable "skip_final_snapshot" {
  description = "Whether to skip the final snapshot when deleting the database"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags applied to created resources"
  type        = map(string)
  default     = {}
}

variable "engine_cluster" {
  description = "Aurora database engine: aurora-postgresql or aurora-mysql"
  type        = string
  default     = "aurora-postgresql"

  validation {
    condition = contains(
      ["aurora-postgresql", "aurora-mysql"],
      var.engine_cluster
    )
    error_message = "engine_cluster must be aurora-postgresql or aurora-mysql."
  }
}

variable "engine_version_cluster" {
  description = "Aurora engine version"
  type        = string
  default     = "15.17"
}

variable "parameter_group_family_aurora" {
  description = "Aurora cluster parameter group family"
  type        = string
  default     = "aurora-postgresql15"
}

variable "aurora_instance_count" {
  description = "Total number of Aurora instances, including one writer"
  type        = number
  default     = 2

  validation {
    condition     = var.aurora_instance_count >= 1
    error_message = "aurora_instance_count must be at least 1."
  }
}