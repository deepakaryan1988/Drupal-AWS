variable "aws_region" {
  default = "ap-south-1"
}

variable "ecr_image_url" {
  description = "Docker image URI from ECR"
  default     = "442740305597.dkr.ecr.ap-south-1.amazonaws.com/devops-ecr-deepak"
}

variable "container_name" {
  default = "drupal-aws-container"
}

variable "ecs_cluster_name" {
  default = "drupal-ecs-cluster"
}

variable "ecs_service_name" {
  default = "drupal-ecs-service"
}

variable "cpu" {
  default = "256"
}

variable "memory" {
  default = "512"
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs"
  type        = list(string)
}

variable "security_group_id" {
  description = "Security group ID for ECS service"
  type        = string
}
