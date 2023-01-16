terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  alias      = "source"
  region     = var.src_aws_region
  access_key = var.src_aws_access_key
  secret_key = var.src_aws_secret_key
}

provider "aws" {
  alias      = "target"
  region     = var.tgt_aws_region
  access_key = var.tgt_aws_access_key
  secret_key = var.tgt_aws_secret_key
}

provider "aws" {
  alias      = "target_global"
  region     = "us-east-1"
  access_key = var.tgt_aws_access_key
  secret_key = var.tgt_aws_secret_key
}
