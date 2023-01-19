#################
# VPC resources #
#################

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

#-------------------#
# VPN VPC resources #
#-------------------#

resource "aws_vpc" "sys_vpn_vpc" {
  cidr_block           = var.sys_vpn_vpc_cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true
  
  tags = {
    Name = "${var.sys_name}-vpn-vpc"
  }
}

resource "aws_internet_gateway" "sys_vpn_igw" {
  vpc_id = aws_vpc.sys_vpn_vpc.id
  
  tags = {
    Name = "${var.sys_name}-vpn-igw"
  }
}

resource "aws_route_table" "sys_vpn_public_rtb" {
  vpc_id = aws_vpc.sys_vpn_vpc.id
  
  tags = {
    Name = "${var.sys_name}-vpn-public-rtb"
  }
}

resource "aws_route" "sys_vpn_public_rtb_igw_r" {
  route_table_id         = aws_route_table.sys_vpn_public_rtb.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.sys_vpn_igw.id
}

resource "aws_subnet" "sys_vpn_public_subnets" {
  for_each = data.aws_availability_zone.all
  
  vpc_id                  = aws_vpc.sys_vpn_vpc.id
  availability_zone       = each.key
  cidr_block              = cidrsubnet(aws_vpc.sys_vpn_vpc.cidr_block, 4, local.pub_az_number[each.value.name_suffix])
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.sys_name}-vpn-public-subnet-${each.value.name_suffix}"
  }
}

resource "aws_route_table_association" "sys_vpn_public_subnet_rtb_assos" {
  for_each = aws_subnet.sys_vpn_public_subnets
  
  subnet_id      = each.value.id
  route_table_id = aws_route_table.sys_vpn_public_rtb.id
}

resource "aws_security_group" "openvpn_host_sg" {
  name        = "${var.sys_name}-openvpn-host-sg"
  description = "Security Group for the OpenVPN host"
  vpc_id      = aws_vpc.sys_vpn_vpc.id
  
  tags = {
    Name = "${var.sys_name}-openvpn-host-sg"
  }
}

