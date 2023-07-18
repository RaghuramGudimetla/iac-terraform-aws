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
}

variable "prefect_api_url" {
  type    = string
  description = "Prefect remote API URL"
}

variable "prefect_api_key" {
  type    = string
  description = "Prefect remote API key"
}

variable "prefect_agent_queue_name" {
  type    = string
  description = "Prefect agent queue name"
}