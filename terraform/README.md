# Lesson 5: Infrastructure as Code with Terraform

This directory contains the Terraform configuration for the Neoversity DevOps CI/CD course practice task.

The goal of this task is to create infrastructure for storing Terraform state in AWS.

## What this configuration creates

Terraform creates the following AWS resources:

| Resource                     | Purpose                                            |
| ---------------------------- | -------------------------------------------------- |
| S3 bucket                    | Stores Terraform remote state                      |
| S3 bucket versioning         | Keeps previous versions of the state file          |
| S3 bucket ownership controls | Enforces bucket owner ownership for stored objects |
| S3 public access block       | Prevents public access to the state bucket         |
| DynamoDB table               | Classic Terraform state locking mechanism          |

## Project structure

```text
terraform/
├── backend.tf
├── main.tf
├── outputs.tf
├── providers.tf
├── README.md
└── modules/
    └── s3-backend/
        ├── dynamodb.tf
        ├── outputs.tf
        ├── s3.tf
        └── variables.tf
```

## Module description

The `s3-backend` module creates the AWS infrastructure required for Terraform state storage.

The root module passes the following values into the module:

```hcl
module "s3_backend" {
  source = "./modules/s3-backend"

  bucket_name = "pbori-neoversity-terraform-state"
  table_name  = "terraform-locks"
}
```

Inside the module:

* `variables.tf` defines input variables;
* `s3.tf` creates and configures the S3 bucket;
* `dynamodb.tf` creates the DynamoDB table;
* `outputs.tf` exposes created resource names.

## AWS provider

The AWS provider is configured in `providers.tf`:

```hcl
provider "aws" {
  region  = "eu-central-1"
  profile = "neoversity"
}
```

The configuration uses the AWS CLI profile `neoversity`.

## Remote backend

The Terraform backend is configured in `backend.tf`:

```hcl
terraform {
  backend "s3" {
    bucket       = "pbori-neoversity-terraform-state"
    key          = "lesson-5/terraform.tfstate"
    region       = "eu-central-1"
    profile      = "neoversity"
    encrypt      = true
    use_lockfile = true
  }
}
```

The original course material uses DynamoDB for state locking. However, the `dynamodb_table` backend parameter is deprecated in the current Terraform version. Therefore, this configuration uses the modern S3-native locking mechanism:

```hcl
use_lockfile = true
```

The DynamoDB table is still created as part of the course task because it demonstrates the classic Terraform state locking approach.

## Additional security improvement

The configuration includes an additional resource:

```hcl
resource "aws_s3_bucket_public_access_block" "terraform_state_public_access_block"
```

This was added intentionally as a security best practice.

Terraform state may contain sensitive infrastructure metadata, so the S3 bucket used for state storage must never be publicly accessible.

## Commands used

Initialize Terraform:

```bash
terraform init
```

Validate the configuration:

```bash
terraform validate
```

Preview planned infrastructure changes:

```bash
terraform plan
```

Apply the configuration:

```bash
terraform apply
```

Migrate local state to the S3 backend:

```bash
terraform init -migrate-state
```

Reconfigure backend after replacing deprecated DynamoDB locking with S3-native lockfile:

```bash
terraform init -reconfigure
```

Verify that the remote state file exists in S3:

```bash
aws s3 ls s3://pbori-neoversity-terraform-state/lesson-5/ --profile neoversity
```

## Important notes

Terraform state files must not be committed to Git.

The following files and directories are ignored:

```text
.terraform/
*.tfstate
*.tfstate.*
```

The `.terraform.lock.hcl` file should be committed because it locks the provider version and makes Terraform runs more reproducible.
