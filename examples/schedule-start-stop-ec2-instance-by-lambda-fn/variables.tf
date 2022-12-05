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

variable "app_ami_id" {
  type        = string
  description = "AMI ID of EC2 instances for the application"
}

variable "app_name" {
  type        = string
  description = "Application name"
}

variable "app_az_name" {
  type        = string
  description = "Availablity Zone of the application"
}

variable "app_fn_schedule_expression" {
  type        = string
  description = "Schedule expression of the Lambda function"
}

variable "app_fn_schedule_dry_run" {
  type        = bool
  description = "Specify whether the schduled Lambda function will dry run"
}

variable "app_fn_start_schedules" {
  type        = list
  description = "Array of string in YYMM that represent time (in UTC) to start the EC2 instance when the schedule is triggered"
}

variable "app_fn_stop_schedules" {
  type        = list
  description = "Array of string in YYMM that represent time (in UTC) to stop the EC2 instance when the schedule is triggered"
}
