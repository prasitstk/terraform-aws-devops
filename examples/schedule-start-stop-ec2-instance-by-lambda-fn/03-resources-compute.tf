#################
# IAM resources #
#################

resource "aws_iam_policy" "start_stop_ec2_instance_fn_base_policy" {
  name = "${var.sys_name}-start-stop-ec2-instance-fn-base-policy"
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
          "arn:aws:logs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/${var.sys_name}-start-stop-ec2-instance-fn:*"
        ]
      }
    ]
  })
}

resource "aws_iam_role" "start_stop_ec2_instance_fn_role" {
  name = "${var.sys_name}-start-stop-ec2-instance-fn-role"
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
    aws_iam_policy.start_stop_ec2_instance_fn_base_policy.arn,
  ]

  inline_policy {
    name = "ec2-actions"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Sid    = "VisualEditor0"
          Effect = "Allow"
          Action = [
            "ec2:Start*",
            "ec2:Stop*"
          ],
          Resource = "*"
        }
      ]
    })
  }

}

######################
# Function resources #
######################

resource "aws_lambda_permission" "allow_sys_sched_rule_to_start_stop_ec2_instance_fn" {
  statement_id  = "AWSEvents_${var.sys_name}-sched-rule"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.start_stop_ec2_instance_fn.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.sys_sched_rule.arn
}

resource "aws_lambda_function" "start_stop_ec2_instance_fn" {
  function_name = "${var.sys_name}-start-stop-ec2-instance-fn"

  package_type     = "Zip"
  publish          = false
  filename         = data.archive_file.start_stop_ec2_instance_fn_zip.output_path
  source_code_hash = data.archive_file.start_stop_ec2_instance_fn_zip.output_base64sha256

  role    = aws_iam_role.start_stop_ec2_instance_fn_role.arn
  handler = "index.handler"
  runtime = "nodejs16.x"

  timeout = 30

  environment {
    variables = {
      DEFAULT_DRY_RUN = "true"
    }
  }

}