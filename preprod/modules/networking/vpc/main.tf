

resource "aws_vpc" "main_vpc" {
  count = var.new_vpc_create ? 1 : 0

  cidr_block = var.cidr_block
  enable_dns_support  = true
  enable_dns_hostnames = true

  tags = {
    Name = var.cluster_name
  }
}
data "aws_region" "current" {}

resource "aws_subnet" "public_subnet" {
  for_each = var.public_subnet_enable ? var.public_subnet_cidrs : {}

  vpc_id                  = local.vpc_id
  cidr_block              = each.value
  availability_zone       = data.aws_availability_zones.available.names[each.key]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.cluster_name}-public-subnet-${each.key}"
  }
}


resource "aws_subnet" "private_subnet" {
  for_each = var.private_subnet_enable ? var.private_subnet_cidrs : {}

  vpc_id                  = local.vpc_id
  cidr_block              = each.value
  availability_zone       = data.aws_availability_zones.available.names[each.key]
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.cluster_name}-private-subnet-${each.key}"
  }
}

resource "aws_route_table" "public_route" {
  count = var.public_subnet_enable ? 1 : 0
  vpc_id = local.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main_igw[0].id
  }

  tags = {
    Name = "${var.cluster_name}-public-route-table"
  }
}



resource "aws_internet_gateway" "main_igw" {
  count  = var.new_vpc_create ? 1 : 0
  vpc_id = local.vpc_id

  tags = {
    Name = "${var.cluster_name}-InternetGateway"
  }
}

data "aws_availability_zones" "available" {}

resource "aws_route_table_association" "public_main_associate" {
  for_each = var.public_subnet_enable ? aws_subnet.public_subnet : {}

  subnet_id     = each.value.id
  route_table_id = aws_route_table.public_route["public"].id
}


resource "aws_nat_gateway" "main_natg" {
  count = var.private_subnet_enable ? 1 : 0

  subnet_id     = aws_subnet.public_subnet[0].id

  tags = {
    Name = "${var.cluster_name}-NatGateway"
  }

  depends_on = [aws_internet_gateway.main_igw]
}

resource "aws_route_table" "private_main_route" {
  count  = var.private_subnet_enable ? 1 : 0
  vpc_id = local.vpc_id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main_natg[0].id
  }

  tags = {
    Name = "${var.cluster_name}-private-route-table"
  }
}


resource "aws_route_table_association" "private_main_associate" {
  for_each      = var.private_subnet_enable ? aws_subnet.private_subnet : {}
  subnet_id     = each.value.id
  route_table_id = aws_route_table.private_main_route[0].id
}


# 
# Conditionally retrieve an existing VPC
data "aws_vpc" "existing_vpc" {
  count = var.new_vpc_create ? 0 : 1
  id    = var.existing_vpc_id
}

# Use a conditional to set the VPC ID
locals {
  vpc_id = var.new_vpc_create ? aws_vpc.main_vpc[0].id : data.aws_vpc.existing_vpc[0].id
}