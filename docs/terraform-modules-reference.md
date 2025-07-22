# Terraform Modules Reference Guide

This document provides a comprehensive reference of all Terraform modules, their variables, outputs, and cross-module dependencies for the Drupal-AWS infrastructure.

## Module Overview

The infrastructure is organized into the following modules:
- **network**: VPC, subnets, security groups, and routing
- **ecr**: Elastic Container Registry for Docker images
- **rds**: Relational Database Service (MySQL)
- **ecs**: Elastic Container Service with ALB
- **ec2**: EC2 instances (basic configuration)

---

## 1. Network Module (`terraform/network/`)

### Variables (`variables.tf`)
| Variable Name | Type | Default Value | Description |
|---------------|------|---------------|-------------|
| `aws_region` | string | `"ap-south-1"` | AWS region |
| `vpc_cidr` | string | `"10.0.0.0/16"` | VPC CIDR block |
| `public_subnet_cidrs` | list | `["10.0.1.0/24", "10.0.2.0/24"]` | Public subnet CIDR blocks |
| `availability_zones` | list | `["ap-south-1a", "ap-south-1b"]` | Availability zones |
| `app_port` | number | `8080` | Application port |
| `allowed_ingress_ports` | list(number) | `[80]` | List of ports to allow in security group |

### Outputs (`outputs.tf`)
| Output Name | Value | Description |
|-------------|-------|-------------|
| `vpc_id` | `aws_vpc.main.id` | VPC ID |
| `public_subnet_ids` | `[for subnet in aws_subnet.public : subnet.id]` | List of public subnet IDs |
| `security_group_id` | `aws_security_group.ecs_sg.id` | ECS security group ID |

### Remote State Configuration
- **Backend Type**: Local
- **State File Path**: `../network/terraform.tfstate`
- **Used By**: ECS module

---

## 2. ECR Module (`terraform/ecr/`)

### Variables (`variables.tf`)
| Variable Name | Type | Default Value | Description |
|---------------|------|---------------|-------------|
| `aws_region` | string | `"ap-south-1"` | Default AWS region |
| `repository_name` | string | `"devops-ecr-deepak"` | ECR repository name |

### Outputs (`outputs.tf`)
| Output Name | Value | Description |
|-------------|-------|-------------|
| `ecr_repository_url` | `aws_ecr_repository.devops_ecr_repo.repository_url` | ECR repository URL |

### Remote State Configuration
- **Backend Type**: None (standalone module)
- **Used By**: None (referenced by ECS module via variable)

---

## 3. RDS Module (`terraform/rds/`)

### Variables (`variables.tf`)
| Variable Name | Type | Default Value | Description |
|---------------|------|---------------|-------------|
| `db_name` | string | `"drupaldb"` | Name of the RDS database |
| `db_username` | string | `"admin"` | Database username |
| `db_password` | string | `"Deepak_12345!"` | Database password |

### Outputs (`outputs.tf`)
| Output Name | Value | Description |
|-------------|-------|-------------|
| `rds_endpoint` | `aws_db_instance.drupal.endpoint` | RDS endpoint |
| `rds_username` | `var.db_username` | Database username |
| `rds_password` | `var.db_password` | Database password |
| `rds_dbname` | `var.db_name` | Database name |

### Remote State Configuration
- **Backend Type**: None (standalone module)
- **Used By**: None (referenced by ECS module via variable)

---

## 4. ECS Module (`terraform/ecs/`)

### Variables (`variables.tf`)
| Variable Name | Type | Default Value | Description |
|---------------|------|---------------|-------------|
| `aws_region` | string | `"ap-south-1"` | AWS region to deploy resources |
| `container_name` | string | `"drupal"` | Name of the container |
| `cpu` | number | `256` | CPU units for the ECS task |
| `memory` | number | `512` | Memory in MiB for the ECS task |
| `repository_name` | string | `"devops-ecr-deepak"` | ECR repo name (used to build image URL) |

### Outputs (`outputs.tf`)
| Output Name | Value | Description |
|-------------|-------|-------------|
| `alb_dns_name` | `aws_lb.this.dns_name` | Application Load Balancer DNS name |

### Remote State Configuration
- **Backend Type**: Local
- **State File Path**: `../network/terraform.tfstate`
- **Data Source**: `data.terraform_remote_state.network`

