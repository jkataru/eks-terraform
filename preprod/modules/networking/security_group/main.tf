resource "aws_security_group" "main_sg" {
  name        = var.name
  description = "Target security group with dynamic ingress rules"
  vpc_id      = var.vpc_id

  tags = {
    Name = var.name
  }

  dynamic "ingress" {
    for_each = var.inbound_rules
    content {
      from_port       = ingress.value.from_port
      to_port         = ingress.value.to_port
      protocol        = ingress.value.protocol
      cidr_blocks     = ingress.value.cidr_blocks != [] ? ingress.value.cidr_blocks : null
      security_groups = ingress.value.source_sg_ids != [] ? ingress.value.source_sg_ids : null
      description     = "Allow traffic from specified source SG on specified port"
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # Allows all egress traffic
    cidr_blocks = ["0.0.0.0/0"]
  }
}