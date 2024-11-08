resource "aws_service_discovery_service" "this" {
  name = var.service_name

  dns_config {
    namespace_id = var.namespace_id
    dns_records {
      type = "A"
      ttl  = var.ttl
    }
  }

  health_check_custom_config {
    failure_threshold = var.failure_threshold
  }
}

resource "aws_service_discovery_instance" "app_instance" {
  service_id = aws_service_discovery_service.this.id
  instance_id = var.instance_id
  attributes = {
    "AWS_INIT_HEALTH_STATUS"      = "HEALTHY"
    "AVAILABILITY_ZONE"           = var.aws_cloud_map_availability_zone
    "ECS_CLUSTER_NAME"            = var.cluster_name
    "ECS_SERVICE_NAME"            = var.ecs_service_name
    "REGION"                      = var.aws_region
    "ECS_TASK_DEFINITION_FAMILY"  = var.ecs_task_definition_family
    AWS_INSTANCE_IPV4             = var.aws_instance_ipv4
  }
}