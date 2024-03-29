#------------------------------------------------------------------------------
# AWS ECS SERVICE
#------------------------------------------------------------------------------
output "service_name" {
  description = "Service name, either overriden by the name_override variable, or composed via {preffix}-{aws_short_region}-{environment}"
  value = local.service_name
}

output "aws_ecs_service_id" {
  description = "The Amazon Resource Name (ARN) that identifies the service."
  value       = var.create_blue_green_deploy_tgs ? aws_ecs_service.service_bg[0].id : aws_ecs_service.service[0].id
}

output "aws_ecs_service_name" {
  description = "The name of the service."
  value       = var.create_blue_green_deploy_tgs ? aws_ecs_service.service_bg[0].name : aws_ecs_service.service[0].name
}

output "aws_ecs_service_cluster" {
  description = "The Amazon Resource Name (ARN) of cluster which the service runs on."
  value       = var.create_blue_green_deploy_tgs ? aws_ecs_service.service_bg[0].cluster : aws_ecs_service.service[0].cluster
}

output "aws_ecs_service_desired_count" {
  description = "The number of instances of the task definition"
  value       = var.create_blue_green_deploy_tgs ? aws_ecs_service.service_bg[0].desired_count : aws_ecs_service.service[0].desired_count
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
  value = var.load_balancing != null && !var.create_blue_green_deploy_tgs ? aws_lb_target_group.lb_http_target_group[0].arn : null
}

output "target_group_blue_arn" {
  description = "Arn of the ervice's blue target group"
  value = var.load_balancing != null && var.create_blue_green_deploy_tgs ? aws_lb_target_group.lb_http_target_group_blue[0].arn : null
}

output "target_group_green_arn" {
  description = "Arn of the ervice's green target group"
  value = var.load_balancing != null && var.create_blue_green_deploy_tgs ? aws_lb_target_group.lb_http_target_group_green[0].arn : null
}

output "target_group_id" {
  description = "Id of the service's target group"
  value = var.load_balancing != null && !var.create_blue_green_deploy_tgs ? aws_lb_target_group.lb_http_target_group[0].id : null
}

output "target_group_blue_id" {
  description = "Id of the service's blue target group"
  value = var.load_balancing != null && var.create_blue_green_deploy_tgs ? aws_lb_target_group.lb_http_target_group_blue[0].id : null
}

output "target_group_green_id" {
  description = "Id of the service's green target group"
  value = var.load_balancing != null && var.create_blue_green_deploy_tgs ? aws_lb_target_group.lb_http_target_group_blue[0].id : null
}