### Cross-Module Dependencies
The ECS module depends on the Network module and references:
- `data.terraform_remote_state.network.outputs.vpc_id`
- `data.terraform_remote_state.network.outputs.public_subnet_ids`
- `data.terraform_remote_state.network.outputs.security_group_id`

---

## 5. EC2 Module (`terraform/ec2/`)

### Variables (`variables.tf`)
- **No variables file found** - module uses hardcoded values

### Outputs (`outputs.tf`)
| Output Name | Value | Description |
|-------------|-------|-------------|
| `instance_ip` | `aws_instance.web.public_ip` | EC2 instance public IP |

### Remote State Configuration
- **Backend Type**: None (standalone module)
- **Used By**: None

---

## Cross-Module Reference Patterns

### Current Remote State Usage

#### ECS Module → Network Module
```hcl
# In terraform/ecs/data.tf
data "terraform_remote_state" "network" {
  backend = "local"
  config = {
    path = "../network/terraform.tfstate"
  }
}

# Usage examples:
vpc_id = data.terraform_remote_state.network.outputs.vpc_id
subnet_ids = data.terraform_remote_state.network.outputs.public_subnet_ids
security_group_id = data.terraform_remote_state.network.outputs.security_group_id
```

### Recommended Cross-Module References

#### ECS Module → RDS Module
```hcl
# Add to terraform/ecs/data.tf
data "terraform_remote_state" "rds" {
  backend = "local"
  config = {
    path = "../rds/terraform.tfstate"
  }
}

# Usage in ECS task definition:
environment = [
  {
    name  = "DB_HOST"
    value = data.terraform_remote_state.rds.outputs.rds_endpoint
  },
  {
    name  = "DB_NAME"
    value = data.terraform_remote_state.rds.outputs.rds_dbname
  }
]
```

#### ECS Module → ECR Module
```hcl
# Add to terraform/ecs/data.tf
data "terraform_remote_state" "ecr" {
  backend = "local"
  config = {
    path = "../ecr/terraform.tfstate"
  }
}

# Usage in ECS task definition:
image = "${data.terraform_remote_state.ecr.outputs.ecr_repository_url}:latest"
```

---

## Module Deployment Order

Based on dependencies, the recommended deployment order is:

1. **Network Module** (foundation)
2. **ECR Module** (container registry)
3. **RDS Module** (database)
4. **ECS Module** (application - depends on network, ECR, RDS)
5. **EC2 Module** (optional - standalone)

---

## State Management Recommendations

### Current State
- **Backend**: Local file system
- **State Files**: Separate state files for each module
- **Remote State**: ECS module uses local remote state to reference Network module

### Recommended Improvements
1. **Migrate to S3 Backend**: For team collaboration and state locking
2. **Use Terraform Workspaces**: For environment separation (dev/staging/prod)
3. **Implement State Encryption**: For sensitive data protection
4. **Add DynamoDB Locking**: For concurrent access protection

### S3 Backend Configuration Example
```hcl
# In each module's main.tf
terraform {
  backend "s3" {
    bucket         = "drupal-aws-terraform-state"
    key            = "network/terraform.tfstate"
    region         = "ap-south-1"
    encrypt        = true
    dynamodb_table = "terraform-locks"
  }
}
```

---

## Security Considerations

### Sensitive Variables
- **RDS Password**: Currently hardcoded in variables (should use AWS Secrets Manager)
- **Database Credentials**: Exposed in outputs (should be secured)

### Recommendations
1. **Use AWS Secrets Manager** for database passwords
2. **Implement Variable Validation** for critical parameters
3. **Add Resource Tagging** for cost tracking and security
4. **Enable CloudTrail** for audit logging

---

## Cost Optimization

### Resource Sizing
- **ECS CPU/Memory**: Currently set to minimum (256 CPU, 512 MiB)
- **RDS Instance**: Currently db.t3.micro (suitable for development)
- **ALB**: Pay-per-request model

### Recommendations
1. **Implement Auto Scaling** for ECS services
2. **Use RDS Reserved Instances** for production
3. **Enable RDS Multi-AZ** for high availability
4. **Implement Cost Alerts** and monitoring

---

## Next Steps

1. **Implement EFS Integration** for persistent storage
2. **Add CI/CD Pipeline** for automated deployments
3. **Implement Monitoring and Alerting**
4. **Add Backup and Disaster Recovery** procedures
5. **Migrate to Remote State Backend** (S3 + DynamoDB)
