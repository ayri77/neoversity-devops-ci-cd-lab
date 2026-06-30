terraform {
  backend "s3" {
    bucket       = "pbori-neoversity-terraform-state"
    key          = "lesson-6/terraform.tfstate"
    region       = "eu-central-1"
    profile      = "neoversity"
    encrypt      = true
    use_lockfile = true
  }
}
