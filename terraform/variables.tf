variable "aws_region" {
  description = "aws region for all resources"
  type        = string
  default     = "eu-west-2"
}


variable "ec2_key_name" {
  description = "ec2 key pair name for SSH access" //temp
  type        = string
  default     = null
}

variable "app_image_tag" {
  description = "Container image tag to deploy"
  type        = string
  default     = "latest"
}

variable "db_name" {
  description = "db name"
  type        = string
  default     = "events"
}

variable "db_username" {
  description = "db username"
  type        = string
  default     = "postgres"
}

variable "db_password" {
  description = "db password"
  type        = string
  sensitive   = true
}


variable "app_port" {
  description = "application listen port"
  type        = number
  default     = 8080
}

