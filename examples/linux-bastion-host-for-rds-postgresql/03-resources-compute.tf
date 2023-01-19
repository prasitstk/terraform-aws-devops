#################
# EC2 resources #
#################

resource "aws_network_interface" "bastion_host_eni" {
  subnet_id = aws_subnet.sys_public_subnets["${var.bastion_host_az_name}"].id
  security_groups = [aws_security_group.bastion_host_sg.id]

  tags = {
    Name = "${var.sys_name}-bastion-host-i"
  }
}

resource "tls_private_key" "bastion_host_tls_private_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "bastion_host_key_pair" {
  key_name   = "${var.sys_name}-bastion-host-keypair"
  public_key = tls_private_key.bastion_host_tls_private_key.public_key_openssh
}

resource "aws_instance" "bastion_host_i" {
  ami           = var.bastion_host_ami_id
  instance_type = "t3.micro"
  key_name      = aws_key_pair.bastion_host_key_pair.key_name

  # Networking
  network_interface {
    network_interface_id = aws_network_interface.bastion_host_eni.id
    device_index         = 0
  }

  # Storage
  root_block_device {
    volume_type = "gp2"
    volume_size = 80

    tags = {
      Name = "${var.sys_name}-bastion-host-i"
    }
  }

  tags = {
    Name = "${var.sys_name}-bastion-host-i"
  }
}
