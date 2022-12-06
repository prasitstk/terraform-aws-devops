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

variable "data_db_name" {
  type        = string
  description = "Targer database name"
}

variable "data_master_db_user" {
  type        = string
  description = "Master user of the target database"
}

variable "data_master_db_password" {
  type        = string
  description = "Master user password of the target database"
}

variable "app_fn_schedule_expression" {
  type        = string
  description = "Schedule expression of the Lambda function"
}

variable "app_fn_schedule_dry_run" {
  type        = bool
  description = "Specify whether the schduled Lambda function will dry run"
}
