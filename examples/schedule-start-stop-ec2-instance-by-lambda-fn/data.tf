###############
# Datasources #
###############

data "aws_caller_identity" "current" {}

data "archive_file" "start_stop_ec2_instance_fn_zip" {
  type        = "zip"
  source_file = "${path.module}/files/aws_lambda_function/start-stop-ec2-instance-fn/index.js"
  output_path = "${path.module}/files/aws_lambda_function/start-stop-ec2-instance-fn.zip"
}
