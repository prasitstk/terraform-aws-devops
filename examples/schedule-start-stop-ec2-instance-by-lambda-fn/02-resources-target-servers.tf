#################
# EC2 resources #
#################

resource "aws_network_interface" "app_eni" {
  subnet_id = aws_subnet.sys_public_subnets["${var.app_az_name}"].id
  security_groups = [aws_security_group.app_sg.id]

  tags = {
    Name = "${var.sys_name}-${var.app_name}-i"
  }
}

resource "aws_instance" "app_i" {
  ami           = var.app_ami_id
  instance_type = "t3.micro"

  # Networking
  network_interface {
    network_interface_id = aws_network_interface.app_eni.id
    device_index         = 0
  }

  # Storage
  root_block_device {
    volume_type = "gp2"
    volume_size = 80

    tags = {
      Name = "${var.sys_name}-${var.app_name}-i"
    }
  }

  tags = {
    Name = "${var.sys_name}-${var.app_name}-i"
  }
}
