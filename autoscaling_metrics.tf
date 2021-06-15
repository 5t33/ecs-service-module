resource "aws_cloudwatch_metric_alarm" "service_high_req" {
  count = var.create_autoscaling && var.create_load_balancing ? 1 : 0
  alarm_name          = "alarm-high-req-scale-up-${local.service_name}"
  metric_name         = var.scale_up_metric
  comparison_operator = var.scale_up_comparison_operator
  threshold           = var.scale_up_threshold
  treat_missing_data  = var.scale_up_treat_missing_data
  statistic           = var.scale_up_statistic
  period              = var.scale_up_period
  evaluation_periods  = var.scale_up_evaluation_periods
  datapoints_to_alarm = var.scale_up_datapoints_to_alarm
  dimensions = {
    TargetGroup  = aws_lb_target_group.lb_http_target_group[0].arn_suffix
  }
  alarm_actions   = [aws_appautoscaling_policy.scale_up[0].arn]
  actions_enabled = true
  namespace       = var.scale_up_namespace
  tags = var.tags
  depends_on = [aws_appautoscaling_policy.scale_up[0]]
}

resource "aws_cloudwatch_metric_alarm" "service_low_req" {
  count = var.create_autoscaling && var.create_load_balancing ? 1 : 0
  alarm_name          = "alarm-low-req-scale-down-${local.service_name}-${var.aws_short_region[var.aws_region]}-${var.environment}"
  metric_name         = var.scale_down_metric
  comparison_operator = var.scale_down_comparison_operator
  threshold           = var.scale_down_threshold
  treat_missing_data  = var.scale_down_treat_missing_data
  statistic           = var.scale_down_statistic
  period              = var.scale_down_period
  evaluation_periods  = var.scale_down_evaluation_periods
  datapoints_to_alarm = var.scale_down_datapoints_to_alarm
  dimensions = {
    TargetGroup  = aws_lb_target_group.lb_http_target_group[0].arn_suffix
  }
  alarm_actions   = [aws_appautoscaling_policy.scale_down[0].arn]
  actions_enabled = true
  namespace       = var.scale_down_namespace
  tags = var.tags
  depends_on = [aws_appautoscaling_policy.scale_down[0]]
}
