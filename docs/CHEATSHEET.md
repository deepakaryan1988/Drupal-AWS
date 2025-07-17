# 📘 DevOps Cheatsheet – Drupal on AWS with Terraform (Fargate + ALB)

This guide summarizes everything implemented in your `Drupal-AWS` project so far, using modular Terraform to deploy a containerized Drupal application via ECS Fargate, exposed through an ALB, and sourced from ECR.

---

## 🔧 Terraform Modules Overview

| Module     | Purpose                               |
| ---------- | ------------------------------------- |
| `network/` | VPC, public subnets, shared SG        |
| `ecr/`     | ECR repo for Docker image             |
| `ecs/`     | ECS cluster, task definition, service |
| `docker/`  | Drupal and NGINX Dockerfiles          |
| `scripts/` | Utility shell scripts (if any)        |

---

## 📦 ECR – Container Registry

```hcl
resource "aws_ecr_repository" "devops_ecr_repo" {
  name = var.repository_name
  image_tag_mutability = "MUTABLE"
  force_delete         = true

  image_scanning_configuration {
    scan_on_push = true
  }
}
```

* 🔁 Push Docker image manually:

  ```bash
  docker tag local-image:latest <aws_account_id>.dkr.ecr.<region>.amazonaws.com/devops-ecr-deepak:latest
  docker push <...>
  ```

---

## 🧱 ECS Task Definition (Fargate)

```hcl
resource "aws_ecs_task_definition" "drupal_task" {
  family                   = "drupal-task"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.cpu
  memory                   = var.memory
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([
    {
      name        = var.container_name
      image       = local.ecr_image_url
      essential   = true
      portMappings = [{ containerPort = 80 }]
      environment  = [...] # DB env vars
    }
  ])
}
```

---

## 🛰️ ECS Cluster + Service

```hcl
resource "aws_ecs_cluster" "this" {
  name = "drupal-cluster"
}

resource "aws_ecs_service" "drupal" {
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.drupal_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = data.terraform_remote_state.network.outputs.public_subnet_ids
    security_groups = [data.terraform_remote_state.network.outputs.security_group_id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.this.arn
    container_name   = var.container_name
    container_port   = 80
  }
}
```

---

## 🌐 ALB + Listener + Target Group

```hcl
resource "aws_lb" "this" {
  name               = "drupal-alb"
  internal           = false
  load_balancer_type = "application"
  subnets            = data.terraform_remote_state.network.outputs.public_subnet_ids
  security_groups    = [aws_security_group.alb_sg.id]
}

resource "aws_lb_target_group" "this" {
  name     = "drupal-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.terraform_remote_state.network.outputs.vpc_id

  health_check {
    path                = "/"
    matcher             = "200-399"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }
}
```

---

## 🔐 IAM Roles

### Task Execution Role (pull image, write logs):

```hcl
resource "aws_iam_role" "ecs_task_execution_role" {
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Principal = { Service = "ecs-tasks.amazonaws.com" },
      Effect = "Allow"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}
```

---

## 📤 Outputs

```hcl
output "alb_dns_name" {
  value = aws_lb.this.dns_name
}
```

---

## 🧠 Terraform Tips

* ✅ Use `terraform_remote_state` to fetch VPC, subnets from `network` layer
* ✅ Avoid hardcoding AWS Account ID by using:

  ```hcl
  data "aws_caller_identity" "current" {}
  ```
* ✅ Use `locals` for dynamic values like image URL
* ✅ Split large configs across files: `alb.tf`, `ecs_service.tf`, etc.

---

## 💬 DevOps Interview Soundbite

> "I built a Dockerized Drupal app, pushed to ECR, and deployed it using ECS Fargate with ALB routing and modular Terraform. I used IAM roles, dynamic image paths, remote state outputs, and designed it for reusability across projects."

---

Next up: \[ ] RDS Integration | \[ ] Secrets Manager | \[ ] CI/CD with GitHub Actions
