locals {
  service_name = var.name_override != "" ? var.name_override : "${var.name_preffix}-${var.aws_short_region[var.aws_region]}-${var.environment}"
  account_id = data.aws_caller_identity.this.account_id
  log_group_name = var.log_group == null ? "ecs/${local.service_name}" : var.log_group 
}

#------------------------------------------------------------------------------
# IAM
#------------------------------------------------------------------------------

data "aws_iam_role" "ecs_service_role" {
  name = var.ecs_service_role_name
}

data "aws_caller_identity" "this" {}

#------------------------------------------------------------------------------
# AWS LOAD BALANCER
#------------------------------------------------------------------------------
data "aws_lb" "selected" {
  count = var.create_load_balancing ? 1 : 0
  name = var.lb_name
}

data "aws_lb_listener" "selected" {
  count = var.create_load_balancing ? 1 : 0
  load_balancer_arn = data.aws_lb.selected[0].arn
  port              = var.listener_port
}

resource "aws_lb_target_group" "lb_http_target_group" {
  count = var.create_load_balancing && !var.create_blue_green_deploy_tgs ? 1 : 0
  name = "tg-${local.service_name}"
  port     = var.tg_port
  protocol = var.tg_protocol
  vpc_id   = var.vpc_id
  target_type = var.launch_type == "EC2" ? "instance" : "ip"
  health_check {
    path = var.tg_health_check_path
    matcher = var.tg_health_check_matcher
    interval = var.tg_health_check_interval
    timeout = var.tg_health_check_timeout
    healthy_threshold = var.tg_health_check_healthy_threshold 
    unhealthy_threshold = var.tg_health_check_unhealthy_threshold 
  }
}

resource "aws_lb_listener_rule" "endpoint_listener_rule" {
  count = var.create_load_balancing && !var.create_blue_green_deploy_tgs ? 1 : 0
  depends_on = [
    aws_lb_target_group.lb_http_target_group[0]
  ]
  listener_arn = data.aws_lb_listener.selected[0].arn
  priority     = var.listener_priority

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lb_http_target_group[0].arn
  }

  condition {
    path_pattern {
      values = var.path_patterns
    }
  }
}

resource "aws_lb_target_group" "lb_http_target_group_blue" {
  count = var.create_load_balancing && var.create_blue_green_deploy_tgs ? 1 : 0
  name = "tg-${local.service_name}-blue"
  port     = var.tg_port
  protocol = var.tg_protocol
  vpc_id   = var.vpc_id
  target_type = var.launch_type == "EC2" ? "instance" : "ip"
  health_check {
    path = var.tg_health_check_path
    matcher = var.tg_health_check_matcher
    interval = var.tg_health_check_interval
    timeout = var.tg_health_check_timeout
    healthy_threshold = var.tg_health_check_healthy_threshold 
    unhealthy_threshold = var.tg_health_check_unhealthy_threshold 
  }
}

resource "aws_lb_target_group" "lb_http_target_group_green" {
  count = var.create_load_balancing && var.create_blue_green_deploy_tgs ? 1 : 0
  name = "tg-${local.service_name}-green"
  port     = var.tg_port
  protocol = var.tg_protocol
  vpc_id   = var.vpc_id
  target_type = var.launch_type == "EC2" ? "instance" : "ip"
  health_check {
    path = var.tg_health_check_path
    matcher = var.tg_health_check_matcher
    interval = var.tg_health_check_interval
    timeout = var.tg_health_check_timeout
    healthy_threshold = var.tg_health_check_healthy_threshold 
    unhealthy_threshold = var.tg_health_check_unhealthy_threshold 
  }
}

resource "aws_lb_listener_rule" "endpoint_listener_rule_bg" {
  count = var.create_load_balancing && var.create_blue_green_deploy_tgs ? 1 : 0
  lifecycle { 
    ignore_changes =  [action[0].target_group_arn] 
  }
  depends_on = [
    aws_lb_target_group.lb_http_target_group[0]
  ]
  listener_arn = data.aws_lb_listener.selected[0].arn
  priority     = var.listener_priority

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lb_http_target_group_blue[0].arn
  }

  condition {
    path_pattern {
      values = var.path_patterns
    }
  }
}

#------------------------------------------------------------------------------
# CLOUDWATCH
#------------------------------------------------------------------------------

