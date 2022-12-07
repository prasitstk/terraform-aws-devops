###############
# Datasources #
###############

data "aws_caller_identity" "current" {}

data "archive_file" "delete_ami_by_tag_name_fn_zip" {
  type        = "zip"
  source_file = "${path.module}/files/aws_lambda_function/delete-ami-by-tag-name-fn/index.js"
  output_path = "${path.module}/files/aws_lambda_function/delete-ami-by-tag-name-fn.zip"
}
