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

variable "db_password" {
  description = "Master password for the database"
  type        = string
  sensitive   = true
  ephemeral   = true
}

variable "db_password_revision" {
  description = "Revision used to rotate the database password"
  type        = number
  default     = 1
}

variable "django_secret_key" {
  description = "Django SECRET_KEY"
  type        = string
  sensitive   = true
  ephemeral   = true
}

variable "django_secret_revision" {
  description = "Revision used to rotate Django application secrets"
  type        = number
  default     = 1
}
