# Module for creating an ECS service

Heavily borrowed from:
* https://github.com/cn-terraform/terraform-aws-ecs-fargate-service

## Usage

```
module "ecs_service" {
  source = "../../../Shared/Modules/ecs-service" 
  // Required variables

  // Misc.  
  environment                          = var.environment // required (type: string)
  aws_region                           = var.aws_region // required (type: string)
  name_preffix                         = var.name_preffix // required (type: string)
  vpc_id                               = var.vpc_id // required (type: string)

  //ECS 
  ecs_cluster_name                     = var.ecs_cluster_name // required (type: string)
  
  // Load balancer/Target group
  lb_name                              = var.lb_name // required (type: string)
  path_patterns                        = var.path_patterns // required (type: list(string))
  
  // Task Definition
  desired_count                        = var.desired_count // required (type: number)
  container_name                       = var.container_name // required (type: string)
  container_port                       = var.container_port // required (type: number)
  container_image                      = var.container_image // required (type: string)
  tg_health_check_path                 = var.tg_health_check_path // required (type: string)
  task_definition_family               = var.task_definition_family // required (type: string)

  // Optional variables
  
  // Optional Misc.
  tags                                 = var.tags // optional (type: map) default = ""
  name_override                        = var.name_override // optional (type: string) defaults to "", unused if left blank
  
  // Optional Roles
  task_execution_role_arn              = var.task_execution_role_arn // optional (type: string) default = null
  ecs_service_role_name                = var.ecs_service_role_name // optional (type: string) default = "AWSServiceRoleForECS"

  
  // Optional ECS
  deployment_maximum_percent           = var.deployment_maximum_percent // optional (type: number) default = 200
  deployment_minimum_healthy_percent   = var.deployment_minimum_healthy_percent // optional (type: number) default = 100
  desired_count                        = var.desired_count // optional (type: number) default = 1
  enable_ecs_managed_tags              = var.enable_ecs_managed_tags // optional (type: bool) default = false
  health_check_grace_period_seconds    = var.health_check_grace_period_seconds // optional (type: number) default = 0
  ordered_placement_strategy           = var.ordered_placement_strategy // optional (type: list(map(id = "", field = ""))) defaults = []
  placement_constraints                = var.placement_constraints // optional (type: list(map(type = "", expression = ""))) default = []
  propagate_tags                       = var.propagate_tags // optional (type: string) default = "SERVICE"
  service_registries                   = var.service_registries // optional (type: map(registry_arn = "", port = 0, container_port = 0, container_name = "")) defaults to {}
  log_retention_days                   = var.log_retention_days // optional (type: number) defaults to 30
  
  // Optional Task Definition
  container_port                       = var.container_port // optional (type: number) default = 3001
  log_group                            = var.log_group // optional (type: string) default = "ecs{generated service name | name_override}"
  task_cpu                             = var.task_cpu // optional (type: number) default = 128
  task_memory                          = var.task_memory // optional (type: number) default = 128
  aws_logs_stream_prefix               = var.aws_logs_stream_prefix // optional (type: string) default = "ecs"
  host_port                            = var.host_port // optional (type: number) default = 0


  // Optional Load Balancer/Target Group
  listener_port                        = var.listener_port // optional (type: string) default = 80
  tg_port                              = var.tg_port // optional (type: string) default = 80
  tg_protocol                          = var.tg_protocol // optional (type: string) default = "HTTP"
  tg_health_check_timeout              = var.tg_health_check_timeout // optional (type: number) defaults to 2
  tg_health_check_interval             = var.tg_health_check_interval // optional (type: number) defaults to 5
  tg_health_check_unhealthy_threshold  = var.tg_health_check_unhealthy_threshold // optional (type: number) defaults to 2
  tg_health_check_healthy_threshold    = var.tg_health_check_healthy_threshold // optional (type: number) defaults to 10
  tg_health_check_matcher              = var.tg_health_check_matcher // optional (type: number) defaults to 200
  listener_priority                    = var.listener_priority // optional (type: number) defaults to 1

  // Optional Auto Scaling Policy
  autoscale_down_policy_type           = var.autoscale_down_policy_type // Optional (type: string) default = "StepScaling"
  autoscale_down_metric_adj_type       = var.autoscale_down_metric_adj_type // Optional (type: string) default = "ChangeInCapacity"
  autoscale_down_cooldown              = var.autoscale_down_cooldown // Optional (type: number) default = 60
  autoscale_down_int_upper             = var.autoscale_down_int_upper // Optional (type: number) default = 0
  scale_down_step                      = var.scale_down_step // Optional (type: number) default = -3
  autoscale_up_policy_type             = var.autoscale_up_policy_type // Optional (type: string) default = StepScaling
  autoscale_up_metric_adj_type         = var.autoscale_up_metric_adj_type // Optional (type: string) default = ChangeInCapacity
  autoscale_up_cooldown                = var.autoscale_up_cooldown // Optional (type: number) default = 60
  autoscale_up_int_lower               = var.autoscale_up_int_lower // Optional (type: number) default = 60
  scale_up_step                        = var.scale_down_step // Optional (type: number) default = 3

  // Optional Auto Scaling Metric
  scale_up_metric                      = var.scale_up_metric // Optional (type: string)  default = "RequestCountPerTarget"
  scale_up_comparison_operator         = var.scale_up_comparison_operator // Optional (type: string) default = "GreaterThanOrEqualToThreshold"
  scale_up_threshold                   = var.scale_up_threshold // Optional (type: number) default = 300
  scale_up_treat_missing_data          = var.scale_up_treat_missing_data // Optional (type: string) default = "notBreaching"
  scale_up_statistic                   = var.scale_up_statistic // Optional (type: string) default = "Sum"
  scale_up_period                      = var.scale_up_period // Optional (type: number) default = 60
  scale_up_evaluation_periods          = var.scale_up_evaluation_periods // Optional (type: number) default = 1
  scale_up_datapoints_to_alarm         = var.scale_up_datapoints_to_alarm // Optional (type: number) default = 1
  scale_up_namespace                   = var.scale_up_namespace // Optional (type: string) default = "AWS/ApplicationELB
  scale_down_metric                    = var.scale_down_metric // Optional (type: string) default = "RequestCountPerTarget"
  scale_down_comparison_operator       = var.scale_down_comparison_operator // Optional (type: string) default = "LessThanOrEqualToThreshold
  scale_down_threshold                 = var.scale_down_threshold // Optional (type: number) scale_down_threshold = 100
  scale_down_treat_missing_data        = var.scale_down_treat_missing_data // Optional (type: string) default = "breaching"
  scale_down_statistic                 = var.scale_down_statistic // Optional (type: string) default = "Sum"
  scale_down_period                    = var.scale_down_period // Optional (type: number) default = 60
  scale_down_evaluation_periods        = var.scale_down_evaluation_periods // Optional (type: number) default = 1
  scale_down_datapoints_to_alarm       = var.scale_down_datapoints_to_alarm // Optional (type: number) default = 1
  scale_down_namespace                 = var.scale_down_namespace // Optional (type: string) default = "AWS/ApplicationELB"

  // Optional Autoscaling Target
  service_max_task_count               = var.service_max_task_count // Optional (type: number) default = 20
  service_min_task_count               = var.service_min_task_count // Optional (type: number) default = 3

}
```

## Limitations

- ECS containers only support port 80/http currently 

## TODO:
* Update the above docs with autoscaling info
* Add variables for autoscaling metrics to readme
* Add default CPU utilization and memory utilization as options for autoscaling metrics
* Add additional port/protocol options (currently only 80/http)
* supoort fargate
* get listener ARN from alb name