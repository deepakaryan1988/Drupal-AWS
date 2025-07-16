# Debugging and Fixing ECS Task Failure Due to Hardcoded Security Group

## 1. Problem Summary

ECS tasks for the Drupal service were consistently failing to launch, entering a `stopped` state shortly after being provisioned. Examination of the stopped tasks and associated ENIs (Elastic Network Interfaces) revealed that the service was attempting to use a security group that no longer existed. This resulted in network timeouts and prevented the container from communicating with other services or being reached by the load balancer.

## 2. Root Cause

The root cause of the failure was a **hardcoded security group ID** in the `aws_ecs_service` resource definition within the `terraform/ecs/main.tf` configuration.

The infrastructure is split into two separate Terraform configurations:
- `terraform/network/`: Manages the VPC, subnets, and security groups.
- `terraform/ecs/`: Manages the ECS cluster, task definitions, and services.

A recent update to the `network` stack replaced the old security group with a new one. Because the `ecs` configuration contained a static, hardcoded reference to the old ID, it was never updated to point to the new resource. This left the ECS service in a broken state, referencing a deleted resource.

## 3. Solution Overview

The solution was to create a dynamic link between the `network` and `ecs` configurations. Instead of hardcoding values, we now use a `terraform_remote_state` data source within the `ecs` stack.

This data source reads the `outputs` from the `network` stack's state file at plan/apply time. By doing this, the `ecs` service can now dynamically access the correct, up-to-date IDs for the public subnets and the security group, eliminating the risk of stale references. This approach ensures that any changes to the network infrastructure are automatically propagated to the ECS service on the next apply.

## 4. Code Changes Made

The fix required two key changes in the `terraform/ecs/main.tf` file.

**A. Added a `terraform_remote_state` Data Source:**

This block was added to fetch the outputs from the network stack's state file.

```hcl
data "terraform_remote_state" "network" {
  backend = "local"

  config = {
    path = "../network/terraform.tfstate"
  }
}
```

**B. Updated the ECS Service `network_configuration`:**

The `network_configuration` block was modified to reference the outputs from the remote state, replacing the hardcoded IDs.

```hcl
resource "aws_ecs_service" "this" {
  # ... other arguments
  name            = var.ecs_service_name
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.this.arn
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = data.terraform_remote_state.network.outputs.public_subnet_ids
    assign_public_ip = true
    security_groups  = [data.terraform_remote_state.network.outputs.security_group_id]
  }
}
```

## 5. Lessons Learned

This incident provided several important reminders about Infrastructure-as-Code best practices:

- **Avoid Hardcoded Values:** Hardcoding resource IDs or other dynamic values between configurations is extremely brittle and a common source of errors.
- **Outputs as an Interface:** A Terraform configuration's `outputs.tf` file should be treated as its public API. It defines a clear contract for other configurations to consume its resources.
- **Wire Stacks Together:** For multi-stack architectures, `terraform_remote_state` is the standard mechanism for creating dependencies and sharing data, ensuring configurations remain in sync.

## 6. Best Practices for the Future

To prevent similar issues, the team should adhere to the following practices:

- **Always Reference, Never Hardcode:** When a resource in one stack depends on a resource from another, always use a data source (like `terraform_remote_state`) to reference it.
- **Enforce Stack Decoupling:** Continue to structure infrastructure into logical, decoupled stacks (e.g., network, security, compute, data). This improves modularity, reusability, and maintainability.
- **Define Clear Output Contracts:** For every stack, explicitly define all resources that may be needed by other stacks in the `outputs.tf` file with clear, consistent naming.
- **Review `terraform plan` Carefully:** Always inspect the output of `terraform plan` before applying. A plan to destroy a resource that other services depend on is a major red flag that should be investigated.
