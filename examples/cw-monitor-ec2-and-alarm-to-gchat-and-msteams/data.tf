###############
# Datasources #
###############

data "aws_caller_identity" "current" {}

data "archive_file" "mon_cwalarm_sns_to_gchat_webhook_fn_zip" {
  type        = "zip"
  source_file = "${path.module}/files/aws_lambda_function/mon-cwalarm-sns-to-gchat-webhook-fn/index.js"
  output_path = "${path.module}/files/aws_lambda_function/mon-cwalarm-sns-to-gchat-webhook-fn.zip"
}

data "archive_file" "mon_cwalarm_sns_to_msteams_webhook_fn_zip" {
  type        = "zip"
  source_file = "${path.module}/files/aws_lambda_function/mon-cwalarm-sns-to-msteams-webhook-fn/index.js"
  output_path = "${path.module}/files/aws_lambda_function/mon-cwalarm-sns-to-msteams-webhook-fn.zip"
}
