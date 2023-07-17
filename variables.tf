variable "account_id" {
  type    = string
  default = "886192468297"
}

variable "region" {
  type    = string
  default = "ap-southeast-2"
}

variable "environment" {
    type = string
    default = "test"
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