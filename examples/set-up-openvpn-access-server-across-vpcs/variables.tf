#############
# Variables #
#############

variable "aws_region" {
  type        = string
  description = "AWS Region for the created resources"
}

variable "aws_access_key" {
  type        = string
  description = "AWS Access Key of your AWS account for the created resources"
}

variable "aws_secret_key" {
  type        = string
  description = "AWS Secret Key of your AWS account for the created resources"
}

variable "sys_name" {
  type        = string
  description = "System name used to naming various components of this system"
}

variable "sys_vpn_vpc_cidr_block" {
  type        = string
  description = "System VPC CIDR block for VPN network in a specified aws_region (it should be in between /16 to /24)"
}

variable "sys_internal_vpc_cidr_block" {
  type        = string
  description = "System VPC CIDR block for internal network in a specified aws_region that need to be connected through VPN network (it should be in between /16 to /24)"
}

variable "host_az_name" {
  type        = string
  description = "Availablity Zone of all host instances"
}

variable "linux_host_ami_id" {
  type        = string
  description = "Linux AMI ID in the form of ami-xxx, Amazon Linux 2 as an example of Linux AMI"
}

variable "win_host_ami_id" {
  type        = string
  description = "Windows AMI ID in the form of ami-xxx"
}

variable "openvpn_host_ami_id" {
  type        = string
  description = "OpenVPN Access Server AMI ID :: AWS Marketplace AMIs > OpenVPN Access Server > (Need subscription before launching with this AMI)"
}
