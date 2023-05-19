terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.67.0"
    }
  }
}

provider "aws" {
  region = "ap-southeast-2"
  profile = "default"
}

terraform {
    backend "s3" {
    bucket = "iac-terraform-instances"
    key    = "aws-infra"
    region = "ap-southeast-2"
  }
}

module "buckets" {
  source = "./buckets"
  account_id = var.account_id
  region = var.region
  environment = var.environment
}

