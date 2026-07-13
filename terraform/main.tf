# Connect the module for S3 and DynamoDB resources
# comment to prevent duplicating backend
/*
module "s3_backend" {
  source = "./modules/s3-backend"

  bucket_name = "pbori-neoversity-terraform-state"
  table_name  = "terraform-locks"
}
*/

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

  vpc_name = "lesson-8-vpc"
}

# Connect the module for ECR repository
module "ecr" {
  source = "./modules/ecr"

  ecr_name     = "lesson-8-ecr"
  scan_on_push = true
}

# Connect the module for EKS cluster
module "eks" {
  source = "./modules/eks"

  cluster_name       = "lesson-8-eks"
  subnet_ids         = module.vpc.private_subnets
  node_instance_type = "t3.small"

  desired_size = 2
  min_size     = 2
  max_size     = 2
}

# Install Jenkins in the EKS cluster using Helm
module "jenkins" {
  source = "./modules/jenkins"

  cluster_name      = module.eks.cluster_name
  oidc_provider_arn = module.eks.oidc_provider_arn
  oidc_provider_url = module.eks.oidc_provider_url

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
    module.eks
  ]
}
