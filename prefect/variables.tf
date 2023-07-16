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

variable "cpu" {
  type    = number
  description = "CPU configuration"
  default = 512
}

variable "memory" {
  type    = number
  description = "Memory configuration"
  default = 1024
}

variable "prefect_image" {
  type    = string
  description = "Docker image for the service"
  default = "prefecthq/prefect:2-python3.10"
}