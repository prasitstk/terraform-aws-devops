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

variable "app_img_repo_name" {
  type        = string
  description = "ECR image repository name for the application"
}

variable "app_img_tag" {
  type        = string
  description = "Container image tag on the ECR image repository for the application"
  default     = "latest"
}

variable "app_src_repo_url" {
  type        = string
  description = "Git source code repository URL for the application"
  default     = "https://github.com/prasitstk/create-mock-file-job.git"
}

variable "data_db_name" {
  type        = string
  description = "Source database name"
}

variable "data_master_db_user" {
  type        = string
  description = "Master user of the source database"
}

variable "data_master_db_password" {
  type        = string
  description = "Master user password of the source database"
}

variable "data_bucket_name" {
  type        = string
  description = "S3 bucket name for target dump data"
}

variable "app_schedule_expression" {
  type        = string
  description = "Schedule expression of ECS Scheduled Task"
}

variable "app_command" {
  type        = string
  description = "Command to be run inside the container from ECS Scheduled Task"
}
