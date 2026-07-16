terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "~> 3.2"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 3.2"
    }
  }
}

provider "aws" {
  region  = "eu-central-1"
  profile = "neoversity"
}

data "aws_eks_cluster" "eks" {
  name = module.eks.cluster_name

  depends_on = [module.eks]
}

provider "helm" {
  kubernetes = {
    host = data.aws_eks_cluster.eks.endpoint

    cluster_ca_certificate = base64decode(
      data.aws_eks_cluster.eks.certificate_authority[0].data
    )

    exec = {
      api_version = "client.authentication.k8s.io/v1"
      command     = "aws"
      args = [
        "eks",
        "get-token",
        "--cluster-name",
        module.eks.cluster_name,
        "--region",
        "eu-central-1",
        "--profile",
        "neoversity",
      ]
    }
  }
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.eks.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)

  exec {
    api_version = "client.authentication.k8s.io/v1"
    command     = "aws"
    args = [
      "eks",
      "get-token",
      "--cluster-name",
      module.eks.cluster_name,
      "--region",
      "eu-central-1",
      "--profile",
      "neoversity",
    ]
  }
}
