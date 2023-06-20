variable "name" {
  type    = string
  default =  "main-eks-vpc"
}

variable "tags" {
  type    = map
  default = { 
    "Name" = "main-eks-vpc"
    } 
}

variable "vpc_tags" {

  type    = map(string)
  default = {
    "Environment" = "staging"
  }
}

variable "igw_tags" {

  type    = map(string)
  default = {
    "Environment" = "staging"
  }
}


variable "azs" {

  type    = list
  default = ["us-east-1a", "us-east-1b"]
}

variable "public_subnets" {

  type    = list
  default = ["10.0.64.0/19", "10.0.96.0/19"]
}


variable "secondary_cidr_blocks" {
  description = "List of secondary CIDR blocks to associate with the VPC to extend the IP Address pool"
  type        = list(string)
  default     = []
}

variable "create_vpc" {
  description = "Controls if VPC should be created (it affects almost all resources)"
  type        = bool
  default     = true
}

variable "create_public_subnets" {

  type    = bool
  default = true
}

variable "map_public_ip_on_launch" {
  description = "Controls if subnet should be map_public_ip_on_launch "
  type        = bool
  default     = true
}
variable "create_igw" {
  description = "Controls if subnet should be create_igw "
  type        = bool
  default     = true
}
variable "create_egress_only_igw" {
  description = "Controls if subnet should be create_igw "
  type        = bool
  default     = true
}

output "public_subnets" {
  description = "List of IDs of public subnets"
  value       = aws_subnet.public[*].id
}



variable "public_subnet_names" {
  description = "Explicit values to use in the Name tag on public subnets. If empty, Name tags are generated"
  type        = list(string)
  default     = ["eks-public-subnet1","eks-public-subnet2"]
}

variable "public_subnet_suffix" {
  description = "Suffix to append to public subnets name"
  type        = string
  default     = "public"
}


variable "public_subnet_tags" {
  description = "Additional tags for the public subnets"
  type        = map(string)
  default     = { 
    "Name" = "eks-vpc-public-subnet"
  }
}

variable "public_subnet_tags_per_az" {
  description = "Additional tags for the public subnets where the primary key is the AZ"
  type        = map(map(string))
  default     = { 
    AZ = {"az-name" = "az1", "az-name" = "az2"}
  }
}

variable "public_route_table_tags" {
  description = "Additional tags for the public route tables"
  type        = map(string)
  default     = {
    Name = "eks-public-subnet-route-table"
  }
}

variable "public_subnet_ipv6_native" {
  type        = bool
  default     = false
}

variable "create_private_subnets" {

  type    = bool
  default = true
}


variable "private_subnets" {

  type    = list
  default = ["10.0.20.0/19", "10.0.25.0/19"]
}


variable "private_subnet_names" {
  description = "Explicit values to use in the Name tag on public subnets. If empty, Name tags are generated"
  type        = list(string)
  default     = ["eks-public-subnet1","eks-public-subnet2"]
}

variable "private_subnet_suffix" {
  description = "Suffix to append to public subnets name"
  type        = string
  default     = "public"
}


variable "private_subnet_tags" {
  description = "Additional tags for the public subnets"
  type        = map(string)
  default     = { 
    "Name" = "eks-vpc-public-subnet"
  }
}

variable "private_subnet_tags_per_az" {
  description = "Additional tags for the public subnets where the primary key is the AZ"
  type        = map(map(string))
  default     = { 
    AZ = {"az-name" = "az1", "az-name" = "az2"}
  }
}

variable "private_subnet_private_dns_hostname_type_on_launch" {
  description = "The type of hostnames to assign to instances in the subnet at launch. For IPv6-only subnets, an instance DNS name must be based on the instance ID. For dual-stack and IPv4-only subnets, you can specify whether DNS names use the instance IPv4 address or the instance ID. Valid values: `ip-name`, `resource-name`"
  type        = string
  default     = "ip-name"
}


variable "private_route_table_tags" {
  description = "Additional tags for the public subnets"
  type        = map(string)
  default     = { 
    "Name" = "eks-vpc-private-route-table"
  }
}
variable "private_subnet_ipv6_native" {
  type        = bool
  default     = false
}


variable "reuse_nat_ips" {
  description = "Should be true if you don't want EIPs to be created for your NAT Gateways and will instead pass them in via the 'external_nat_ip_ids' variable"
  type        = bool
  default     = false
}

# output "nat_ids" {
#   description = "List of allocation ID of Elastic IPs created for AWS NAT Gateway"
#   value       = aws_eip.nat[*].id
# }
  
variable "enable_nat_gateway" {

  type    = bool
  default = true
}
variable "single_nat_gateway" {

  type    = bool
  default = true
}
variable "one_nat_gateway_per_az" {

  type    = bool
  default = false
}

variable "nat_gateway_destination_cidr_block" {
  description = "Used to pass a custom destination route for private NAT Gateway. If not specified, the default 0.0.0.0/0 is used as a destination route"
  type        = string
  default     = "0.0.0.0/0"
}

# output "nat_public_ips" {
#   description = "List of public Elastic IPs created for AWS NAT Gateway"
#   value       = var.reuse_nat_ips ? var.external_nat_ips : aws_eip.nat[*].public_ip
# }

output "natgw_ids" {
  description = "List of NAT Gateway IDs"
  value       = aws_nat_gateway.this[*].id
}



variable "external_nat_ip_ids" {
  description = "List of EIP IDs to be assigned to the NAT Gateways (used in combination with reuse_nat_ips)"
  type        = list(string)
  default     = []
}

variable "external_nat_ips" {
  description = "List of EIPs to be used for `nat_public_ips` output (used in combination with reuse_nat_ips and external_nat_ip_ids)"
  type        = list(string)
  default     = []
}

variable "nat_gateway_tags" {
  description = "Additional tags for the NAT gateways"
  type        = map(string)
  default     = {}
}

variable "nat_eip_tags" {
  description = "Additional tags for the NAT EIP"
  type        = map(string)
  default     = {}
}
