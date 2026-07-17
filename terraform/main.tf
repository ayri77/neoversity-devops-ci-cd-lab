# Connect the module for VPC networking resources
module "vpc" {
  source = "./modules/vpc"

  vpc_cidr_block = "10.0.0.0/16"

  public_subnets = [
    "10.0.1.0/24",
    "10.0.2.0/24",
    "10.0.3.0/24"
  ]

  private_subnets = [
    "10.0.4.0/24",
    "10.0.5.0/24",
    "10.0.6.0/24"
  ]

  availability_zones = [
    "eu-central-1a",
    "eu-central-1b",
    "eu-central-1c"
  ]

  vpc_name = "final-project-vpc"
}

# Connect the module for ECR repository
module "ecr" {
  source = "./modules/ecr"

  ecr_name     = "final-project-ecr"
  scan_on_push = true
}

# Connect the module for EKS cluster
module "eks" {
  source = "./modules/eks"

  cluster_name        = "final-project-eks"
  subnet_ids          = module.vpc.private_subnets
  node_instance_type  = "t3.small"
  cluster_version     = "1.36"
  public_access_cidrs = var.eks_public_access_cidrs

  desired_size = 3
  min_size     = 2
  max_size     = 3
}

# Install Jenkins in the EKS cluster using Helm
module "jenkins" {
  source = "./modules/jenkins"

  cluster_name          = module.eks.cluster_name
  oidc_provider_arn     = module.eks.oidc_provider_arn
  oidc_provider_url     = module.eks.oidc_provider_url
  github_token          = var.github_token
  github_token_revision = var.github_token_revision
  ecr_repository_arn    = module.ecr.repository_arn
  ecr_repository_url    = module.ecr.repository_url

  providers = {
    aws        = aws
    helm       = helm
    kubernetes = kubernetes
  }

  depends_on = [
    module.eks,
    kubernetes_storage_class_v1.ebs_gp3,
  ]
}

# Install Argo CD in the EKS cluster using Helm
module "argo_cd" {
  source = "./modules/argo-cd"

  namespace     = "argocd"
  chart_version = "10.1.3"

  providers = {
    helm = helm
  }

  depends_on = [
    module.eks,
    kubernetes_secret_v1.django_app,
  ]
}

# Create a standard RDS instance or an Aurora cluster
module "rds" {
  source = "./modules/rds"

  name                  = "final-project-db"
  use_aurora            = false
  aurora_instance_count = 2

  # Aurora-only configuration
  engine_cluster                = "aurora-postgresql"
  engine_version_cluster        = "15.17"
  parameter_group_family_aurora = "aurora-postgresql15"

  # Standard RDS-only configuration
  engine                     = "postgres"
  engine_version             = "17.10"
  parameter_group_family_rds = "postgres17"
  allocated_storage          = 20
  multi_az                   = false

  # Common database configuration
  instance_class    = "db.t3.micro"
  db_name           = "myapp"
  username          = "postgres"
  password          = var.db_password
  password_revision = var.db_password_revision
  port              = 5432

  # Network configuration
  vpc_id             = module.vpc.vpc_id
  subnet_private_ids = module.vpc.private_subnets
  subnet_public_ids  = module.vpc.public_subnets

  publicly_accessible = false
  allowed_cidr_blocks = ["10.0.0.0/16"]

  # Backups and protection
  backup_retention_period = 1
  storage_encrypted       = true
  deletion_protection     = false
  skip_final_snapshot     = true

  parameters = {
    max_connections            = "200"
    log_statement              = "ddl"
    work_mem                   = "4096"
    log_min_duration_statement = "500"
  }

  tags = {
    Environment = "dev"
    Project     = "final-project"
  }
}

# Install Prometheus and Grafana in the EKS cluster using Helm
module "monitoring" {
  source = "./modules/monitoring"

  namespace                    = "monitoring"
  prometheus_chart_version     = "29.17.0"
  grafana_chart_version        = "12.7.2"
  metrics_server_chart_version = "3.13.1"

  providers = {
    helm       = helm
    kubernetes = kubernetes
  }

  depends_on = [
    module.eks,
    kubernetes_storage_class_v1.ebs_gp3,
  ]
}