resource "aws_security_group_rule" "openvpn_host_sg_public_in_ssh" {
  description       = "All inbound SSH traffic from public"
  security_group_id = aws_security_group.openvpn_host_sg.id
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "openvpn_host_sg_public_in_openvpn_tcp" {
  description       = "All TCP inbound traffic for OpenVPN from public"
  security_group_id = aws_security_group.openvpn_host_sg.id
  type              = "ingress"
  from_port         = 943
  to_port           = 943
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "openvpn_host_sg_public_in_https" {
  description       = "All inbound HTTPS traffic from public"
  security_group_id = aws_security_group.openvpn_host_sg.id
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "openvpn_host_sg_public_in_openvpn_udp" {
  description       = "All UDP inbound traffic for OpenVPN from public"
  security_group_id = aws_security_group.openvpn_host_sg.id
  type              = "ingress"
  from_port         = 1194
  to_port           = 1194
  protocol          = "udp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "openvpn_host_sg_all_out_public" {
  security_group_id = aws_security_group.openvpn_host_sg.id
  type              = "egress"
  to_port           = 0     # Allowing any outgoing port
  from_port         = 0     # Allowing any incoming port
  protocol          = "-1"  # Allowing any outgoing protocol 
  cidr_blocks       = ["0.0.0.0/0"]  # Allowing traffic out to all IP addresses
}

#------------------------#
# Internal VPC resources #
#------------------------#

resource "aws_vpc" "sys_internal_vpc" {
  cidr_block           = var.sys_internal_vpc_cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true
  
  tags = {
    Name = "${var.sys_name}-internal-vpc"
  }
}

resource "aws_internet_gateway" "sys_internal_igw" {
  vpc_id = aws_vpc.sys_internal_vpc.id
  
  tags = {
    Name = "${var.sys_name}-internal-igw"
  }
}

resource "aws_route_table" "sys_internal_public_rtb" {
  vpc_id = aws_vpc.sys_internal_vpc.id
  
  tags = {
    Name = "${var.sys_name}-internal-public-rtb"
  }
}

resource "aws_route" "sys_internal_public_rtb_igw_r" {
  route_table_id         = aws_route_table.sys_internal_public_rtb.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.sys_internal_igw.id
}

resource "aws_subnet" "sys_internal_public_subnets" {
  for_each = data.aws_availability_zone.all
  
  vpc_id                  = aws_vpc.sys_internal_vpc.id
  availability_zone       = each.key
  cidr_block              = cidrsubnet(aws_vpc.sys_internal_vpc.cidr_block, 4, local.pub_az_number[each.value.name_suffix])
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.sys_name}-internal-public-subnet-${each.value.name_suffix}"
  }
}

resource "aws_route_table_association" "sys_internal_public_subnet_rtb_assos" {
  for_each = aws_subnet.sys_internal_public_subnets
  
  subnet_id      = each.value.id
  route_table_id = aws_route_table.sys_internal_public_rtb.id
}

resource "aws_security_group" "win_host_sg" {
  name        = "${var.sys_name}-win-host-sg"
  description = "Security Group for the Windows host"
  vpc_id      = aws_vpc.sys_internal_vpc.id
  
  tags = {
    Name = "${var.sys_name}-win-host-sg"
  }
}

resource "aws_security_group_rule" "win_host_sg_vpn_in_rdp" {
  description       = "All inbound RDP traffic from VPN VPC"
  security_group_id = aws_security_group.win_host_sg.id
  type              = "ingress"
  from_port         = 3389
  to_port           = 3389
  protocol          = "tcp"
  cidr_blocks       = [aws_vpc.sys_vpn_vpc.cidr_block]
}

resource "aws_security_group_rule" "win_host_sg_all_out_public" {
  security_group_id = aws_security_group.win_host_sg.id
  type              = "egress"
  to_port           = 0     # Allowing any outgoing port
  from_port         = 0     # Allowing any incoming port
  protocol          = "-1"  # Allowing any outgoing protocol 
  cidr_blocks       = ["0.0.0.0/0"]  # Allowing traffic out to all IP addresses
}

resource "aws_security_group" "linux_host_sg" {
  name        = "${var.sys_name}-linux-host-sg"
  description = "Security Group for the Linux host"
  vpc_id      = aws_vpc.sys_internal_vpc.id
  
  tags = {
    Name = "${var.sys_name}-linux-host-sg"
  }
}

resource "aws_security_group_rule" "linux_host_sg_vpn_in_ssh" {
  description       = "All inbound SSH traffic from VPN VPC"
  security_group_id = aws_security_group.linux_host_sg.id
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = [aws_vpc.sys_vpn_vpc.cidr_block]
}

resource "aws_security_group_rule" "linux_host_sg_all_out_public" {
  security_group_id = aws_security_group.linux_host_sg.id
  type              = "egress"
  to_port           = 0     # Allowing any outgoing port
  from_port         = 0     # Allowing any incoming port
  protocol          = "-1"  # Allowing any outgoing protocol 
  cidr_blocks       = ["0.0.0.0/0"]  # Allowing traffic out to all IP addresses
}

#-------------#
# VPC Peering #
#-------------#

resource "aws_vpc_peering_connection" "sys_vpn_to_internal_peer_conn" {
  peer_owner_id = data.aws_caller_identity.current.account_id  # The AWS account ID of the owner of the peer VPC.
  vpc_id        = aws_vpc.sys_vpn_vpc.id       # The ID of the requester VPC
  peer_vpc_id   = aws_vpc.sys_internal_vpc.id  # The ID of the VPC with which you are creating the VPC Peering Connection.
  auto_accept   = true
  
  tags = {
    Name = "${var.sys_name}-vpn-to-internal-peer-conn"
  }
}

resource "aws_route" "sys_vpn_to_internal_r" {
  route_table_id = aws_route_table.sys_vpn_public_rtb.id
  destination_cidr_block = aws_vpc.sys_internal_vpc.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.sys_vpn_to_internal_peer_conn.id
}

resource "aws_route" "sys_internal_to_vpn_r" {
  route_table_id = aws_route_table.sys_internal_public_rtb.id
  destination_cidr_block = aws_vpc.sys_vpn_vpc.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.sys_vpn_to_internal_peer_conn.id
}
