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

variable "fn_msg_name" {
  type        = string
  description = "Value for the environment variable FN_MSG_NAME of the example-fn lambda function"
}
