################################
# ECS Scheduled task resources #
################################

#-----------------------#
# CloudWatch event role #
#-----------------------#

data "aws_iam_policy_document" "app_scheduled_task_cw_event_role_assume_role_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      identifiers = ["events.amazonaws.com"]
      type        = "Service"
    }
  }
}

data "aws_iam_policy_document" "app_scheduled_task_cw_event_role_cloudwatch_policy" {
  statement {
    effect    = "Allow"
    actions   = ["ecs:RunTask"]
    resources = ["*"]
    condition {
      test     = "ArnEquals"
      variable = "ecs:cluster"
      values   = [aws_ecs_cluster.app_cluster.arn]
    }
  }
  statement {
    actions   = ["iam:PassRole"]
    resources = ["${aws_iam_role.app_ecsTaskExecutionRole.arn}"]
  }
}

resource "aws_iam_role" "app_scheduled_task_cw_event_role" {
  name               = "${var.sys_name}-app-cw-role"
  assume_role_policy = data.aws_iam_policy_document.app_scheduled_task_cw_event_role_assume_role_policy.json
}

resource "aws_iam_role_policy" "app_scheduled_task_cw_event_role_cloudwatch_policy" {
  name   = "${var.sys_name}-app-cw-policy"
  role   = aws_iam_role.app_scheduled_task_cw_event_role.id
  policy = data.aws_iam_policy_document.app_scheduled_task_cw_event_role_cloudwatch_policy.json
}

#-----------------------#
# CloudWatch event rule #
#-----------------------#

resource "aws_cloudwatch_event_rule" "app_event_rule" {
  name                = "${var.sys_name}-app-cw-event-rule"
  schedule_expression = "${var.app_schedule_expression}"
  is_enabled          = true
  tags = {
    Name = "${var.sys_name}-app-cw-event-rule"
  }
}

#-------------------------#
# CloudWatch event target #
#-------------------------#

resource "aws_cloudwatch_event_target" "app_ecs_scheduled_task" {
  rule           = aws_cloudwatch_event_rule.app_event_rule.name
  event_bus_name = aws_cloudwatch_event_rule.app_event_rule.event_bus_name
  target_id      = aws_ecs_cluster.app_cluster.name
  arn            = aws_ecs_cluster.app_cluster.arn
  role_arn       = aws_iam_role.app_scheduled_task_cw_event_role.arn
  
  input = <<DOC
{
  "containerOverrides": [{
    "name": "${var.sys_name}-app-task",
    "command": ["${var.app_command}"],
    "environment": [
      {"name": "AWS_ACCESS_KEY_ID", "value": "${var.aws_access_key}"},
      {"name": "AWS_SECRET_ACCESS_KEY", "value": "${var.aws_secret_key}"},
      {"name": "AWS_REGION", "value": "${var.aws_region}"},
      {"name": "MOCK_CONTENT", "value": "${var.app_mock_content}"},
      {"name": "RESOURCE_GRP_NAME", "value": "${aws_resourcegroups_group.env_resourcegroup_grp.name}"}
    ],
    "environmentFiles": []
  }]
}
DOC

  ecs_target {
    launch_type         = "FARGATE"
    platform_version    = "LATEST"
    task_count          = 1
    task_definition_arn = aws_ecs_task_definition.app_taskdef.arn
    
    network_configuration {
      subnets          = [for s in aws_subnet.sys_public_subnets: "${s.id}"]
      security_groups  = ["${aws_security_group.app_sg.id}"]
      
      # IMPORTANT: 
      # For Auto-assign Public IP, choose whether to have your tasks receive a public IP address. 
      # For tasks on Fargate, for the task to pull the container image, 
      # - it must either use a public subnet and be assigned a public IP address 
      # - or a private subnet that has a route to the internet or a NAT gateway that can route requests to the internet.
      # So, inside the public subnet of this project, 
      # it is required to be true to ECS Scheduled Task to pull image from ECR Private Repository.
      assign_public_ip = true  
    }
  }
}
