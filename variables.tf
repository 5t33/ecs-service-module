#------------------------------------------------------------------------------
# Misc
#------------------------------------------------------------------------------

variable "aws_region" {
  type = string
}

variable "environment" {
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
  description = "Name preffix for resources on AWS"
  type = string
}

variable "name_override" {
  description = "Overrides name generaged from name_preffix, region, and environment"
  default = ""
}

variable "use_custom_kms" {
  default = false
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

variable "container_name" {
  description = "Name of container that will be running inside the task"
  type = string
}

variable "container_port" {
  description = "Container port."
  type = number
  default = 3001
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
  type        = object({
    registry_arn = string
    port = optional(number, null)
    container_name = optional(string, null)
    container_port = optional(number, null)
  })
  default     = null
}

variable "log_retention_days" {
  description = "Log retention days for ecs service"
  type = number
  default = 30
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


#------------------------------------------------------------------------------
# AWS LOAD BALANCER
#------------------------------------------------------------------------------

variable "load_balancing" {
  description = "Load balancing config. This assumes a load balancer already exists. It ill append the necessary listener rule."
  type = object({
    load_balancer_name = string
    listener_port = number
    listener_priority = optional(number, 1)
    path_patterns = optional(list(string), ["/"])
    target_group = optional(
      object({
        port = optional(number, 80)
        protocol = optional(string, "HTTP")
        health_check_path = optional(string, "/")
        health_check_timeout = optional(number, 2)
        health_check_interval = optional(number, 5)
        health_check_unhealthy_threshold = optional(number, 3)
        health_check_healthy_threshold = optional(number, 2)
        health_check_matcher = optional(number, 200)
      }), {
        port = 80
        protocol = "HTTP"
        health_check_path = "/"
        health_check_timeout = 2
        health_check_interval = 5
        health_check_unhealthy_threshold = 5
        health_check_healthy_threshold = 10
        health_check_matcher = 200
      })
  })
  default = null
}

#------------------------------------------------------------------------------
# TASK DEFINITION
#------------------------------------------------------------------------------

variable "task_definition_arn" {
  type = string
  default = null
}

variable "task_definition" {
  type = object({
    executionRoleArn = optional(string, null)
    taskRoleArn = optional(string, null)
    family = string
    ephemeralStorage = optional(object({
      sizeInGiB = number
    }), null)
    runtimePlatform = optional(object({
      operatingSystemFamily = optional(string, null)
      cpuArchitecture = optional(string, null)
    }), null)
    volumes = optional(
      list(
        object({
          name = string
          hostPath = optional(string, null)
          efs_volume_configuration = optional(object({
            fileSystemId = string
            rootDirectory = optional(string, null)
            transitEncryption = optional(string, null)
            transitEncryptionPort = optional(number, null)
            authorizationConfig = optional(object({
              accessPointId = optional(string, null)
              iam = optional(string, null)
            }), null)
          }), null)
        })
      ),
      []
    )
    cpu = optional(number, null)
    memory = optional(number, null)
    containerDefinitions = list(
      object({
        essential = optional(bool, true)
        name = optional(string, null)
        image = optional(string, null)
        command = optional(string, null)
        cpu = optional(number, null)
        memory = optional(number, null)
        environment = optional(list(object({
          name = string
          value = string
        })))
        secrets = optional(list(object({
          name = string
          valueFrom = string
        })))
        protocol = optional(string, "tcp")
        portMappings = optional(list(object({
          containerPort: number,
          hostPort: optional(number, null),
          protocol: optional(string, "tcp")
        })), [])
        mountPoints = optional(list(object({
          sourceVolume = string
          containerPath = string
          readOnly = optional(bool, false)
        })),[])
        volumesFrom = optional(list(object({
          sourceContainer = string
          readOnly = optional(bool, false)
        })),[])
      })
    )
  })
  default = null
}

#------------------------------------------------------------------------------
# AUTO SCALING
#------------------------------------------------------------------------------

variable "scaling_policy_type" {
  type = string
  default = "StepScaling"
  validation {
    condition = var.scaling_policy_type == "StepScaling"
    error_message = "Currently only StepScaling is supported."
  }
}

variable "scale_up_metric_alarms" {
  type = list(object({
      metric = string
      comparison_operator = string
      threshold = number
      treat_missing_data = string
      statistic = string
      period = number
      evaluation_periods = number
      datapoints_to_alarm = number
      dimensions = optional(map(string), {})
      namespace = string
      tags = optional(map(string), {})
      metric_queries = list(object({
        id = string
        expression = string 
        label = string
        return_data = string
        metric = object({
          metric_name = string
          namespace   = string
          period      = number
          stat        = string
          unit        = string
          dimensions = map(string)
        })
      }))
    }))
  default = []
}

variable "scale_down_metric_alarms" {
  type = list(object({
    metric = string
    comparison_operator = string
    threshold = number
    treat_missing_data = string
    statistic = string
    period = number
    evaluation_periods = number
    datapoints_to_alarm = number
    dimensions = optional(map(string), {})
    namespace = string
    tags = optional(map(string), {})
    metric_queries = list(object({
      id = string
      expression = string 
      label = string
      return_data = string
      metric = object({
        metric_name = string
        namespace   = string
        period      = number
        stat        = string
        unit        = string
        dimensions = map(string)
      })
    }))
  }))
  default = []
}

variable "step_scaling_policies" {
  description = "see https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm"
  type = object({
    scale_up_policy = object({
      metric_adj_type = string
      cooldown = number
      metric_aggregation_type = string
      metric_interval_lower_bound = number
      scale_up_step = number
    })
    scale_down_policy = object({
      metric_adj_type = string
      cooldown = number
      metric_aggregation_type = string
      metric_interval_upper_bound = number
      scale_down_step = number
    })
  })
  default = {
    scale_up_policy = {
      metric_adj_type = "ChangeInCapacity"
      metric_aggregation_type = "Average"
      cooldown = 60
      metric_interval_lower_bound = 0
      scale_up_step = 1
    }
    scale_down_policy = {
      metric_adj_type = "ChangeInCapacity"
      metric_aggregation_type = "Average"
      cooldown = 60
      metric_interval_upper_bound = 0
      scale_down_step = 1
    }
  }
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

variable "enable_execute_command" {
  type = bool
  default = false
}

variable "task_role_arn" {
  type = string
  default = null
}

variable "create_blue_green_deploy_tgs" {
  type = bool
  default = false
}

variable "runtime_platform" {
  type = map(string)
  default = null
}