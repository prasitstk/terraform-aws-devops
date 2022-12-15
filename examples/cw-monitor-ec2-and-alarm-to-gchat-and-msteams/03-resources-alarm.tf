#################
# IAM resources #
#################

#-----------------------------#
# Google Chat alarm resources #
#-----------------------------#

resource "aws_iam_policy" "mon_cwalarm_sns_to_gchat_webhook_fn_base_policy" {
  name = "${var.sys_name}-mon-cwalarm-sns-to-gchat-webhook-fn-base-policy"
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
          "arn:aws:logs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/${var.sys_name}-mon-cwalarm-sns-to-gchat-webhook-fn:*"
        ]
      }
    ]
  })
}

resource "aws_iam_role" "mon_cwalarm_sns_to_gchat_webhook_fn_role" {
  name = "${var.sys_name}-mon-cwalarm-sns-to-gchat-webhook-fn-role"
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
    aws_iam_policy.mon_cwalarm_sns_to_gchat_webhook_fn_base_policy.arn,
  ]
}

#--------------------------#
# MS Teams alarm resources #
#--------------------------#

resource "aws_iam_policy" "mon_cwalarm_sns_to_msteams_webhook_fn_base_policy" {
  name = "${var.sys_name}-mon-cwalarm-sns-to-msteams-webhook-fn-base-policy"
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
          "arn:aws:logs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/${var.sys_name}-mon-cwalarm-sns-to-msteams-webhook-fn:*"
        ]
      }
    ]
  })
}

resource "aws_iam_role" "mon_cwalarm_sns_to_msteams_webhook_fn_role" {
  name = "${var.sys_name}-mon-cwalarm-sns-to-msteams-webhook-fn-role"
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
    aws_iam_policy.mon_cwalarm_sns_to_msteams_webhook_fn_base_policy.arn,
  ]
}

#################
# SNS resources #
#################

resource "aws_sns_topic" "mon_cwalarm_to_webhook_topic" {
  name = "${var.sys_name}-mon-cwalarm-to-webhook-topic"
}

#-----------------------------#
# Google Chat alarm resources #
#-----------------------------#

resource "aws_sns_topic_subscription" "mon_cwalarm_to_webhook_topic_mon_cwalarm_sns_to_gchat_webhook_fn_lambda_subscription" {
  topic_arn = aws_sns_topic.mon_cwalarm_to_webhook_topic.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.mon_cwalarm_sns_to_gchat_webhook_fn.arn
}

#--------------------------#
# MS Teams alarm resources #
#--------------------------#

resource "aws_sns_topic_subscription" "mon_cwalarm_to_webhook_topic_mon_cwalarm_sns_to_msteams_webhook_fn_lambda_subscription" {
  topic_arn = aws_sns_topic.mon_cwalarm_to_webhook_topic.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.mon_cwalarm_sns_to_msteams_webhook_fn.arn
}

######################
# Function resources #
######################

#-----------------------------#
# Google Chat alarm resources #
#-----------------------------#

resource "aws_lambda_permission" "allow_mon_cwalarm_to_webhook_topic_to_mon_cwalarm_sns_to_gchat_webhook_fn" {
  statement_id  = "sns-${var.aws_region}-${data.aws_caller_identity.current.account_id}-${var.sys_name}-mon-cwalarm-to-gchat-webhook-topic"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.mon_cwalarm_sns_to_gchat_webhook_fn.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.mon_cwalarm_to_webhook_topic.arn
}

resource "aws_lambda_function" "mon_cwalarm_sns_to_gchat_webhook_fn" {
  function_name = "${var.sys_name}-mon-cwalarm-sns-to-gchat-webhook-fn"

  package_type     = "Zip"
  publish          = false
  filename         = data.archive_file.mon_cwalarm_sns_to_gchat_webhook_fn_zip.output_path
  source_code_hash = data.archive_file.mon_cwalarm_sns_to_gchat_webhook_fn_zip.output_base64sha256

  role    = aws_iam_role.mon_cwalarm_sns_to_gchat_webhook_fn_role.arn
  handler = "index.handler"
  runtime = "nodejs16.x"

  timeout = 30

  environment {
    variables = {
      GCHAT_CARD_IMG_ALERT_URL = var.gchat_card_img_alert_url
      GCHAT_CARD_IMG_OK_URL    = var.gchat_card_img_ok_url
      GCHAT_WEBHOOK_URL        = var.ghat_webhook_url
      TIMEZONE                 = var.ghat_card_timezone
    }
  }

}

#--------------------------#
# MS Teams alarm resources #
#--------------------------#

