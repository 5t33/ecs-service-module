resource "aws_appautoscaling_policy" "scale_down" {
  count = var.create_autoscaling && var.create_load_balancing ? 1 : 0
  name               = "appautoscale-${local.service_name}-${var.aws_short_region[var.aws_region]}-${var.environment}-scale-down"
  policy_type        = var.autoscale_down_policy_type
  resource_id        = aws_appautoscaling_target.this[0].resource_id
  scalable_dimension = aws_appautoscaling_target.this[0].scalable_dimension
  service_namespace  = aws_appautoscaling_target.this[0].service_namespace

  step_scaling_policy_configuration {
    adjustment_type         = var.autoscale_down_metric_adj_type
    cooldown                = var.autoscale_down_cooldown
    metric_aggregation_type = "Average" //TODO: make variable with default

    step_adjustment {
      metric_interval_upper_bound = var.autoscale_down_int_upper
      scaling_adjustment          = var.scale_down_step
    }
  }

  depends_on = [
    aws_appautoscaling_target.this[0]
  ]
}

resource "aws_appautoscaling_policy" "scale_up" {
  count = var.create_autoscaling && var.create_load_balancing ? 1 : 0
  name               = "appautoscale-${local.service_name}-${var.aws_short_region[var.aws_region]}-${var.environment}-scale-up"
  policy_type        = var.autoscale_up_policy_type
  resource_id        = aws_appautoscaling_target.this[0].resource_id
  scalable_dimension = aws_appautoscaling_target.this[0].scalable_dimension
  service_namespace  = aws_appautoscaling_target.this[0].service_namespace

  step_scaling_policy_configuration {
    adjustment_type         = var.autoscale_up_metric_adj_type
    cooldown                = var.autoscale_up_cooldown
    metric_aggregation_type = "Average" //TODO: make variable with default

    step_adjustment {
      metric_interval_lower_bound = var.autoscale_up_int_lower
      scaling_adjustment          = var.scale_up_step
    }
  }

  depends_on = [
    aws_appautoscaling_target.this[0]
  ]
}
