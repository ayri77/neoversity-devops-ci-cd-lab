# Connect the module for S3 and DynamoDB resources
module "s3_backend" {
  source = "./modules/s3-backend"

  bucket_name = "pbori-neoversity-terraform-state"
  table_name  = "terraform-locks"
}
