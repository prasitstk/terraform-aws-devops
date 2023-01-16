#####################
# Storage resources #
#####################

#----------------#
# Source account #
#----------------#

module "app_bucket" {
  providers = {
    aws = aws.source
  }
  
  source        = "../../modules/s3-bucket"
  bucket        = "${var.app_domain_name}"
  force_destroy = true
  acl           = "private"
}
