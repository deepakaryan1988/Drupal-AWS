variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "ap-south-1"
}

variable "container_name" {
  description = "Name of the container"
  type        = string
  default     = "drupal"
}

variable "cpu" {
  description = "CPU units for the ECS task"
  type        = number
  default     = 256
}

variable "memory" {
  description = "Memory in MiB for the ECS task"
  type        = number
  default     = 512
}

variable "repository_name" {
  description = "ECR repo name (used to build image URL)"
  type        = string
  default     = "devops-ecr-deepak"
}
