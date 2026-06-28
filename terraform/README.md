# Lesson 5: Infrastructure as Code with Terraform

This directory contains the Terraform configuration for the Neoversity DevOps CI/CD Lesson 5 homework.

The goal of this task is to create AWS infrastructure with Terraform using a modular structure.

All Terraform configuration files are located in the `terraform/` directory. The work is done in the `lesson-5` Git branch.

## What this configuration creates

Terraform creates the following AWS resources:

| Resource                     | Purpose                                                          |
| ---------------------------- | ---------------------------------------------------------------- |
| S3 bucket                    | Stores Terraform remote state                                    |
| S3 bucket versioning         | Keeps previous versions of the state file                        |
| S3 bucket ownership controls | Enforces bucket owner ownership for stored objects               |
| S3 public access block       | Prevents public access to the state bucket                       |
| DynamoDB table               | Demonstrates the classic Terraform state locking mechanism       |
| VPC                          | Provides an isolated network for AWS resources                   |
| Public subnets               | Subnets with access to the Internet Gateway                      |
| Private subnets              | Subnets without direct public internet access                    |
| Internet Gateway             | Allows public subnets to access the internet                     |
| NAT Gateway                  | Allows private subnets to initiate outbound internet connections |
| Public route table           | Routes public subnet traffic to the Internet Gateway             |
| Private route table          | Routes private subnet outbound traffic through the NAT Gateway   |
| ECR repository               | Stores Docker container images                                   |
| ECR repository policy        | Defines access permissions for the ECR repository                |

## Project structure

```text
terraform/
├── backend.tf
├── main.tf
├── outputs.tf
├── providers.tf
├── README.md
└── modules/
    ├── ecr/
    │   ├── ecr.tf
    │   ├── outputs.tf
    │   └── variables.tf
    ├── s3-backend/
    │   ├── dynamodb.tf
    │   ├── outputs.tf
    │   ├── s3.tf
    │   └── variables.tf
    └── vpc/
        ├── outputs.tf
        ├── routes.tf
        ├── variables.tf
        └── vpc.tf
```

## Modules

### `s3-backend`

The `s3-backend` module creates infrastructure required for Terraform remote state storage.

It creates:

* an S3 bucket for Terraform state;
* S3 bucket versioning;
* S3 bucket ownership controls;
* S3 public access block;
* a DynamoDB table that demonstrates the classic state locking approach.

The root module passes the following values into the module:

```hcl
module "s3_backend" {
  source = "./modules/s3-backend"

  bucket_name = "pbori-neoversity-terraform-state"
  table_name  = "terraform-locks"
}
```

### `vpc`

The `vpc` module creates the networking infrastructure.

It creates:

* one VPC;
* three public subnets;
* three private subnets;
* one Internet Gateway;
* one NAT Gateway;
* one Elastic IP for the NAT Gateway;
* a public route table;
* a private route table;
* route table associations for public and private subnets.

The root module passes the following values into the module:

```hcl
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

  vpc_name = "lesson-5-vpc"
}
```

### `ecr`

The `ecr` module creates an Amazon Elastic Container Registry repository.

It creates:

* an ECR repository;
* repository-level access policy;
* image scanning on push.

The root module passes the following values into the module:

```hcl
module "ecr" {
  source = "./modules/ecr"

  ecr_name     = "lesson-5-ecr"
  scan_on_push = true
}
```

## AWS provider

The AWS provider is configured in `providers.tf`:

```hcl
provider "aws" {
  region  = "eu-central-1"
  profile = "neoversity"
}
```

The configuration uses the AWS CLI profile `neoversity`.

The AWS region used for this homework is:

```text
eu-central-1
```

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

## Network design

The VPC uses the CIDR block:

```text
10.0.0.0/16
```

Public subnets:

```text
10.0.1.0/24
10.0.2.0/24
10.0.3.0/24
```

Private subnets:

```text
10.0.4.0/24
10.0.5.0/24
10.0.6.0/24
```

Public subnets use a route table with the following internet route:

```text
0.0.0.0/0 -> Internet Gateway
```

Private subnets use a separate route table with the following outbound route:

```text
0.0.0.0/0 -> NAT Gateway
```

This allows resources in private subnets to initiate outbound internet connections without being directly reachable from the public internet.

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

Format Terraform files:

```bash
terraform fmt -recursive
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

List Terraform-managed resources:

```bash
terraform state list
```

## Outputs

The configuration exposes the following outputs:

| Output                | Description                                    |
| --------------------- | ---------------------------------------------- |
| `s3_bucket_name`      | Name of the S3 bucket used for Terraform state |
| `dynamodb_table_name` | Name of the DynamoDB table                     |
| `vpc_id`              | ID of the created VPC                          |
| `public_subnets`      | IDs of the public subnets                      |
| `private_subnets`     | IDs of the private subnets                     |
| `internet_gateway_id` | ID of the Internet Gateway                     |
| `nat_gateway_id`      | ID of the NAT Gateway                          |
| `nat_eip`             | Public IP address of the NAT Gateway           |
| `ecr_repository_name` | Name of the ECR repository                     |
| `ecr_repository_url`  | URL of the ECR repository                      |
| `ecr_repository_arn`  | ARN of the ECR repository                      |

## Important notes

Terraform state files must not be committed to Git.

The following files and directories are ignored:

```text
.terraform/
*.tfstate
*.tfstate.*
```

The `.terraform.lock.hcl` file should be committed because it locks the provider version and makes Terraform runs more reproducible.

## Cost note

The NAT Gateway is a paid AWS resource. It should not be left running after the homework is submitted unless it is still needed.

The ECR repository may also generate storage costs if Docker images are pushed to it.

After submission, the temporary infrastructure should be reviewed and removed if it is no longer required.

## Cleanup note

A full `terraform destroy` would try to destroy all resources managed by this configuration, including the Terraform backend infrastructure.

Because the S3 bucket is used as the remote backend for Terraform state, cleanup should be done carefully.

For removing only the application/networking part, use a targeted cleanup approach, for example:

```bash
terraform destroy -target=module.vpc -target=module.ecr
```

The S3 backend and DynamoDB table should be removed separately only after the Terraform state migration or final cleanup strategy is clear.
