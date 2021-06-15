#------------------------------------------------------------------------------
# Misc
#------------------------------------------------------------------------------

variable "aws_region" {
  type = string
}

variable "aws_short_region" {
  description = "The short name for an AWS region"
  default = {
    us-west-1 = "usw1"
    us-west-2 = "usw2"
    eu-central-1	= "euc1"
    eu-west-1 = "euw1"
    eu-west-2 = "euw2"
    eu-west-3	= "euw3"
    eu-north-1	= "eun1"
    eu-south-1	= "eus1"
    us-east-1 = "use1"
    us-east-2 = "use2"
    af-south-1 = "afs1"
    ap-east-1	= "ape1"
    ap-south-1 = "aps1"
    ap-northeast-1 = "apne1"
    ap-northeast-2 = "apne2"
    ap-northeast-3 = "apne3"
    ap-southeast-1 = "apse1"
    ap-southeast-2 = "apse2"
    ca-central-1	= "cac1"
    cn-north-1	= "cnn1"
    cn-northwest-1	= "cnnw1"
    me-south-1	= "mes1"
    sa-east-1	= "sae1"
  }
}

variable "name_preffix" {
  description = "Name preffix for resources on AWS."
  type = string
}

variable "name_override" {
  description = "Overrides name generaged from name_preffix, region, and environment."
  default = ""
}

variable "environment" {
  description = "Environment."
  default = "tst"
}


#------------------------------------------------------------------------------
# IAM
#------------------------------------------------------------------------------

variable "ecs_service_role_name" {
  description = "iam role for the ecs service (used to communicate with load balancer)."
  default = "AWSServiceRoleForECS"
}
#------------------------------------------------------------------------------
# AWS Networking
#------------------------------------------------------------------------------
variable "vpc_id" {
  description = "ID of the VPC"
  type = string
}

variable "network_configuration" {
  description = "AWS Network Configuration. Only necessary if using Fargate launch type."
  type = object({
    subnets = list(string)
    security_groups = list(string)
    assign_public_ip = bool
  })
  default = null
}

#------------------------------------------------------------------------------
# AWS ECS SERVICE
#------------------------------------------------------------------------------

variable "ecs_cluster_name" {
  description = "Name of an ECS cluster"
  type = string
}

variable "launch_type" {
  description = "ECS launch type"
  type = string
  default = "EC2"

  validation {
    condition = var.launch_type == "EC2" || var.launch_type == "FARGATE" || var.launch_type == "FARGATE_SPOT" 
    error_message = "Launch type must be one of \"EC2\", \"FARGATE\", \"FARGATE_SPOT\"."
  }
}

variable "deployment_maximum_percent" {
  description = "(Optional) The upper limit (as a percentage of the service's desiredCount) of the number of running tasks that can be running in a service during a deployment."
  type        = number
  default     = 200
}

variable "deployment_minimum_healthy_percent" {
  description = "(Optional) The lower limit (as a percentage of the service's desiredCount) of the number of running tasks that must remain running and healthy in a service during a deployment."
  type        = number
  default     = 100
}

variable "desired_count" {
  description = "(Optional) The number of instances of the task definition to place and keep running. Defaults to 0."
  type        = number
  default     = 1
}

variable "enable_ecs_managed_tags" {
  description = "(Optional) Specifies whether to enable Amazon ECS managed tags for the tasks within the service."
  type        = bool
  default     = false
}

variable "health_check_grace_period_seconds" {
  description = "(Optional) Seconds to ignore failing load balancer health checks on newly instantiated tasks to prevent premature shutdown, up to 2147483647. Only valid for services configured to use load balancers."
  type        = number
  default     = 0
}

variable "ordered_placement_strategy" {
  description = "(Optional) Service level strategy rules that are taken into consideration during task placement. List from top to bottom in order of precedence. The maximum number of ordered_placement_strategy blocks is 5. This is a list of maps where each map should contain \"id\" and \"field\""
  type        = list
  default     = []
}

variable "placement_constraints" {
  type        = list
  description = "(Optional) rules that are taken into consideration during task placement. Maximum number of placement_constraints is 10. This is a list of maps, where each map should contain \"type\" and \"expression\""
  default     = []
}

variable "propagate_tags" {
  description = "(Optional) Specifies whether to propagate the tags from the task definition or the service to the tasks. The valid values are SERVICE and TASK_DEFINITION. Default to SERVICE"
  default     = "SERVICE"
}

variable "service_registries" {
  description = "(Optional) The service discovery registries for the service. The maximum number of service_registries blocks is 1. This is a map that should contain the following fields \"registry_arn\", \"port\", \"container_port\" and \"container_name\""
  type        = map
  default     = {}
}

variable "log_retention_days" {
  description = "Log retention days for ecs service"
  type = number
  default = 30
}

