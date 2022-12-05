#########################
# EventBridge resources #
#########################

resource "aws_cloudwatch_event_rule" "sys_sched_rule" {
  depends_on = [
    aws_lambda_function.start_stop_ec2_instance_fn  # required to associate the rule to the Lambda function event source mappng
  ]
  name                = "${var.sys_name}-sched-rule"
  schedule_expression = "${var.app_fn_schedule_expression}"
}

resource "aws_cloudwatch_event_target" "sys_sched_rule_start_stop_ec2_instance_fn_lambda_target_start" {
  # IMPORTANT: Don't forget to specify target_id to be different than the stop target; otherwise, only one target will remain.
  target_id = "${var.sys_name}-start-stop-ec2-instance-fn-start"
  arn       = aws_lambda_function.start_stop_ec2_instance_fn.arn
  rule      = aws_cloudwatch_event_rule.sys_sched_rule.id

  input = jsonencode({
    DryRun = "${lower(var.app_fn_schedule_dry_run)}",
    Schedules = [{
      InstanceID = "${aws_instance.app_i.id}"
      Action = "start"
      ScheduledTimes = var.app_fn_start_schedules
    }]
  })
}

resource "aws_cloudwatch_event_target" "sys_sched_rule_start_stop_ec2_instance_fn_lambda_target_stop" {
  # IMPORTANT: Don't forget to specify target_id to be different than the start target; otherwise, only one target will remain.
  target_id = "${var.sys_name}-start-stop-ec2-instance-fn-stop"
  arn       = aws_lambda_function.start_stop_ec2_instance_fn.arn
  rule      = aws_cloudwatch_event_rule.sys_sched_rule.id

  input = jsonencode({
    DryRun = "${lower(var.app_fn_schedule_dry_run)}",
    Schedules = [{
      InstanceID = "${aws_instance.app_i.id}"
      Action = "stop"
      ScheduledTimes = var.app_fn_stop_schedules
    }]
  })
}
