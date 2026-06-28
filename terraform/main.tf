# Connect the module for S3 and DynamoDB resources
module "s3_backend" {
  source = "./modules/s3-backend"

  bucket_name = "pbori-neoversity-terraform-state"
  table_name  = "terraform-locks"
}

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

  vpc_name = "lesson-5-vpc"
}

# Connect the module for ECR repository
module "ecr" {
  source = "./modules/ecr"

  ecr_name     = "lesson-5-ecr"
  scan_on_push = true
}