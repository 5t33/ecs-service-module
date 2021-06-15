resource "aws_appautoscaling_target" "this" {
  count = var.create_autoscaling && var.create_load_balancing ? 1 : 0
  service_namespace  = "ecs"
  resource_id        = "service/${var.ecs_cluster_name}/${local.service_name}"
  scalable_dimension = "ecs:service:DesiredCount"
  max_capacity       = var.service_max_task_count
  min_capacity       = var.service_min_task_count
  role_arn           = data.aws_iam_role.ecs_service_role.arn # TODO change this to execution role

  lifecycle {
    ignore_changes = [role_arn]
  }

  depends_on = [
    aws_ecs_service.service,
    data.aws_iam_role.ecs_service_role
  ]
}