variable "environment_variables" {
  description = "Environment variables to provide to service"
  type = list(object({
    name = string
    value = string
  }))
  default = []
}

variable "secrets" {
  description = "Secrets to provide as variables to service via Secrets Manager or Parameter Store"
  type = list(object({
    name = string
    valueFrom = string
  }))
  default = []
}

#------------------------------------------------------------------------------
# AWS LOAD BALANCER
#------------------------------------------------------------------------------

variable "create_load_balancing" {
  description = "whether or not to create load balancing for this service. If true a listener rule and target group will be created."
  type = bool
  default = true
}

variable "lb_name" {
  description = "Name of LB to get listener arn from"
  type = string
  default = null
}

variable "listener_port" {
  description = "Port that the listener will be listening on via he LB"
  type = number
  default = 80
}

variable "tg_port" {
  description = "Port that ECS will recieve traffic on from the LB listener"
  type        = string
  default = 80
}

variable "tg_protocol" {
  description = "Protocol that ECS will recieve traffic via the LB"
  type        = string
  default = "HTTP"
}

variable "tg_health_check_path" {
  description = "Target group health check path"
  type = string
  default = "/"
}

variable "tg_health_check_timeout" {
  description = "Target group health check timeout (must be less than interval)"
  type = number
  default = 2
}

variable "tg_health_check_interval" {
  description = "Target group health check interval"
  type = number
  default = 5
}

variable "tg_health_check_unhealthy_threshold" {
  description = "Unhealthy threshold for target group health check"
  type = number
  default = 2
}

variable "tg_health_check_healthy_threshold" {
  description = "Healthy threshold for target group health check"
  type = number
  default = 10
}

variable "tg_health_check_matcher" {
  description = "Status code for target group health check"
  type = string
  default = 200
}

variable "listener_protocol" {
  description = "Protocol for LB listener"
  type = string
  default = "HTTP"
}

variable "listener_priority" {
  description = "priority of endpiont listener" 
  type = number
  default = 1
}

variable "path_patterns" {
  description = "Pattern for your service endpoint"
  type = list(string)
  default = []
}

#------------------------------------------------------------------------------
# TASK DEFINITION
#------------------------------------------------------------------------------

variable "task_execution_role_arn" {
  description = "Task execution role arn"
  type = string
  default = null
}

variable "task_definition_family" {
  description = "The task definition family (the part before the number)"
  type = string
}

variable "container_name" {
  description = "Name of container that will be running inside the task"
  type = string
}

variable "container_image" {
  description = "Image to be used by the container, e.g. 1234567891012.dkr.ecr.us-west-2.amazonaws.com/hello-world"
  type = string
}

variable "container_port" {
  description = "Container port."
  type = number
  default = 3001
}

variable "host_port" {
  description = "Host port. Should be 0 for auto-port assignment." 
  type = number
  default = 0
}

variable "task_cpu" {
  description = "CPU units to be used per task"
  type = number
  default = 128
}

variable "task_memory" {
  description = "memory units to be used per task"
  type = number
  default = 128
}

variable "log_group" {
  description = "Log group for ecs service, defaults to generated service name"
  type = string
  default = null
}

variable "aws_logs_stream_prefix" {
  description = "Prefix for log stream"
  type = string
  default = "ecs"
}

variable "tags" {
  description = "tags"
  type = map
  default = {}
}

variable "ignore_task_def_after_creation" {
  description = "Whether to ignore the task definition after creation to be handled by CI/CD"
  type = bool
  default = false
}

#------------------------------------------------------------------------------
# AUTO SCALING
#------------------------------------------------------------------------------

// Policy
variable "autoscale_down_policy_type" {
  type        = string
  description = "For DynamoDB, only TargetTrackingScaling is supported. For Amazon ECS, Spot Fleet, and Amazon RDS, both StepScaling and TargetTrackingScaling are supported. For any other service, only StepScaling is supported. Defaults to StepScaling"
  default     = "StepScaling"
}

variable "autoscale_down_metric_adj_type" {
  type        = string
  description = "Specifies whether the adjustment is an absolute number or a percentage of the current capacity. Valid values are ChangeInCapacity, ExactCapacity, and PercentChangeInCapacity"
  default     = "ChangeInCapacity"
}

variable "autoscale_down_cooldown" {
  type        = number
  description = "The amount of time, in seconds, after a scaling activity completes and before the next scaling activity can start."
  default     = 60
}

variable "autoscale_down_int_upper" {
  type        = number
  description = "The upper bound for the difference between the alarm threshold and the CloudWatch metric. Without a value, AWS will treat this bound as infinity. The upper bound must be greater than the lower bound."
  default     = 0
}

variable "scale_down_step" {
  type        = number
  description = "The number of members by which to scale down, when the adjustment bounds are breached. A positive value scales up. A negative value scales down."
  default     = -1
}

