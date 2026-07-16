output "rds_instance_identifier" {
  description = "Identifier of the standard RDS instance"
  value       = try(aws_db_instance.standard[0].identifier, null)
}

output "rds_instance_arn" {
  description = "ARN of the standard RDS instance"
  value       = try(aws_db_instance.standard[0].arn, null)
}

output "rds_endpoint" {
  description = "Connection endpoint of the standard RDS instance"
  value       = try(aws_db_instance.standard[0].endpoint, null)
}

output "rds_address" {
  description = "DNS address of the standard RDS instance without the port"
  value       = try(aws_db_instance.standard[0].address, null)
}

output "rds_port" {
  description = "Port of the standard RDS instance"
  value       = try(aws_db_instance.standard[0].port, null)
}

output "db_subnet_group_name" {
  description = "Name of the database subnet group"
  value       = aws_db_subnet_group.default.name
}

output "security_group_id" {
  description = "ID of the database security group"
  value       = aws_security_group.rds.id
}

output "database_endpoint" {
  description = "Primary endpoint: standard RDS endpoint or Aurora writer endpoint"
  value = var.use_aurora ? (
    try(aws_rds_cluster.aurora[0].endpoint, null)
    ) : (
    try(aws_db_instance.standard[0].endpoint, null)
  )
}

output "database_reader_endpoint" {
  description = "Aurora reader endpoint; null for a standard RDS instance"
  value = var.use_aurora ? (
    try(aws_rds_cluster.aurora[0].reader_endpoint, null)
  ) : null
}

output "database_port" {
  description = "Database connection port"
  value       = var.port
}

output "database_host" {
  description = "Database DNS host without the port"
  value = var.use_aurora ? (
    try(aws_rds_cluster.aurora[0].endpoint, null)
    ) : (
    try(aws_db_instance.standard[0].address, null)
  )
}

output "aurora_cluster_identifier" {
  description = "Identifier of the Aurora cluster"
  value       = try(aws_rds_cluster.aurora[0].cluster_identifier, null)
}

output "aurora_cluster_arn" {
  description = "ARN of the Aurora cluster"
  value       = try(aws_rds_cluster.aurora[0].arn, null)
}

output "aurora_writer_instance_identifier" {
  description = "Identifier of the Aurora writer instance"
  value       = try(aws_rds_cluster_instance.aurora_writer[0].identifier, null)
}

output "aurora_reader_instance_identifiers" {
  description = "Identifiers of the Aurora reader instances"
  value = [
    for instance in aws_rds_cluster_instance.aurora_readers :
    instance.identifier
  ]
}