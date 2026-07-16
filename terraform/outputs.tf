# comment to prevent duplicating backend
/* 
output "s3_bucket_name" {
  description = "Name of the S3 bucket used for Terraform state"
  value       = module.s3_backend.s3_bucket_name
}

output "dynamodb_table_name" {
  description = "Name of the DynamoDB table used for Terraform state locking"
  value       = module.s3_backend.dynamodb_table_name
}
*/

output "vpc_id" {
  description = "ID of the created VPC"
  value       = module.vpc.vpc_id
}

output "public_subnets" {
  description = "IDs of the public subnets"
  value       = module.vpc.public_subnets
}

output "private_subnets" {
  description = "IDs of the private subnets"
  value       = module.vpc.private_subnets
}

output "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  value       = module.vpc.internet_gateway_id
}

output "nat_gateway_id" {
  description = "ID of the NAT Gateway"
  value       = module.vpc.nat_gateway_id
}

output "nat_eip" {
  description = "Public IP address of the NAT Gateway"
  value       = module.vpc.nat_eip
}

output "ecr_repository_name" {
  description = "Name of the ECR repository"
  value       = module.ecr.repository_name
}

output "ecr_repository_url" {
  description = "URL of the ECR repository"
  value       = module.ecr.repository_url
}

output "ecr_repository_arn" {
  description = "ARN of the ECR repository"
  value       = module.ecr.repository_arn
}

output "eks_cluster_name" {
  description = "Name of the EKS cluster"
  value       = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  description = "Endpoint for the EKS Kubernetes API server"
  value       = module.eks.cluster_endpoint
}

output "eks_cluster_arn" {
  description = "ARN of the EKS cluster"
  value       = module.eks.cluster_arn
}

output "eks_node_group_name" {
  description = "Name of the EKS managed node group"
  value       = module.eks.node_group_name
}

output "jenkins_release" {
  description = "Name of the Jenkins Helm release"
  value       = module.jenkins.jenkins_release_name
}

output "jenkins_namespace" {
  description = "Kubernetes namespace where Jenkins is deployed"
  value       = module.jenkins.jenkins_namespace
}

output "argocd_release" {
  description = "Name of the Argo CD Helm release"
  value       = module.argo_cd.release_name
}

output "argocd_namespace" {
  description = "Namespace where Argo CD is installed"
  value       = module.argo_cd.namespace
}

output "argocd_applications_release" {
  description = "Name of the Argo CD Applications Helm release"
  value       = module.argo_cd.applications_release_name
}

output "rds_instance_identifier" {
  description = "Identifier of the standard RDS instance"
  value       = module.rds.rds_instance_identifier
}

output "rds_instance_arn" {
  description = "ARN of the standard RDS instance"
  value       = module.rds.rds_instance_arn
}

output "rds_endpoint" {
  description = "Connection endpoint of the standard RDS instance"
  value       = module.rds.rds_endpoint
}

output "rds_port" {
  description = "Port of the standard RDS instance"
  value       = module.rds.rds_port
}

output "rds_security_group_id" {
  description = "ID of the database security group"
  value       = module.rds.security_group_id
}

output "rds_subnet_group_name" {
  description = "Name of the database subnet group"
  value       = module.rds.db_subnet_group_name
}

output "database_endpoint" {
  description = "Primary endpoint of the selected database type"
  value       = module.rds.database_endpoint
}

output "database_reader_endpoint" {
  description = "Aurora reader endpoint; null for a standard RDS instance"
  value       = module.rds.database_reader_endpoint
}

output "database_port" {
  description = "Database connection port"
  value       = module.rds.database_port
}

output "aurora_cluster_identifier" {
  description = "Identifier of the Aurora cluster"
  value       = module.rds.aurora_cluster_identifier
}

output "aurora_cluster_arn" {
  description = "ARN of the Aurora cluster"
  value       = module.rds.aurora_cluster_arn
}

output "aurora_writer_instance_identifier" {
  description = "Identifier of the Aurora writer instance"
  value       = module.rds.aurora_writer_instance_identifier
}

output "aurora_reader_instance_identifiers" {
  description = "Identifiers of the Aurora reader instances"
  value       = module.rds.aurora_reader_instance_identifiers
}

output "monitoring_namespace" {
  description = "Kubernetes namespace containing monitoring components"
  value       = module.monitoring.namespace
}

output "prometheus_release" {
  description = "Name of the Prometheus Helm release"
  value       = module.monitoring.prometheus_release_name
}

output "prometheus_service" {
  description = "Name of the Prometheus server Kubernetes Service"
  value       = module.monitoring.prometheus_service_name
}

output "grafana_release" {
  description = "Name of the Grafana Helm release"
  value       = module.monitoring.grafana_release_name
}

output "grafana_service" {
  description = "Name of the Grafana Kubernetes Service"
  value       = module.monitoring.grafana_service_name
}

output "grafana_admin_secret" {
  description = "Name of the Kubernetes Secret containing Grafana admin credentials"
  value       = module.monitoring.grafana_admin_secret_name
}
