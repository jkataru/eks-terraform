resource "aws_ecs_service" "ecs_service" {
  name            = var.service_name
  cluster         = var.cluster_id
  task_definition = var.task_definition
  desired_count   = var.desired_count

  network_configuration {
    subnets          = var.subnets
    security_groups  = var.security_groups
    assign_public_ip = var.assign_public_ip
  }

  capacity_provider_strategy {
    capacity_provider = "FARGATE"
    weight            = 50
    base              = 20
  }

  lifecycle {
    ignore_changes = [triggers]
  }

  force_new_deployment              = var.force_new_deployment
  health_check_grace_period_seconds = var.health_check_grace_period_seconds

  dynamic "load_balancer" {
    for_each = var.target_group_arn != null ? toset(var.target_group_arn) : []
    content {
      target_group_arn = load_balancer.value
      container_name   = var.container_name
      container_port   = var.container_port
    }
  }

}
