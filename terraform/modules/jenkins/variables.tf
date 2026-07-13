variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "oidc_provider_arn" {
  description = "ARN of the IAM OIDC provider used by IRSA"
  type        = string
}

variable "oidc_provider_url" {
  description = "URL of the IAM OIDC provider used by IRSA"
  type        = string
}