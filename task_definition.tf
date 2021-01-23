resource "aws_ecs_task_definition" "task_def" {
  execution_role_arn = var.task_execution_role_arn
  family = var.task_definition_family
  network_mode = "bridge"
  tags = var.tags
  container_definitions = jsonencode(
    list({
      "name" = var.container_name,
      "image" = var.container_image,
      "cpu" = var.task_cpu,
      "memory" = var.task_memory,
      "logConfiguration" = {
        "logDriver" = "awslogs",
        "options" = {
          "awslogs-group" = var.log_group == null ? "ecs/${local.service_name}" : var.log_group, 
          "awslogs-region" = var.aws_region,
          "awslogs-stream-prefix" = var.aws_logs_stream_prefix,
        }
      },
      "portMappings" = list({
        "containerPort" = var.container_port,
        "hostPort" = 0,
        "protocol": "tcp"
      })
    })
  )
}