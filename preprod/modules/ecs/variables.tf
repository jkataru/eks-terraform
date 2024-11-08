# ecs/variables.tf

variable "family" {
  description = "Family of the ECS Task Definition"
  type        = string
}

variable "execution_role_arn" {
  description = "ARN of the execution role for ECS Task"
  type        = string
}

variable "task_role_arn" {
  description = "ARN of the task role for ECS Task"
  type        = string
}

variable "cpu" {
  description = "Number of CPU units for the ECS task"
  type        = number
}

variable "memory" {
  description = "Amount of memory for the ECS task"
  type        = number
}

variable "operating_system_family" {
  description = "Operating system family (e.g., LINUX)"
  type        = string
}

variable "cpu_architecture" {
  description = "CPU architecture (e.g., X86_64)"
  type        = string
}

# variable "container_definitions" {
#   description = "JSON-encoded container definitions"
#   type        = string
# }
variable "task_definition" {
  
}
variable "service_name" {
  description = "Name of the ECS Service"
  type        = string
}

variable "cluster_id" {
  description = "ECS Cluster ID"
  type        = string
}

variable "desired_count" {
  description = "Number of desired tasks"
  type        = number
  default     = 1
}

variable "subnets" {
  description = "Subnets for the ECS service"
  type        = list(string)
}

variable "security_groups" {
  description = "Security groups for the ECS service"
  type        = list(string)
}

variable "assign_public_ip" {
  description = "Whether to assign a public IP"
  type        = bool
  default     = true
}

variable "force_new_deployment" {
  description = "Force a new ECS deployment"
  type        = bool
  default     = true
}

variable "health_check_grace_period_seconds" {
  description = "Grace period for health checks"
  type        = number
  default     = 600
}

variable "target_group_arn" {
  description = "ARN of the load balancer target group"
  type        = list(string)
}

variable "container_name" {
  description = "Name of the container"
  type        = string
}

variable "container_port" {
  description = "Port of the container"
  type        = number
}