# Module for creating an ECS service

Inspired by:
* https://github.com/cn-terraform/terraform-aws-ecs-fargate-service

## Usage

```
module "ecs_service" {
  source = "git@github.com:5t33/ecs-service-module?ref=v0.2.1alpha" 
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
  network_configuration                = var.network_configuration // optional as a variable but required for fargate launch type. Unused otherwise. (type: { subnets: list(string), security_groups: list(string), assign_public_ip: bool})
  
  // Optional Task Definition
  container_port                       = var.container_port // optional (type: number) default = 3001
  log_group                            = var.log_group // optional (type: string) default = "ecs{generated service name | name_override}"
  task_cpu                             = var.task_cpu // optional (type: number) default = 128
  task_memory                          = var.task_memory // optional (type: number) default = 128
  aws_logs_stream_prefix               = var.aws_logs_stream_prefix // optional (type: string) default = "ecs"
  host_port                            = var.host_port // optional (type: number) default = 0 (0 is used for auto-assign IP in instance type. host port is set to same as container port for fargate launch type)


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

## Examples


### Launch Type EC2
```
provider aws {
  region = var.aws_region
  profile = var.aws_profile
}

data "aws_caller_identity" "this" {}

locals { 
  image_repo = "hello-world"
  account_id = data.aws_caller_identity.this.account_id
}
locals {
  container_image = "${local.account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/${local.image_repo}:latest"
  subnet_arns = [for subnet in var.subnets: "arn:aws:ec2:${var.aws_region}:${local.account_id}:subnet/${subnet}"]
}

module "hello-world" {
    source      = "git@github.com:5t33/ecs-service-module?ref=v0.2.1alpha"
    environment = "tst"
    launch_type = "EC2"
    aws_region  = var.aws_region
    task_execution_role_arn = aws_iam_role.task_role.arn
    name_preffix = "hello-world"
    ecs_cluster_name = "test-temp"
    vpc_id = "vpc-ad27b8c4"
    lb_name = "temp-lb"
    path_patterns = [ "/api/v1/hello_world*" ]
    container_name = "hello-world"
    container_port = 3001
    container_image = local.container_image
    tg_health_check_path = "/api/v1/hello_world/health_check"
    tg_port = 80
    tg_protocol = "HTTP"
    task_definition_family = "hello-world"
    listener_port = 80
    ignore_task_def_after_creation = true
    log_retention_days = 90
    create_autoscaling = true
    task_cpu = 128
    task_memory = 128
    tags = {
      Environment = "tst"
    }
}


