#################
# VPC resources #
#################

resource "aws_vpc" "sys_vpc" {
  cidr_block           = var.sys_vpc_cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true
  
  tags = {
    Name = "${var.sys_name}-vpc"
  }
}

resource "aws_internet_gateway" "sys_igw" {
  vpc_id = aws_vpc.sys_vpc.id
  
  tags = {
    Name = "${var.sys_name}-igw"
  }
}

resource "aws_route_table" "sys_public_rtb" {
  vpc_id = aws_vpc.sys_vpc.id
  
  tags = {
    Name = "${var.sys_name}-public-rtb"
  }
}

resource "aws_route" "sys_public_rtb_igw_r" {
  route_table_id         = aws_route_table.sys_public_rtb.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.sys_igw.id
}

resource "aws_route_table" "sys_private_rtb" {
  vpc_id = aws_vpc.sys_vpc.id
  
  tags = {
    Name = "${var.sys_name}-private-rtb"
  }
}

locals {
  # Assign a number to each AZ letter used in public subnets
  pub_az_number = {
    a = 1
    b = 2
    c = 3
    d = 4
    e = 5
    f = 6
  }
  
  # Assign a number to each AZ letter used in private subnets
  pvt_az_number = {
    a = 7
    b = 8
    c = 9
    d = 10
    e = 11
    f = 12
  }
}

# Determine all of the available availability zones in the current AWS region.
data "aws_availability_zones" "available" {
  state = "available"
}

# This additional data source determines some additional details about each VPC, 
# including its suffix letter.
data "aws_availability_zone" "all" {
  for_each = toset(data.aws_availability_zones.available.names)
  
  name = each.key
}

resource "aws_subnet" "sys_public_subnets" {
  for_each = data.aws_availability_zone.all
  
  vpc_id                  = aws_vpc.sys_vpc.id
  availability_zone       = each.key
  cidr_block              = cidrsubnet(aws_vpc.sys_vpc.cidr_block, 4, local.pub_az_number[each.value.name_suffix])
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.sys_name}-public-subnet-${each.value.name_suffix}"
  }
}

resource "aws_route_table_association" "sys_public_subnet_rtb_assos" {
  for_each = aws_subnet.sys_public_subnets
  
  subnet_id      = each.value.id
  route_table_id = aws_route_table.sys_public_rtb.id
}

resource "aws_subnet" "sys_private_subnets" {
  for_each = data.aws_availability_zone.all
  
  vpc_id            = aws_vpc.sys_vpc.id
  availability_zone = each.key
  cidr_block        = cidrsubnet(aws_vpc.sys_vpc.cidr_block, 4, local.pvt_az_number[each.value.name_suffix])

  tags = {
    Name = "${var.sys_name}-private-subnet-${each.value.name_suffix}"
  }
}

resource "aws_route_table_association" "sys_private_subnet_rtb_assos" {
  for_each = aws_subnet.sys_private_subnets
  
  subnet_id      = each.value.id
  route_table_id = aws_route_table.sys_private_rtb.id
}

resource "aws_security_group" "bastion_host_sg" {
  name        = "${var.sys_name}-bastion-host-sg"
  description = "Security Group for the bastion host"
  vpc_id      = aws_vpc.sys_vpc.id
  
  tags = {
    Name = "${var.sys_name}-bastion-host-sg"
  }
}

resource "aws_security_group_rule" "bastion_host_sg_public_in_ssh" {
  description       = "All inbound SSH traffic from public"
  security_group_id = aws_security_group.bastion_host_sg.id
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "bastion_host_sg_all_out_public" {
  security_group_id = aws_security_group.bastion_host_sg.id
  type              = "egress"
  to_port           = 0     # Allowing any outgoing port
  from_port         = 0     # Allowing any incoming port
  protocol          = "-1"  # Allowing any outgoing protocol 
  cidr_blocks       = ["0.0.0.0/0"]  # Allowing traffic out to all IP addresses
}

resource "aws_security_group" "db_sg" {
  name        = "${var.sys_name}-db-sg"
  description = "Security Group for database for ${var.sys_name} system"
  vpc_id      = aws_vpc.sys_vpc.id
  
  tags = {
    Name = "${var.sys_name}-db-sg"
  }
}

resource "aws_security_group_rule" "db_sg_bastion_host_in_pg" {
  description              = "Allow inbound from ${var.sys_name}-bastion-host-sg"
  security_group_id        = aws_security_group.db_sg.id
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.bastion_host_sg.id
}

resource "aws_security_group_rule" "db_sg_all_out_public" {
  security_group_id = aws_security_group.db_sg.id
  type              = "egress"
  to_port           = 0
  from_port         = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}
