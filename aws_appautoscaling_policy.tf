resource "aws_appautoscaling_policy" "scale_down" {
  count = var.step_scaling_policies != null ? 1 : 0
  name               = "appautoscale-${local.service_name}-${var.aws_short_region[var.aws_region]}-${var.environment}-scale-down"
  policy_type        = var.scaling_policy_type
  resource_id        = aws_appautoscaling_target.this[0].resource_id
  scalable_dimension = aws_appautoscaling_target.this[0].scalable_dimension
  service_namespace  = aws_appautoscaling_target.this[0].service_namespace

  step_scaling_policy_configuration {
    adjustment_type         = var.step_scaling_policies.scale_down_policy.metric_adj_type
    cooldown                = var.step_scaling_policies.scale_down_policy.cooldown
    metric_aggregation_type = var.step_scaling_policies.scale_down_policy.metric_aggregation_type

    step_adjustment {
      metric_interval_upper_bound = var.step_scaling_policies.scale_down_policy.metric_interval_upper_bound
      scaling_adjustment          = var.step_scaling_policies.scale_down_policy.scale_down_step
    }
  }

  depends_on = [
    aws_appautoscaling_target.this[0]
  ]
}

resource "aws_appautoscaling_policy" "scale_up" {
  count = var.step_scaling_policies != null ? 1 : 0
  name               = "appautoscale-${local.service_name}-${var.aws_short_region[var.aws_region]}-${var.environment}-scale-up"
  policy_type        = var.scaling_policy_type
  resource_id        = aws_appautoscaling_target.this[0].resource_id
  scalable_dimension = aws_appautoscaling_target.this[0].scalable_dimension
  service_namespace  = aws_appautoscaling_target.this[0].service_namespace

  step_scaling_policy_configuration {
    adjustment_type         = var.step_scaling_policies.scale_up_policy.metric_adj_type
    cooldown                = var.step_scaling_policies.scale_up_policy.cooldown
    metric_aggregation_type = var.step_scaling_policies.scale_up_policy.metric_aggregation_type

    step_adjustment {
      metric_interval_lower_bound = var.step_scaling_policies.scale_up_policy.metric_interval_lower_bound
      scaling_adjustment          = var.step_scaling_policies.scale_up_policy.scale_up_step
    }
  }

  depends_on = [
    aws_appautoscaling_target.this[0]
  ]
}