variable "autoscale_up_policy_type" {
  type        = string
  description = "For DynamoDB, only TargetTrackingScaling is supported. For Amazon ECS, Spot Fleet, and Amazon RDS, both StepScaling and TargetTrackingScaling are supported. For any other service, only StepScaling is supported. Defaults to StepScaling"
  default     = "StepScaling"
}

variable "autoscale_up_metric_adj_type" {
  type        = string
  description = "Specifies whether the adjustment is an absolute number or a percentage of the current capacity. Valid values are ChangeInCapacity, ExactCapacity, and PercentChangeInCapacity"
  default     = "ChangeInCapacity"
}

variable "autoscale_up_cooldown" {
  type        = number
  description = "The amount of time, in seconds, after a scaling activity completes and before the next scaling activity can start."
  default     = 60
}

variable "autoscale_up_int_lower" {
  type        = number
  description = "The lower bound for the difference between the alarm threshold and the CloudWatch metric. Without a value, AWS will treat this bound as negative infinity."
  default     = 0
}

variable "scale_up_step" {
  type        = number
  description = "The number of members by which to scale down, when the adjustment bounds are breached. A positive value scales up. A negative value scales down."
  default     = 1
}

// Metric (scale up)
variable "scale_up_metric" {
  type        = string
  description = "https://docs.aws.amazon.com/elasticloadbalancing/latest/application/load-balancer-cloudwatch-metrics.html"
  default     = "RequestCountPerTarget"
}

variable "scale_up_comparison_operator" {
  type        = string
  description = "scale up comparison operator"
  default     = "GreaterThanOrEqualToThreshold"
}

variable "scale_up_threshold" {
  type        = number
  description = "Threshold which triggers cloudwatch alarm and therefore autoscale up action when metric value crosses threshold value"
  default     = 300
}

variable "scale_up_treat_missing_data" {
  type        = string
  description = "scale up treat missing data"
  default     = "notBreaching"
}

variable "scale_up_statistic" {
  type        = string
  description = "The statistic to apply to the alarm's associated metric. Either of the following is supported: SampleCount, Average, Sum, Minimum, Maximum"
  default     = "Sum"
}

variable "scale_up_period" {
  type        = number
  description = "The period length applied to the scale up statistic metric"
  default     = 60
}

variable "scale_up_evaluation_periods" {
  type        = number
  description = "The number of periods evaluated by the scale up statistic metric"
  default     = 1
}

variable "scale_up_datapoints_to_alarm" {
  type        = number
  description = "The number of datapoints that must be breaching to cause the scale up metric to be in alarm"
  default     = 1
}

variable "scale_up_namespace" {
  type        = string
  description = "Scale up metric namespace"
  default     = "AWS/ApplicationELB"
}


// Metric (scale down)

variable "scale_down_metric" {
  type        = string
  description = "https://docs.aws.amazon.com/elasticloadbalancing/latest/application/load-balancer-cloudwatch-metrics.html"
  default     = "RequestCountPerTarget"
}

variable "scale_down_comparison_operator" {
  type        = string
  description = "scale down comparison operator"
  default     = "LessThanOrEqualToThreshold"
}

variable "scale_down_threshold" {
  type        = number
  description = "Threshold which triggers cloudwatch alarm and therefore autoscale down action when metric value crosses threshold value"
  default     = 100
}

variable "scale_down_treat_missing_data" {
  type        = string
  description = "scale down treat missing data"
  default     = "breaching"
}

variable "scale_down_statistic" {
  type        = string
  description = "The statistic to apply to the alarm's associated metric. Either of the following is supported: SampleCount, Average, Sum, Minimum, Maximum"
  default     = "Sum"
}

variable "scale_down_period" {
  type        = number
  description = "The period length applied to the scale down statistic metric"
  default     = 60
}

variable "scale_down_evaluation_periods" {
  type        = number
  description = "The number of periods evaluated by the scale down statistic metric"
  default     = 1
}

variable "scale_down_datapoints_to_alarm" {
  type        = number
  description = "The number of datapoints that must be breaching to cause the scale down metric to be in alarm"
  default     = 1
}

variable "scale_down_namespace" {
  type        = string
  description = "Scale down metric namespace"
  default     = "AWS/ApplicationELB"
}

// Target
variable "service_max_task_count" {
  type        = number
  description = "The maximum value to scale to in response to a scale-out event. MaxCapacity is required to register a scalable target."
  default     = 20
}

variable "service_min_task_count" {
  type        = number
  description = "The minimum value to scale to in response to a scale-in event. MinCapacity is required to register a scalable target."
  default     = 1
}

variable "create_autoscaling" {
  type = bool
  description = "Whether or not to create autoscaling for the service."
  default = true
}