
data "aws_ecs_task_definition" "task_def" {
  count = var.create_task_definition ? 0 : 1
  task_definition = var.task_definition_family
}

resource "aws_ecs_task_definition" "task_def" {
  count = var.create_task_definition ? 1 : 0
  execution_role_arn = var.task_execution_role_arn
  task_role_arn = var.task_role_arn == null ? var.task_execution_role_arn : var.task_role_arn
  family = var.task_definition_family
  network_mode = var.launch_type == "EC2" ? "bridge" : "awsvpc"
  requires_compatibilities = var.launch_type == "EC2" ? [] : ["FARGATE"]
  // Fargate requires that 'cpu' be defined at the task level.
  cpu = var.launch_type == "EC2" ? null: var.task_cpu
  memory = var.launch_type == "EC2" ? null: var.task_memory
  container_definitions = jsonencode(
    [{
      "name" = var.container_name,
      "image" = var.container_image,
      "cpu" = var.launch_type == "EC2" ? var.task_cpu : null,
      "memory" = var.launch_type == "EC2" ? var.task_memory: null,
      "logConfiguration" = {
        "logDriver" = "awslogs",
        "options" = {
          "awslogs-group" = var.log_group == null ? "ecs/${local.service_name}" : var.log_group, 
          "awslogs-region" = var.aws_region,
          "awslogs-stream-prefix" = var.aws_logs_stream_prefix,
        }
      },
      "environment" = var.environment_variables,
      "secrets" = var.secrets,
      "portMappings" = var.create_load_balancing ? [{
        "containerPort" = var.container_port,
        // When networkMode=awsvpc, the host ports and container ports in port mappings must match
        "hostPort" = var.launch_type == "EC2" ? var.host_port : var.container_port,
        "protocol": "tcp"
      }] : null
    }]
  )
  tags = var.tags
}