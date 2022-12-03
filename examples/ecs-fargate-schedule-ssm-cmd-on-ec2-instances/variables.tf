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

variable "env_name" {
  type        = string
  description = "Environment name used to naming various components of this system"
}

variable "ec2conn_cidr_block" {
  type        = string
  description = "AWS CIDR block for the IP range to allow inbound traffic from AWS EC2_INSTANCE_CONNECT service in a specified aws_region"
}

variable "app_ami_id" {
  type        = string
  description = "AMI ID of EC2 instances for the application"
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

variable "app_mock_content" {
  type        = string
  description = "The application mock content to be generated on text files in EC2 instances by SSM Run Command"
}

variable "app_schedule_expression" {
  type        = string
  description = "Schedule expression of ECS Scheduled Task"
}

variable "app_command" {
  type        = string
  description = "Command to be run inside the container from  ECS Scheduled Task"
}

variable "app1_name" {
  type        = string
  description = "Application 1 name"
}

variable "app1_az_name" {
  type        = string
  description = "Availablity Zone of the Application 1"
}

variable "app2_name" {
  type        = string
  description = "Application 2 name"
}

variable "app2_az_name" {
  type        = string
  description = "Availablity Zone of the Application 2"
}
