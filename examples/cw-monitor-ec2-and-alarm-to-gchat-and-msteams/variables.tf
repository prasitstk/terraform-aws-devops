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

variable "gchat_card_img_alert_url" {
  type        = string
  description = "Public image URL of Google Chat card when the metric excees threshold"
}

variable "gchat_card_img_ok_url" {
  type        = string
  description = "Public image URL of Google Chat card when the metric is back to normal" 
}

variable "ghat_webhook_url" {
  type        = string
  description = "Google Chat Webhook URL"
}

variable "ghat_card_timezone" {
  type        = string
  description = "Timezone to display date/time in Google Chat card"
  default     = "Asia/Bangkok"
}

variable "msteams_webhook_url" {
  type        = string
  description = "Microsoft Teams Webhook URL"
}

variable "msteams_card_timezone" {
  type        = string
  description = "Timezone to display date/time in Microsoft Teams card"
  default     = "Asia/Bangkok"
}

variable "cpu_alarm_threshold" {
  type        = number
  description = "Threshold CPUUtilization metric that if it is exceeded, the alarm will be triggered"
  default     = 75
}

variable "mem_alarm_threshold" {
  type        = number
  description = "Threshold mem_used_percent metric that if it is exceeded, the alarm will be triggered"
  default     = 75
}

variable "disk_alarm_threshold" {
  type        = number
  description = "Threshold disk_used_percent metric that if it is exceeded, the alarm will be triggered"
  default     = 75
}
