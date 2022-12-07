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

variable "app_fn_schedule_expression" {
  type        = string
  description = "Schedule expression of the Lambda function"
}

variable "app_fn_schedule_dry_run" {
  type        = bool
  description = "Specify whether the schduled Lambda function will dry run"
}

variable "app_fn_schedule_tag_name" {
  type        = string
  description = "Specify which AMIs to be deleted by EC2 instance tag name"
}

variable "app_fn_schedule_retention_days" {
  type        = number
  description = "Specify how long the AMIs exist in days before they are deleted"
}

variable "app_fn_schedule_min_retention" {
  type        = number
  description = "Specify the minimum number of AMIs of a tag name to be retained which will override the app_fn_schedule_retention_days"
}
