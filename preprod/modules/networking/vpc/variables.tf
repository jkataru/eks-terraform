variable "cluster_name" {
  description = "This is the ECS cluster name"
  type        = string
}
variable "cidr_block" {
  description = "This is the CIDR of choosen network"
  type        = string
  default     = "10.0.0.0/16"
}
variable "public_subnet_cidrs" {
  description = "List of CIDRs for the private subnets"
  type        = map(string)
default = {
    "0" = "10.0.1.0/24"
    "1" = "10.0.2.0/24"
  }
}
variable "private_subnet_cidrs" {
  description = "List of CIDRs for the private subnets"
  type        = map(string)
default = {
    "0" = "10.0.3.0/24"
    "1" = "10.0.4.0/24"
  }
}
variable "private_subnet_enable" {
  description = "Enable or disable the private subnet"
  type        = bool
  default     = false
}
variable "public_subnet_enable" {
  description = "Enable or disable the private subnet"
  type        = bool
  default     = false
}

variable "new_vpc_create" {
  type    = bool
  default = true
}

variable "existing_vpc_id" {
  type    = string
  default = ""
  description = "ID of the existing VPC to use if new_vpc_create is false"
}
