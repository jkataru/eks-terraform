output "service_id" {
  description = "The ID of the service in AWS Service Discovery."
  value       = aws_service_discovery_service.this.id
}