resource "aws_iam_role" "task_role" {
  name = "hello-world-task-role"
  description = "Hello world task role."
  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Service": "ecs-tasks.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "task_policy" {
  name = "hello-world-task-policy"
  path        = "/"
  description = "Hello world task policy."

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
          "Sid": "ECSTaskManagement",
          "Effect": "Allow",
          "Action": [
              "ec2:AttachNetworkInterface",
              "ec2:CreateNetworkInterface",
              "ec2:CreateNetworkInterfacePermission",
              "ec2:DeleteNetworkInterface",
              "ec2:DeleteNetworkInterfacePermission",
              "ec2:Describe*",
              "ec2:DetachNetworkInterface"
          ],
          "Resource": "*",
          "Condition": {
              "StringEquals": {
                "ec2:Vpc": "vpc-053c9c7d",
                "ec2:Subnet": local.subnet_arns,
                "ec2:AuthorizedService": "ecs.amazonaws.com"
              }
            }
        },
        {
            "Action": [
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Effect": "Allow",
            "Resource": [
                "arn:aws:logs:${var.aws_region}:${local.account_id}:log-group:ecs/hello-world-use2-tst*"
            ],
            "Sid": "Logs"
        },
        {
            "Action": [
                "ecr:GetDownloadUrlForLayer",
                "ecr:BatchGetImage",
                "ecr:BatchCheckLayerAvailability"
            ],
            "Effect": "Allow",
            "Resource": ["arn:aws:ecr:*:${local.account_id}:repository/hello-world"],
            "Sid": "ECRReadOnly"
        },
        {
          "Action": [
              "ecr:GetAuthorizationToken"
          ],
          "Effect": "Allow",
          "Resource": "*",
          "Sid": "ECRToken"
        }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attachment" {
  role = aws_iam_role.task_role.name
  policy_arn = aws_iam_policy.task_policy.arn
}
```

### Launch Type Fargate 
```
provider aws {
  region = var.aws_region
  profile = var.aws_profile
}

data "aws_caller_identity" "this" {}

locals { 
  image_repo = "hello-world"
  account_id = data.aws_caller_identity.this.account_id
}
locals {
  container_image = "${local.account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/${local.image_repo}:latest"
  subnet_arns = [for subnet in var.subnets: "arn:aws:ec2:${var.aws_region}:${local.account_id}:subnet/${subnet}"]
}

module "hello-world" {
    source      = "git@github.com:5t33/ecs-service-module?ref=v0.2.1alpha"
    environment = "tst"
    launch_type = "FARGATE"
    aws_region  = var.aws_region
    task_execution_role_arn = aws_iam_role.task_role.arn
    name_preffix = "hello-world"
    ecs_cluster_name = "test-temp"
    vpc_id = "vpc-ad27b8c4"
    lb_name = "temp-lb"
    path_patterns = [ "/api/v1/hello_world*" ]
    container_name = "hello-world"
    container_port = 3001
    container_image = local.container_image
    tg_health_check_path = "/api/v1/hello_world/health_check"
    tg_port = 80
    tg_protocol = "HTTP"
    task_definition_family = "hello-world"
    listener_port = 80
    ignore_task_def_after_creation = true
    log_retention_days = 90
    create_autoscaling = true
    task_cpu = 256
    task_memory = 512
    tags = {
      Environment = "tst"
    }
    network_configuration = {
      subnets = var.subnets
      security_groups = var.security_groups
      assign_public_ip = false
    }
}


resource "aws_iam_role" "task_role" {
  name = "hello-world-task-role"
  description = "Hello world task role."
  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Service": "ecs-tasks.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "task_policy" {
  name = "hello-world-task-policy"
  path        = "/"
  description = "Hello world task policy."

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
          "Sid": "ECSTaskManagement",
          "Effect": "Allow",
          "Action": [
              "ec2:AttachNetworkInterface",
              "ec2:CreateNetworkInterface",
              "ec2:CreateNetworkInterfacePermission",
              "ec2:DeleteNetworkInterface",
              "ec2:DeleteNetworkInterfacePermission",
              "ec2:Describe*",
              "ec2:DetachNetworkInterface"
          ],
          "Resource": "*",
          "Condition": {
              "StringEquals": {
                "ec2:Vpc": "vpc-053c9c7d",
                "ec2:Subnet": local.subnet_arns,
                "ec2:AuthorizedService": "ecs.amazonaws.com"
              }
            }
        },
        {
            "Action": [
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Effect": "Allow",
            "Resource": [
                "arn:aws:logs:${var.aws_region}:${local.account_id}:log-group:ecs/hello-world-use2-tst*"
            ],
            "Sid": "Logs"
        },
        {
            "Action": [
                "ecr:GetDownloadUrlForLayer",
                "ecr:BatchGetImage",
                "ecr:BatchCheckLayerAvailability"
            ],
            "Effect": "Allow",
            "Resource": ["arn:aws:ecr:*:${local.account_id}:repository/hello-world"],
            "Sid": "ECRReadOnly"
        },
        {
          "Action": [
              "ecr:GetAuthorizationToken"
          ],
          "Effect": "Allow",
          "Resource": "*",
          "Sid": "ECRToken"
        }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attachment" {
  role = aws_iam_role.task_role.name
  policy_arn = aws_iam_policy.task_policy.arn
}

```

## Autoscaling (Untested)

```
module "hello-world" {
  ...
  create_autoscaling = true
  step_scaling_policies = {
    scale_up_policy = {
      metric_adj_type = "ChangeInCapacity"
      metric_aggregation_type = "Average"
      cooldown = 60
      metric_interval_upper_bound = 0
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
  scale_up_metric_alarms = [
    {
      metric = "CPUUtilization"
      comparison_operator = "GreaterThanOrEqualToThreshold"
      threshold = 60
      treat_missing_data = "missing"
      statistic = "Average"
      period = 60
      datapoints_to_alarm = 1
      dimensions = {
        ClusterName = "my-cluster-name",
        ServiceName = "hello-world"
      } //todo
      namespace = "AWS/ECS"
      tags = {
        environment = "prd"
        service = "hello-world"
        team    = "my-team"
      }
      metric_queries = []
   }
  ]
  scale_down_metric_alarms = [
    {
      metric = "CPUUtilization"
      comparison_operator = "LessThanOrEqualToThreshold"
      threshold = 20
      treat_missing_data = "missing"
      statistic = "Average"
      period = 60
      datapoints_to_alarm = 3
      dimensions = {
        ClusterName = "my-cluster-name",
        ServiceName = "hello-world"
      } //todo
      namespace = "AWS/ECS"
      tags = {
        environment = "prd"
        service = "hello-world"
        team    = "my-team"
      }
      metric_queries = []
   }
  ]
}
```

## TODO:
* Add default CPU utilization, memory utilization, and request count as options for autoscaling metrics in addition to custom
* Move autoscaling to blocks instead of flat variables
