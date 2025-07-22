terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "ap-south-1"
}

data "terraform_remote_state" "network" {
  backend = "local"
  config = {
    path = "../network/terraform.tfstate"
  }
}

resource "aws_efs_file_system" "this" {
  creation_token = "drupal-efs"
  tags = {
    Name        = "drupal-efs"
    Environment = "dev"
    Project     = "drupal-aws"
  }
}

resource "aws_efs_mount_target" "this" {
  for_each = toset(data.terraform_remote_state.network.outputs.public_subnet_ids)

  file_system_id  = aws_efs_file_system.this.id
  subnet_id       = each.value
  security_groups = [data.terraform_remote_state.network.outputs.security_group_id]
}

resource "aws_efs_access_point" "drupal_ap" {
  file_system_id = aws_efs_file_system.this.id

  posix_user {
    uid = var.efs_uid
    gid = var.efs_gid
  }

  root_directory {
    path = "/"
    creation_info {
      owner_uid   = var.efs_uid
      owner_gid   = var.efs_gid
      permissions = "0755"
    }
  }

  tags = {
    Name = "drupal-efs-ap"
  }
}
