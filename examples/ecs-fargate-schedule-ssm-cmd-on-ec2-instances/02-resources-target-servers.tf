#################
# IAM resources #
#################

resource "aws_iam_role" "app_instance_profile_role" {
  name        = "${var.sys_name}-app-i-profile"
  description = "Allows EC2 instances to call AWS services on your behalf."

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy",
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  ]
}

resource "aws_iam_instance_profile" "app_instance_profile" {
  name = "${var.sys_name}-app-i-profile"
  role = aws_iam_role.app_instance_profile_role.name
}

#################
# EC2 resources #
#################

resource "tls_private_key" "app_tls_private_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "app_key_pair" {
  key_name   = "${var.sys_name}-app-keypair"
  public_key = tls_private_key.app_tls_private_key.public_key_openssh
}

#------#
# App1 #
#------#

resource "aws_network_interface" "app1_eni" {
  subnet_id = aws_subnet.sys_public_subnets["${var.app1_az_name}"].id
  security_groups = [aws_security_group.app_sg.id]

  tags = {
    Name = "${var.sys_name}-${var.app1_name}-i"
  }
}

resource "aws_instance" "app1_i" {
  ami           = var.app_ami_id
  instance_type = "t3.micro"
  key_name      = aws_key_pair.app_key_pair.key_name

  # Security
  iam_instance_profile   = aws_iam_instance_profile.app_instance_profile.name

  # Networking
  network_interface {
    network_interface_id = aws_network_interface.app1_eni.id
    device_index         = 0
  }

  # Storage
  root_block_device {
    volume_type = "gp2"
    volume_size = 80

    tags = {
      Name = "${var.sys_name}-${var.app1_name}-i"
    }
  }

  tags = {
    Name        = "${var.sys_name}-${var.app1_name}-i"
    System      = "${var.sys_name}"
    Environment = "${var.env_name}"
  }
}

#------#
# App2 #
#------#

resource "aws_network_interface" "app2_eni" {
  subnet_id = aws_subnet.sys_public_subnets["${var.app2_az_name}"].id
  security_groups = [aws_security_group.app_sg.id]

  tags = {
    Name = "${var.sys_name}-${var.app2_name}-i"
  }
}

resource "aws_instance" "app2_i" {
  ami           = var.app_ami_id
  instance_type = "t3.micro"
  key_name      = aws_key_pair.app_key_pair.key_name

  # Security
  iam_instance_profile   = aws_iam_instance_profile.app_instance_profile.name

  # Networking
  network_interface {
    network_interface_id = aws_network_interface.app2_eni.id
    device_index         = 0
  }

  # Storage
  root_block_device {
    volume_type = "gp2"
    volume_size = 80

    tags = {
      Name = "${var.sys_name}-${var.app2_name}-i"
    }
  }

  tags = {
    Name        = "${var.sys_name}-${var.app2_name}-i"
    System      = "${var.sys_name}"
    Environment = "${var.env_name}"
  }
}

###################
# Resource groups #
###################

resource "aws_resourcegroups_group" "env_resourcegroup_grp" {
  name = "${var.sys_name}-${var.env_name}-group"

  resource_query {
    query = <<JSON
{
  "ResourceTypeFilters": [
    "AWS::EC2::Instance"
  ],
  "TagFilters": [
    {
      "Key": "System",
      "Values": ["${var.sys_name}"]
    },
    {
      "Key": "Environment",
      "Values": ["${var.env_name}"]
    }
  ]
}
JSON
  }
}
