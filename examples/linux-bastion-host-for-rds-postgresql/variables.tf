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

variable "sys_vpc_cidr_block" {
  type        = string
  description = "System VPC CIDR block in a specified aws_region (it should be in between /16 to /24)"
}

variable "db_name" {
  type        = string
  description = "Database name"
}

variable "master_db_user" {
  type        = string
  description = "Master user of the database"
}

variable "master_db_password" {
  type        = string
  description = "Master user password of the database"
}

variable "bastion_host_az_name" {
  type        = string
  description = "Availablity Zone of the bastion host"
}

variable "bastion_host_ami_id" {
  type        = string
  description = "Linux AMI ID inform of ami-xxx for the bastion host (Amazon Linux 2)"
}
