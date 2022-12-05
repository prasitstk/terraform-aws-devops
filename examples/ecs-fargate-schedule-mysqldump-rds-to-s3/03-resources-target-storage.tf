#####################
# Storage resources #
#####################

module "tgt_data_bucket" {
  source        = "../../modules/s3-bucket"
  bucket        = "${var.data_bucket_name}"
  force_destroy = true
  acl           = "private"
}
