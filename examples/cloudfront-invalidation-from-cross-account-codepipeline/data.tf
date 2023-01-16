###############
# Datasources #
###############

data "aws_caller_identity" "src" {
  provider = aws.source
}

data "aws_caller_identity" "tgt" {
  provider = aws.target
}

data "aws_route53_zone" "app_zone" {
  provider = aws.target
  name         = "${var.app_zone_name}."
  private_zone = false
}

data "archive_file" "codepipeline_cloudfront_invalidation_cross_account_fn_zip" {
  type        = "zip"
  source_file = "${path.module}/files/aws_lambda_function/codepipeline-cloudfront-invalidation-cross-account-fn/lambda_function.py"
  output_path = "${path.module}/files/aws_lambda_function/codepipeline-cloudfront-invalidation-cross-account-fn.zip"
}
