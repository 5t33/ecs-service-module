# Module for creating an ECS service

Heavily borrowed from:
* https://github.com/cn-terraform/terraform-aws-ecs-fargate-service

## Usage

```
module "ecs_service" {
  source = "../../../Shared/Modules/ecs-service"   
  environment = var.environment // required (type: string)
  aws_region  = var.aws_region // required (type: string)
  aws_profile = var.aws_profile // required (type: string)
  name_preffix = var.name_preffix // required (type: string)
  desired_count = var.desired_count // required (type: number)
  ecs_cluster_name = var.ecs_cluster_name // required (type: string)
  vpc_id = var.vpc_id // required (type: string)
  listener_arn = var.listener_arn // required (type: string)
  path_patterns = var.path_patterns // required (type: list(string))
  container_name = var.container_name // required (type: string)
  container_port = var.container_port // required (type: number)
  container_image = var.container_image // required (type: string)
  tg_health_check_path = var.tg_health_check_path // required (type: string)
  task_definition_family = var.task_definition_family // required (type: string)
  
  tags = var.tags // optional (type: map) default = ""
  name_override = var.name_override // optional (type: string) defaults to "", unused if left blank
  ecs_service_role_name = var.ecs_service_role_name // optional (type: string) defaults to "AWSServiceRoleForECS"
  deployment_maximum_percent = var.deployment_maximum_percent // optional (type: number) defaults to 200
  deployment_minimum_healthy_percent = var.deployment_minimum_healthy_percent // optional (type: number) defaults to 100
  desired_count = var.desired_count // optional (type: number) defaults to 1
  enable_ecs_managed_tags = var.enable_ecs_managed_tags // optional (type: bool) defaults to false
  health_check_grace_period_seconds = var.health_check_grace_period_seconds // optional (type: number) defaults to 0
  ordered_placement_strategy = var.ordered_placement_strategy // optional (type: list(map(id = "", field = ""))) defaults = []
  placement_constraints = var.placement_constraints // optional (type: list(map(type = "", expression = ""))) defaults to []
  propagate_tags = var.propagate_tags // optional (type: string) defaults to "SERVICE"
  service_registries = var.service_registries // optional (type: map(registry_arn = "", port = 0, container_port = 0, container_name = "")) defaults to {}
  tg_health_check_timeout = var.tg_health_check_timeout // optional (type: number) defaults to 2
  tg_health_check_interval = var.tg_health_check_interval // optional (type: number) defaults to 5
  tg_health_check_unhealthy_threshold = var.tg_health_check_unhealthy_threshold // optional (type: number) defaults to 2
  tg_health_check_healthy_threshold = var.tg_health_check_healthy_threshold // optional (type: number) defaults to 10
  tg_health_check_matcher = var.tg_health_check_matcher // optional (type: number) defaults to 200
  listener_port = var.listener_port // optional (type: number) defaults to 80
  listener_protocol = var.listener_protocol // optional (type: string) defaults to "HTTP"
  listener_priority = var.listener_priority // optional (type: number) defaults to 1
  task_execution_role_arn = var.task_execution_role_arn // optional (type: string) defaults to null
  container_port = var.container_port // optional (type: number) defaults to 3001
  task_cpu = var.task_cpu // optional (type: number) defaults to 128
  task_memory = var.task_memory // optional (type: number) defaults to 128
  log_group = var.log_group // optional (type: string) defaults to "ecs/{generated service name | name_override}"
  aws_logs_stream_prefix = var.aws_logs_stream_prefix // optional (type: string) defaults to "ecs"
}
```

## Limitations

- ECS containers only support port 80/http currently 

## TODO:
* Update the above docs with autoscaling info
* Add variables for autoscaling metrics to readme
* Add default CPU utilization and memory utilization as options for autoscaling metrics
* Add additional port/protocol options (currently only 80/http)