resource "aws_lambda_permission" "allow_mon_cwalarm_to_webhook_topic_to_mon_cwalarm_sns_to_msteams_webhook_fn" {
  statement_id  = "sns-${var.aws_region}-${data.aws_caller_identity.current.account_id}-${var.sys_name}-mon-cwalarm-to-msteams-webhook-topic"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.mon_cwalarm_sns_to_msteams_webhook_fn.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.mon_cwalarm_to_webhook_topic.arn
}

resource "aws_lambda_function" "mon_cwalarm_sns_to_msteams_webhook_fn" {
  function_name = "${var.sys_name}-mon-cwalarm-sns-to-msteams-webhook-fn"

  package_type     = "Zip"
  publish          = false
  filename         = data.archive_file.mon_cwalarm_sns_to_msteams_webhook_fn_zip.output_path
  source_code_hash = data.archive_file.mon_cwalarm_sns_to_msteams_webhook_fn_zip.output_base64sha256

  role    = aws_iam_role.mon_cwalarm_sns_to_msteams_webhook_fn_role.arn
  handler = "index.handler"
  runtime = "nodejs16.x"

  timeout = 30

  environment {
    variables = {
      MSTEAMS_WEBHOOK_URL = var.msteams_webhook_url
      TIMEZONE = var.msteams_card_timezone
    }
  }

}

###############################
# CloudWatch Alarms resources #
###############################

resource "aws_cloudwatch_metric_alarm" "app_i_cpu_alarm" {
  alarm_name                = "${var.sys_name}-${var.app_name}-i-cpu-alarm"
  alarm_description         = "{\"ResourceName\":\"${var.sys_name}-${var.app_name}-i\",\"ApplicationName\":\"${var.app_name}\",\"SystemName\":\"${var.sys_name}\"}"
  
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/EC2"
  statistic                 = "Average"
  period                    = 300
  comparison_operator       = "GreaterThanThreshold"
  threshold                 = var.cpu_alarm_threshold
  evaluation_periods        = 1
  datapoints_to_alarm       = 1

  dimensions = {
    InstanceId = aws_instance.app_i.id
  }

  alarm_actions = [
    aws_sns_topic.mon_cwalarm_to_webhook_topic.arn
  ]

  ok_actions = [
    aws_sns_topic.mon_cwalarm_to_webhook_topic.arn
  ]

  insufficient_data_actions = [
    aws_sns_topic.mon_cwalarm_to_webhook_topic.arn
  ]

}

resource "aws_cloudwatch_metric_alarm" "app_i_mem_alarm" {
  alarm_name                = "${var.sys_name}-${var.app_name}-i-mem-alarm"
  alarm_description         = "{\"ResourceName\":\"${var.sys_name}-${var.app_name}-i\",\"ApplicationName\":\"${var.app_name}\",\"SystemName\":\"${var.sys_name}\"}"
  
  metric_name               = "mem_used_percent"
  namespace                 = "CWAgent"
  statistic                 = "Average"
  period                    = 300
  comparison_operator       = "GreaterThanThreshold"
  threshold                 = var.mem_alarm_threshold
  evaluation_periods        = 1
  datapoints_to_alarm       = 1

  dimensions = {
    InstanceId = aws_instance.app_i.id
  }

  alarm_actions = [
    aws_sns_topic.mon_cwalarm_to_webhook_topic.arn
  ]

  ok_actions = [
    aws_sns_topic.mon_cwalarm_to_webhook_topic.arn
  ]

  insufficient_data_actions = [
    aws_sns_topic.mon_cwalarm_to_webhook_topic.arn
  ]
}

resource "aws_cloudwatch_metric_alarm" "app_i_disk_alarm" {
  alarm_name                = "${var.sys_name}-${var.app_name}-i-disk-alarm"
  alarm_description         = "{\"ResourceName\":\"${var.sys_name}-${var.app_name}-i\",\"ApplicationName\":\"${var.app_name}\",\"SystemName\":\"${var.sys_name}\"}"
  
  metric_name               = "disk_used_percent"
  namespace                 = "CWAgent"
  statistic                 = "Average"
  period                    = 300
  comparison_operator       = "GreaterThanThreshold"
  threshold                 = var.disk_alarm_threshold
  evaluation_periods        = 1
  datapoints_to_alarm       = 1

  dimensions = {
    InstanceId = aws_instance.app_i.id
  }

  alarm_actions = [
    aws_sns_topic.mon_cwalarm_to_webhook_topic.arn
  ]

  ok_actions = [
    aws_sns_topic.mon_cwalarm_to_webhook_topic.arn
  ]

  insufficient_data_actions = [
    aws_sns_topic.mon_cwalarm_to_webhook_topic.arn
  ]
}