resource "aws_kms_key" "log_group_key" {
  count = var.use_custom_kms ? 1 : 0
  deletion_window_in_days = 30
  enable_key_rotation = true

  policy = jsonencode({
    "Version": "2012-10-17",
    "Id": "kms-1",
    "Statement": [
        {
            "Sid": "Enable IAM User Permissions",
            "Effect": "Allow",
            "Principal": {
                "AWS": [
                  "arn:aws:iam::${local.account_id}:root"
                ]
            },
            "Action": "kms:*",
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "logs.${var.aws_region}.amazonaws.com"
            },
            "Action": [
                "kms:Encrypt*",
                "kms:Decrypt*",
                "kms:ReEncrypt*",
                "kms:GenerateDataKey*",
                "kms:Describe*"
            ],
            "Resource": "*",
            "Condition": {
                "ArnEquals": {
                    "kms:EncryptionContext:aws:logs:arn": "arn:aws:logs:${var.aws_region}:${local.account_id}:log-group:${local.log_group_name}"
                }
            }
        }    
    ]
  })
}

resource "aws_cloudwatch_log_group" "log_group" {
  name = local.log_group_name
  tags = var.tags

  kms_key_id =  var.use_custom_kms ? aws_kms_key.log_group_key[0].arn : null
  retention_in_days = var.log_retention_days
}

#------------------------------------------------------------------------------
# AWS ECS SERVICE
#------------------------------------------------------------------------------

data "aws_ecs_cluster" "cluster" {
  cluster_name = var.ecs_cluster_name
}

resource "aws_ecs_service" "service" {
  name                               = local.service_name
  # capacity_provider_strategy - (Optional) The capacity provider strategy to use for the service. Can be one or more. Defined below.
  cluster                            = data.aws_ecs_cluster.cluster.arn
  iam_role                           = var.create_load_balancing && var.launch_type == "EC2" ? data.aws_iam_role.ecs_service_role.arn : null
  deployment_maximum_percent         = var.deployment_maximum_percent
  deployment_minimum_healthy_percent = var.deployment_minimum_healthy_percent
  desired_count                      = var.desired_count
  enable_ecs_managed_tags            = var.enable_ecs_managed_tags
  health_check_grace_period_seconds  = var.create_load_balancing ? var.health_check_grace_period_seconds : null
  launch_type                        = var.launch_type
  enable_execute_command             = var.enable_execute_command

  lifecycle { 
    ignore_changes = [task_definition, load_balancer]
  }
  
  dynamic "load_balancer" {
    for_each = var.create_load_balancing && !var.create_blue_green_deploy_tgs ? [1] : []
    content {
      target_group_arn = aws_lb_target_group.lb_http_target_group[0].arn
      container_name   = var.container_name
      container_port   = var.container_port
    }
  }

  dynamic "load_balancer" {
    for_each = var.create_load_balancing && var.create_blue_green_deploy_tgs ? [1] : []
    content {
      target_group_arn = aws_lb_target_group.lb_http_target_group_blue[0].arn
      container_name   = var.container_name
      container_port   = var.container_port
    }
  }

  dynamic "deployment_controller" {
     for_each = var.create_blue_green_deploy_tgs ? [1] : []
    content {
      type = "CODE_DEPLOY"
    }
  }

  dynamic "ordered_placement_strategy" {
    for_each = var.ordered_placement_strategy
    content {
      type  = ordered_placement_strategy.value.type
      field = lookup(ordered_placement_strategy.value, "field", null)
    }
  }
  dynamic "placement_constraints" {
    for_each = var.placement_constraints
    content {
      expression = lookup(placement_constraints.value, "expression", null)
      type       = placement_constraints.value.type
    }
  }
  propagate_tags   = var.propagate_tags
  dynamic "service_registries" {
    for_each = var.service_registries
    content {
      registry_arn   = service_registries.value.registry_arn
      port           = lookup(service_registries.value, "port", null)
      container_name = lookup(service_registries.value, "container_name", null)
      container_port = lookup(service_registries.value, "container_port", null)
    }
  }
  dynamic "network_configuration" {
    // network_configuration is only needed for Fargate launch type
    for_each = var.launch_type != "EC2" && var.network_configuration != null ? [1] : []
    content {
      subnets = var.network_configuration.subnets
      security_groups = var.network_configuration.security_groups
      assign_public_ip = var.network_configuration.assign_public_ip
    }
  }
  task_definition = var.create_task_definition ? aws_ecs_task_definition.task_def[0].arn : var.task_definition_arn
  tags = merge({
    Name = "${local.service_name}-ecs-tasks-sg"
  }, var.tags)
}