#########################
# EventBridge resources #
#########################

resource "aws_cloudwatch_event_rule" "sys_sched_rule" {
  depends_on = [
    aws_lambda_function.stop_rds_instance_fn  # required to associate the rule to the Lambda function event source mappng
  ]
  name                = "${var.sys_name}-sched-rule"
  schedule_expression = "${var.app_fn_schedule_expression}"
}

resource "aws_cloudwatch_event_target" "sys_sched_rule_stop_rds_instance_fn_lambda_target" {
  target_id = "${var.sys_name}-stop-rds-instance-fn"
  arn       = aws_lambda_function.stop_rds_instance_fn.arn
  rule      = aws_cloudwatch_event_rule.sys_sched_rule.id

  input = jsonencode({
    DryRun = "${tostring(var.app_fn_schedule_dry_run)}"
    DBIdentifier = "${aws_db_instance.tgt_data_dbi.identifier}"
  })
}
