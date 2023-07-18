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

# All are independent modules for now :)
module "buckets" {
  source = "./buckets"
  account_id = var.account_id
  region = var.region
  environment = var.environment
}

module "lambdas" {
  source = "./lambdas"
  account_id = var.account_id
  region = var.region
  environment = var.environment
}

module "instances" {
  source = "./instances"
  account_id = var.account_id
  region = var.region
  environment = var.environment
}

module "snowflake" {
  source = "./snowflake"
  account_id = var.account_id
  region = var.region
  environment = var.environment
}

module "prefect" {
  source = "./prefect"
  account_id = var.account_id
  region = var.region
  environment = var.environment
  prefect_agent_queue_name = var.prefect_agent_queue_name
  prefect_api_key = var.prefect_api_key
  prefect_api_url = var.prefect_api_url
  prefect_image = var.prefect_image
}