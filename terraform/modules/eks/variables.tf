variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "subnet_ids" {
  description = "Subnet IDs for the EKS cluster and worker nodes"
  type        = list(string)
}

variable "node_instance_type" {
  description = "EC2 instance type for EKS worker nodes"
  type        = string
  default     = "t2.micro"
}

variable "desired_size" {
  description = "Desired number of worker nodes"
  type        = number
  default     = 1
}

variable "min_size" {
  description = "Minimum number of worker nodes"
  type        = number
  default     = 1
}

variable "max_size" {
  description = "Maximum number of worker nodes"
  type        = number
  default     = 1
}

variable "cluster_version" {
  description = "Kubernetes version for the EKS control plane and managed node group"
  type        = string
  default     = "1.36"
}

variable "public_access_cidrs" {
  description = "CIDR blocks allowed to access the public EKS API endpoint"
  type        = list(string)

  validation {
    condition = (
      length(var.public_access_cidrs) > 0 &&
      alltrue([
        for cidr in var.public_access_cidrs : can(cidrhost(cidr, 0))
      ])
    )
    error_message = "At least one valid CIDR block must be provided."
  }
}
