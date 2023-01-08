#################
# IAM resources #
#################

resource "aws_iam_policy" "example_fn_base_policy" {
  name = "${var.sys_name}-example-fn-base-policy"
  path = "/service-role/"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "logs:CreateLogGroup"
        Resource = "arn:aws:logs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:*"
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = [
          "arn:aws:logs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/${var.sys_name}-example-fn:*"
        ]
      }
    ]
  })
}

resource "aws_iam_role" "example_fn_role" {
  name = "${var.sys_name}-example-fn-role"
  path = "/service-role/"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  managed_policy_arns = [
    aws_iam_policy.example_fn_base_policy.arn,
  ]

}

######################
# Function resources #
######################

resource "aws_lambda_layer_version" "example_fn_layer" {
  layer_name       = "${var.sys_name}-example-fn-layer"
  filename         = data.archive_file.example_fn_layer_zip.output_path
  source_code_hash = data.archive_file.example_fn_layer_zip.output_base64sha256

  compatible_runtimes = ["nodejs16.x"]
}

resource "aws_lambda_function" "example_fn" {
  function_name = "${var.sys_name}-example-fn"

  package_type     = "Zip"
  publish          = false
  filename         = data.archive_file.example_fn_zip.output_path
  source_code_hash = data.archive_file.example_fn_zip.output_base64sha256

  role    = aws_iam_role.example_fn_role.arn
  handler = "index.handler"
  runtime = "nodejs16.x"
  layers  = [aws_lambda_layer_version.example_fn_layer.arn]
  
  environment {
    variables = {
      FN_MSG_NAME = "${var.fn_msg_name}"
    }
  }
}
