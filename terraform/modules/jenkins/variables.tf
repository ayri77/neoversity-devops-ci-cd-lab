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

variable "github_token" {
  description = "GitHub PAT used by Jenkins for the GitOps repository"
  type        = string
  sensitive   = true
  ephemeral   = true
}

variable "github_token_revision" {
  description = "Revision used to rotate the Jenkins GitHub token"
  type        = number
  default     = 1
}
