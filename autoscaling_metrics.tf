resource "aws_cloudwatch_metric_alarm" "scale_up" {
  count = var.scale_up_metric_alarms != null ? length(var.scale_up_metric_alarms) : 0
  alarm_name          = "alarm-scale-up-${local.service_name}"
  metric_name         = var.scale_up_metric_alarms[count.index].metric
  comparison_operator = var.scale_up_metric_alarms[count.index].comparison_operator
  threshold           = var.scale_up_metric_alarms[count.index].threshold
  treat_missing_data  = var.scale_up_metric_alarms[count.index].treat_missing_data
  statistic           = var.scale_up_metric_alarms[count.index].statistic
  period              = var.scale_up_metric_alarms[count.index].period
  evaluation_periods  = var.scale_up_metric_alarms[count.index].evaluation_periods
  datapoints_to_alarm = var.scale_up_metric_alarms[count.index].datapoints_to_alarm
  dimensions = merge(
    var.scale_up_metric_alarms[count.index].dimensions,
    {
      ClusterName = var.ecs_cluster_name,
      ServiceName = local.service_name
    }
  )
  alarm_actions   = [aws_appautoscaling_policy.scale_up[0].arn]
  actions_enabled = true
  namespace       = "AWS/ECS"
  tags = var.scale_up_metric_alarms[count.index].tags
  depends_on = [aws_appautoscaling_policy.scale_up[0]]
}

resource "aws_cloudwatch_metric_alarm" "scale_down" {
  count = var.scale_down_metric_alarms != null  ? length(var.scale_down_metric_alarms) : 0
  alarm_name          = "alarm-scale-down-${local.service_name}"
  metric_name         = var.scale_down_metric_alarms[count.index].metric
  comparison_operator = var.scale_down_metric_alarms[count.index].comparison_operator
  threshold           = var.scale_down_metric_alarms[count.index].threshold
  treat_missing_data  = var.scale_down_metric_alarms[count.index].treat_missing_data
  statistic           = var.scale_down_metric_alarms[count.index].statistic
  period              = var.scale_down_metric_alarms[count.index].period
  evaluation_periods  = var.scale_down_metric_alarms[count.index].evaluation_periods
  datapoints_to_alarm = var.scale_down_metric_alarms[count.index].datapoints_to_alarm
  dimensions = merge(
    var.scale_down_metric_alarms[count.index].dimensions,
    {
      ClusterName = var.ecs_cluster_name,
      ServiceName = local.service_name
    }
  )
  alarm_actions   = [aws_appautoscaling_policy.scale_down[0].arn]
  actions_enabled = true
  namespace       = "AWS/ECS"
  tags = var.scale_down_metric_alarms[count.index].tags
  depends_on = [aws_appautoscaling_policy.scale_down[0]]
}
