provider "aws" {
  region = var.aws_region
}

# 🔹 Fetch AWS Account ID dynamically
data "aws_caller_identity" "current" {}

# 🔹 Build ECR image URI dynamically (use DockerHub instead if needed)
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

# 🔐 ECS Task Role – used by app if accessing AWS services (not required now)
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

# 🧱 ECS Task Definition – with logging configured
resource "aws_ecs_task_definition" "drupal_task" {
  family                   = "drupal-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.cpu
  memory                   = var.memory
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  volume {
    name = "drupal-efs-volume"

    efs_volume_configuration {
      file_system_id          = data.terraform_remote_state.efs.outputs.efs_id
      root_directory          = "/"
      transit_encryption      = "ENABLED"
      authorization_config {
        access_point_id = data.terraform_remote_state.efs.outputs.efs_access_point_id
        iam             = "DISABLED"
      }
    }
  }

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
      mountPoints = [
        {
          sourceVolume  = "drupal-efs-volume"
          containerPath = "/var/www/html/web/sites/default/files"
          readOnly      = false
        }
      ],
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/drupal"
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "ecs"
        }
      },
      environment = [
        {
          name  = "DB_NAME"
          value = data.terraform_remote_state.rds.outputs.rds_dbname
        },
        {
          name  = "DB_USER"
          value = data.terraform_remote_state.rds.outputs.rds_username
        },
        {
          name  = "DB_PASS"
          value = data.terraform_remote_state.rds.outputs.rds_password
        },
        {
          name  = "DB_HOST"
          value = data.terraform_remote_state.rds.outputs.rds_endpoint
        }
      ]
    }
  ])
}

# 📊 CloudWatch Log Group for ECS logs
resource "aws_cloudwatch_log_group" "drupal" {
  name              = "/ecs/drupal"
  retention_in_days = 7
}
