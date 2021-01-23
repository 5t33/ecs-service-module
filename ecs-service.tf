
locals {
  service_name = var.name_override != "" ? var.name_override : "${var.name_preffix}-${var.aws_short_region[var.aws_region]}-${var.environment}"
}

#------------------------------------------------------------------------------
# IAM
#------------------------------------------------------------------------------

data "aws_iam_role" "ecs_service_role" {
  name = var.ecs_service_role_name
}

#------------------------------------------------------------------------------
# AWS LOAD BALANCER
#------------------------------------------------------------------------------

resource "aws_lb_target_group" "lb_http_target_group" {
  name = "tg-${local.service_name}"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
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
  depends_on = [
    aws_lb_target_group.lb_http_target_group
  ]
  listener_arn = var.listener_arn
  priority     = var.listener_priority

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lb_http_target_group.arn
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

resource "aws_cloudwatch_log_group" "log_group" {
  name = var.log_group == null ? "ecs/${local.service_name}" : var.log_group 
  retention_in_days = var.log_retention_days
  tags = var.tags
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
  iam_role                           = data.aws_iam_role.ecs_service_role.arn
  deployment_maximum_percent         = var.deployment_maximum_percent
  deployment_minimum_healthy_percent = var.deployment_minimum_healthy_percent
  desired_count                      = var.desired_count
  enable_ecs_managed_tags            = var.enable_ecs_managed_tags
  health_check_grace_period_seconds  = var.health_check_grace_period_seconds
  launch_type                        = "EC2"
  // Deploy first time then ignore to be managed by deployment pipeline.
  lifecycle {
    ignore_changes = [task_definition]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.lb_http_target_group.arn
    container_name   = var.container_name
    container_port   = var.container_port
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
  task_definition = aws_ecs_task_definition.task_def.arn
  tags = merge({
    Name = "${local.service_name}-ecs-tasks-sg"
  }, var.tags)
}
