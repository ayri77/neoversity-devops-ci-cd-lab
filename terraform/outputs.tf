output "s3_bucket_name" {
  description = "Name of the S3 bucket used for Terraform state"
  value       = module.s3_backend.s3_bucket_name
}

output "dynamodb_table_name" {
  description = "Name of the DynamoDB table used for Terraform state locking"
  value       = module.s3_backend.dynamodb_table_name
}
