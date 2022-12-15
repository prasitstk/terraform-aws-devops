##################
# SSM Parameters #
##################

resource "aws_ssm_parameter" "cloudwatch_agent_cfg_linux" {
  name        = "AmazonCloudWatch-linux"
  type        = "String"
  value       = file("${path.module}/files/aws_ssm_parameter/cw-agent-cfg-linux.json")
}

#################
# IAM resources #
#################

resource "aws_iam_role" "app_instance_profile_role" {
  name        = "${var.sys_name}-${var.app_name}-i-profile"
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

  inline_policy {
    name = "ssm-get-parameters"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Sid    = "VisualEditor0"
          Effect = "Allow"
          Action = [
            "ssm:GetParameters",
            "ssm:GetParameter"
          ]
          Resource = "arn:aws:ssm:*:${data.aws_caller_identity.current.account_id}:parameter/*"
        }
      ]
    })
  }
}

resource "aws_iam_instance_profile" "app_instance_profile" {
  name = "${var.sys_name}-${var.app_name}-i-profile"
  role = aws_iam_role.app_instance_profile_role.name
}

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
  key_name      = aws_key_pair.sys_key_pair.key_name
  
  # Security
  iam_instance_profile   = aws_iam_instance_profile.app_instance_profile.name

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
  
  user_data = <<EOF
    #!/bin/bash
    sudo yum update -y
    sudo yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
    sudo yum install -y collectd
    sudo yum install -y amazon-cloudwatch-agent
    sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -s -c ssm:AmazonCloudWatch-linux
  EOF

  tags = {
    Name = "${var.sys_name}-${var.app_name}-i"
  }
}
