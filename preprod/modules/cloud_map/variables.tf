variable "namespace_id" {
  description = "The ID of the Cloud Map namespace."
  type        = string
}

variable "service_name" {
  description = "The name of the Cloud Map service."
  type        = string
}
variable "aws_region" {
  description = "The name of the Cloud Map service."
  type        = string
}
variable "aws_cloud_map_availability_zone" {
  description = "The name of the Cloud Map service."
  type        = string
}
variable "cluster_name" {
  description = "The name of the cluster_name."
  type        = string
}

variable "ttl" {
  description = "TTL for DNS records."
  type        = number
  default     = 60
}

variable "failure_threshold" {
  description = "The number of health check failures that must occur before a service is considered unhealthy."
  type        = number
  default     = 1
}

variable "instance_id" {
  description = "The instance ID for the service discovery instance"
  type        = string
}

variable "aws_instance_ipv4" {
  description = "The IPv4 address for the instance"
  type        = string
}


variable "ecs_service_name" {
  description = "The ECS service name"
  type        = string
}

variable "ecs_task_definition_family" {
  description = "The ECS task definition family"
  type        = string
}