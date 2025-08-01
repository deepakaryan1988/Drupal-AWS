provider "aws" {
  region = "ap-south-1"
}

# 🔗 Reference outputs from the Network module's remote state
data "terraform_remote_state" "network" {
  backend = "local"
  config = {
    path = "../network/terraform.tfstate"
  }
}

# 🔍 Get default VPC by tag or use your specific one
locals {
  vpc_id = data.terraform_remote_state.network.outputs.vpc_id
}

# 🔍 Fetch public subnets dynamically
data "aws_subnets" "public" {
  filter {
    name   = "tag:Name"
    values = ["public-subnet-*"]
  }

  filter {
    name   = "vpc-id"
    values = [local.vpc_id]
  }
}

# 🔍 Get ECS SG by tag or name
data "aws_security_group" "ecs" {
  filter {
    name   = "tag:Name"
    values = ["ecs-sg"]
  }
  vpc_id = local.vpc_id
}

resource "aws_db_subnet_group" "drupal" {
  name       = "drupal-rds-subnet-group"
  subnet_ids = data.aws_subnets.public.ids

  tags = {
    Name = "drupal-subnet-group"
  }
}

resource "aws_security_group" "drupal_rds_sg" {
  name        = "drupal-rds-sg"
  description = "Allow MySQL from ECS"
  vpc_id      = local.vpc_id

  ingress {
    description     = "MySQL from ECS"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [data.aws_security_group.ecs.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "drupal-rds-sg"
  }
}

resource "aws_db_instance" "drupal" {
  identifier             = "drupal-db"
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  db_name                = var.db_name
  username               = var.db_username
  password               = var.db_password
  skip_final_snapshot    = true
  publicly_accessible    = true
  vpc_security_group_ids = [aws_security_group.drupal_rds_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.drupal.name

  tags = {
    Name = "drupal-db"
  }
}

