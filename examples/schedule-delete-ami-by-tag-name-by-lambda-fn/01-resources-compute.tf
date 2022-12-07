#################
# IAM resources #
#################

resource "aws_iam_policy" "delete_ami_by_tag_name_fn_base_policy" {
  name = "${var.sys_name}-delete-ami-by-tag-name-fn-base-policy"
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
          "arn:aws:logs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/${var.sys_name}-delete-ami-by-tag-name-fn:*"
        ]
      }
    ]
  })
}

resource "aws_iam_role" "delete_ami_by_tag_name_fn_role" {
  name = "${var.sys_name}-delete-ami-by-tag-name-fn-role"
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
    aws_iam_policy.delete_ami_by_tag_name_fn_base_policy.arn,
  ]

  inline_policy {
    name = "ec2-delete-snapshot"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Sid    = "VisualEditor0"
          Effect = "Allow"
          Action = [
            "ec2:DeleteSnapshot"
          ]
          Resource = "arn:aws:ec2:*::snapshot/*"
        }
      ]
    })
  }

  inline_policy {
    name = "ec2-deregister-image"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Sid    = "VisualEditor0"
          Effect = "Allow"
          Action = [
            "ec2:DeregisterImage"
          ]
          Resource = "arn:aws:ec2:*::image/*"
        }
      ]
    })
  }

  inline_policy {
    name = "ec2-describe-images"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Sid    = "VisualEditor0"
          Effect = "Allow"
          Action = [
            "ec2:DescribeImages"
          ]
          Resource = "*"
        }
      ]
    })
  }

}

######################
# Function resources #
######################

resource "aws_lambda_permission" "allow_sys_sched_rule_to_delete_ami_by_tag_name_fn" {
  statement_id  = "AWSEvents_${var.sys_name}-sched-rule"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.delete_ami_by_tag_name_fn.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.sys_sched_rule.arn
}

resource "aws_lambda_function" "delete_ami_by_tag_name_fn" {
  function_name = "${var.sys_name}-delete-ami-by-tag-name-fn"

  package_type     = "Zip"
  publish          = false
  filename         = data.archive_file.delete_ami_by_tag_name_fn_zip.output_path
  source_code_hash = data.archive_file.delete_ami_by_tag_name_fn_zip.output_base64sha256

  role    = aws_iam_role.delete_ami_by_tag_name_fn_role.arn
  handler = "index.handler"
  runtime = "nodejs16.x"

  timeout = 30

  environment {
    variables = {
      DEFAULT_DRY_RUN        = "true"
      DEFAULT_MIN_RETENTION  = "7"
      DEFAULT_RETENTION_DAYS = "7"
      DEFAULT_TAG_NAME       = "delete-ami"
    }
  }

}
