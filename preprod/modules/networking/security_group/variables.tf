variable "name" {
  description = "This is the ECS cluster name"
  type        = string
}
variable "vpc_id" {
  description = "This is the ECS cluster name"
  type        = string
}


variable "sg_source" {
  description = "The source security group ID to allow ingress traffic"
  type        = string
  default     = null  # Make it optional
}
variable "inbound_rules" {
  type = list(object({
    from_port      = number
    to_port        = number
    protocol       = string
    cidr_blocks    = optional(list(string), [])
    source_sg_ids  = optional(list(string), [])
  }))
}
