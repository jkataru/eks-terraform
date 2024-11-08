# alb/variables.tf

variable "lb_name" {
  description = "The name of the Load Balancer"
  type        = string
}

variable "internal" {
  description = "Boolean to determine if the load balancer is internal or not"
  type        = bool
  default     = false
}

variable "security_groups" {
  description = "List of security groups for the ALB"
  type        = list(string)
}

variable "subnets" {
  description = "List of subnets for the ALB"
  type        = list(string)
}

variable "tags" {
  description = "Tags for the ALB"
  type        = map(string)
}

variable "certificate_arn" {
  description = "ARN of the SSL certificate for HTTPS listener"
  type        = string
}

variable "target_group_name" {
  description = "Name of the target group"
  type        = string
}

variable "target_group_port" {
  description = "Port for the target group"
  type        = number
  default     = 80
}

variable "listnerport" {
  description = "Port for the target group"
  type        = number
  default     = 5574
}

variable "target_group_protocol" {
  description = "Protocol for the target group"
  type        = string
  default     = "HTTP"
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "health_check_path" {
  description = "Health check path"
  type        = string
  default     = "/"
}