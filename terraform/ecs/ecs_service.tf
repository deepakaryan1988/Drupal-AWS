resource "aws_ecs_service" "drupal" {
  name            = "drupal-service"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.drupal_task.arn
  launch_type     = "FARGATE"
  desired_count   = 1

  network_configuration {
    subnets          = data.terraform_remote_state.network.outputs.public_subnet_ids
    security_groups  = [data.terraform_remote_state.network.outputs.security_group_id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.this.arn
    container_name   = var.container_name
    container_port   = 80
  }

  depends_on = [aws_lb_listener.http]
}
