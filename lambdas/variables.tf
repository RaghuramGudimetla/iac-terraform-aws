variable "account_id" {
  type    = string
}

variable "region" {
  type    = string
}

variable "environment" {
  type    = string
}

variable "data_wrangler_layer" {
  type    = string
  description = "AWS Data Wrangler"
  default = "arn:aws:lambda:ap-southeast-2:336392948345:layer:AWSDataWrangler-Python39:5"
}