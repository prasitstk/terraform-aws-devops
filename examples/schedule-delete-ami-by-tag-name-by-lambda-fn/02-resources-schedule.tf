#########################
# EventBridge resources #
#########################

resource "aws_cloudwatch_event_rule" "sys_sched_rule" {
  depends_on = [
    aws_lambda_function.delete_ami_by_tag_name_fn  # required to associate the rule to the Lambda function event source mappng
  ]
  name                = "${var.sys_name}-sched-rule"
  schedule_expression = "${var.app_fn_schedule_expression}"
}

resource "aws_cloudwatch_event_target" "sys_sched_rule_delete_ami_by_tag_name_fn_lambda_target" {
  target_id = "${var.sys_name}-delete-ami-by-tag-name-fn"
  arn       = aws_lambda_function.delete_ami_by_tag_name_fn.arn
  rule      = aws_cloudwatch_event_rule.sys_sched_rule.id

  input = jsonencode({
    DryRun = "${tostring(var.app_fn_schedule_dry_run)}"
    TagName = "${var.app_fn_schedule_tag_name}"
    RetentionDays = "${tostring(var.app_fn_schedule_retention_days)}"
    MinRetention = "${tostring(var.app_fn_schedule_min_retention)}"
  })
}
