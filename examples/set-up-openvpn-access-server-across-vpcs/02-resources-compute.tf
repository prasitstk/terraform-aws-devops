#################
# EC2 resources #
#################

resource "tls_private_key" "sys_tls_private_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "sys_key_pair" {
  key_name   = "${var.sys_name}-keypair"
  public_key = tls_private_key.sys_tls_private_key.public_key_openssh
}

#--------------#
# OpenVPN host #
#--------------#

resource "aws_network_interface" "openvpn_host_eni" {
  subnet_id = aws_subnet.sys_vpn_public_subnets["${var.host_az_name}"].id
  security_groups = [aws_security_group.openvpn_host_sg.id]

  tags = {
    Name = "${var.sys_name}-openvpn-host-i"
  }
}

resource "aws_instance" "openvpn_host_i" {
  ami           = var.openvpn_host_ami_id
  instance_type = "t3.small"
  key_name      = aws_key_pair.sys_key_pair.key_name

  # Networking
  network_interface {
    network_interface_id = aws_network_interface.openvpn_host_eni.id
    device_index         = 0
  }

  # Storage
  root_block_device {
    volume_type = "gp2"
    volume_size = 80

    tags = {
      Name = "${var.sys_name}-openvpn-host-i"
    }
  }

  tags = {
    Name = "${var.sys_name}-openvpn-host-i"
  }
}

resource "aws_eip" "openvpn_host_eip" {
  vpc        = true
  instance   = aws_instance.openvpn_host_i.id
  depends_on = [aws_internet_gateway.sys_vpn_igw]
}

#--------------#
# Windows host #
#--------------#

resource "aws_network_interface" "win_host_eni" {
  subnet_id = aws_subnet.sys_internal_public_subnets["${var.host_az_name}"].id
  security_groups = [aws_security_group.win_host_sg.id]

  tags = {
    Name = "${var.sys_name}-win-host-i"
  }
}

resource "aws_instance" "win_host_i" {
  ami           = var.win_host_ami_id
  instance_type = "t3.small"
  key_name      = aws_key_pair.sys_key_pair.key_name

  # Networking
  network_interface {
    network_interface_id = aws_network_interface.win_host_eni.id
    device_index         = 0
  }

  # Storage
  root_block_device {
    volume_type = "gp2"
    volume_size = 80

    tags = {
      Name = "${var.sys_name}-win-host-i"
    }
  }

  tags = {
    Name = "${var.sys_name}-win-host-i"
  }
}

#------------#
# Linux host #
#------------#

resource "aws_network_interface" "linux_host_eni" {
  subnet_id = aws_subnet.sys_internal_public_subnets["${var.host_az_name}"].id
  security_groups = [aws_security_group.linux_host_sg.id]

  tags = {
    Name = "${var.sys_name}-linux-host-i"
  }
}

resource "aws_instance" "linux_host_i" {
  ami           = var.linux_host_ami_id
  instance_type = "t3.small"
  key_name      = aws_key_pair.sys_key_pair.key_name

  # Networking
  network_interface {
    network_interface_id = aws_network_interface.linux_host_eni.id
    device_index         = 0
  }

  # Storage
  root_block_device {
    volume_type = "gp2"
    volume_size = 80

    tags = {
      Name = "${var.sys_name}-linux-host-i"
    }
  }

  tags = {
    Name = "${var.sys_name}-linux-host-i"
  }
}
