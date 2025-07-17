provider "aws" {
  region = var.aws_region
}

# 🔹 Fetch AWS Account ID dynamically
data "aws_caller_identity" "current" {}

# 🔹 Build ECR image URI dynamically
locals {
  ecr_image_url = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/${var.repository_name}:latest"
}

# 🔐 ECS Task Execution Role – allows ECS to pull image and write logs
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExecutionRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Effect = "Allow"
        Sid    = ""
      }
    ]
  })

  tags = {
    Name = "ECS Execution Role"
  }
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# 🔐 ECS Task Role – used by your app to access AWS services (Secrets Manager, RDS, etc.)
resource "aws_iam_role" "ecs_task_role" {
  name = "ecsTaskRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Effect = "Allow"
        Sid    = ""
      }
    ]
  })

  tags = {
    Name = "ECS Task Role"
  }
}

# 🧱 ECS Task Definition – runs your Drupal container from ECR
resource "aws_ecs_task_definition" "drupal_task" {
  family                   = "drupal-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.cpu
  memory                   = var.memory
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([
    {
      name      = var.container_name
      image     = local.ecr_image_url
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
          protocol      = "tcp"
        }
      ],
      environment = [
        {
          name  = "DRUPAL_DB_HOST"
          value = "placeholder"
        },
        {
          name  = "DRUPAL_DB_NAME"
          value = "drupal"
        },
        {
          name  = "DRUPAL_DB_USER"
          value = "drupal"
        },
        {
          name  = "DRUPAL_DB_PASSWORD"
          value = "drupal"
        }
      ]
    }
  ])
}
