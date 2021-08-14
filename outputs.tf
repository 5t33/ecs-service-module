#------------------------------------------------------------------------------
# AWS ECS SERVICE
#------------------------------------------------------------------------------
output "service_name" {
  description = "Service name, either overriden by the name_override variable, or composed via {preffix}-{aws_short_region}-{environment}"
  value = local.service_name
}

output "aws_ecs_service_id" {
  description = "The Amazon Resource Name (ARN) that identifies the service."
  value       = aws_ecs_service.service.id
}

output "aws_ecs_service_name" {
  description = "The name of the service."
  value       = aws_ecs_service.service.name
}

output "aws_ecs_service_cluster" {
  description = "The Amazon Resource Name (ARN) of cluster which the service runs on."
  value       = aws_ecs_service.service.cluster
}

output "aws_ecs_service_desired_count" {
  description = "The number of instances of the task definition"
  value       = aws_ecs_service.service.desired_count
}

#------------------------------------------------------------------------------
# AUTO-SCALING
#------------------------------------------------------------------------------

output "service_min_task_count" {
  value = var.service_min_task_count
}

output "service_max_task_count" {
  value = var.service_max_task_count
}

#------------------------------------------------------------------------------
# AWS LOAD BALANCER
#------------------------------------------------------------------------------

output "target_group_arn" {
  description = "Arn of the ervice's target group"
  value = var.create_load_balancing ? aws_lb_target_group.lb_http_target_group[0].arn : null
}

output "target_group_id" {
  description = "Id of the service's target group"
  value = var.create_load_balancing ? aws_lb_target_group.lb_http_target_group[0].arn : null
}
