output "main_vpc_id" {
  value       = aws_vpc.main_vpc[0].id
  description = "ID of the main VPC created by the networking module"
}


output "public_subnet_ids" {
  value = [for subnet in aws_subnet.public_subnet : subnet.id]
  description = "IDs of public subnets created by the networking module"
}

output "private_subnet_ids" {
  value = [for subnet in aws_subnet.private_subnet : subnet.id]
  description = "IDs of private subnets created by the networking module"
}