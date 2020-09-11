# backend.tf
terraform {
  required_version = ">= 0.12"

  backend "s3" {
    bucket  = "whoi.appdev.terraform"
    key     = "cloudendure/terraform.tfstate"
    region  = "us-east-1"
    profile = "default"
  }
}
