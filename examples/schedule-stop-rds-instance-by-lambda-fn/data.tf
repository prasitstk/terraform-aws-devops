###############
# Datasources #
###############

data "aws_caller_identity" "current" {}

data "archive_file" "stop_rds_instance_fn_zip" {
  type        = "zip"
  source_file = "${path.module}/files/aws_lambda_function/stop-rds-instance-fn/index.js"
  output_path = "${path.module}/files/aws_lambda_function/stop-rds-instance-fn.zip"
}
