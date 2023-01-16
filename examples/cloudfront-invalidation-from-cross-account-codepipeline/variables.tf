variable "src_aws_region" {
  type        = string
  description = "AWS Region of your source AWS account for the created resources to invalidate CloudFront distribution on the target account"
}

variable "src_aws_access_key" {
  type        = string
  description = "AWS Access Key of your source AWS account for the created resources to invalidate CloudFront distribution on the target account"
}

variable "src_aws_secret_key" {
  type        = string
  description = "AWS Secret Key of your source AWS account for the created resources to invalidate CloudFront distribution on the target account"
}

variable "tgt_aws_region" {
  type        = string
  description = "AWS Region of your target AWS account for the CloudFront distribution to be invalidated"
}

variable "tgt_aws_access_key" {
  type        = string
  description = "AWS Access Key of your target AWS account for the CloudFront distribution to be invalidated"
}

variable "tgt_aws_secret_key" {
  type        = string
  description = "AWS Secret Key of your target AWS account for the CloudFront distribution to be invalidated"
}

variable "sys_name" {
  type        = string
  description = "System name used to naming various components of this system"
}

variable "app_zone_name" {
  type        = string
  description = "Application hosted zone name. It can be the domain name registered outside Amazon Route 53."
}

variable "app_domain_name" {
  type        = string
  description = "Application domain name"
}

variable "app_codestar_connection_arn" {
  type        = string
  description = "AWS CodeStar connection ARN of the application source codes to be deployed"
}

variable "app_full_repository_id" {
  type        = string
  description = "Full repository ID/path of the source code of the application"
}

variable "app_branch_name" {
  type        = string
  description = "Branch name of the repository of the source code of the application"
}

variable "api_domain_name" {
  type        = string
  description = "API domain name"
}
