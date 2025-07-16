provider "aws" {
  region = var.aws_region
}

resource "aws_ecr_repository" "devops_ecr_repo" {
  name = var.repository_name

  image_tag_mutability = "MUTABLE"
  force_delete         = true

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name        = var.repository_name
    Environment = "dev"
    ManagedBy   = "terraform"
  }
}
