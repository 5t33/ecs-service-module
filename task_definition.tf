
data "aws_ecs_task_definition" "task_def" {
  count = var.task_definition == null ? 1 : 0
  task_definition = var.task_definition_arn
}

resource "aws_ecs_task_definition" "task_def" {
  count = var.task_definition == null ? 0 : 1
  execution_role_arn = var.task_definition.executionRoleArn
  task_role_arn = var.task_definition.taskRoleArn == null ? var.task_definition.executionRoleArn : var.task_definition.taskRoleArn
  family = var.task_definition.family
  network_mode = var.launch_type == "EC2" ? "bridge" : "awsvpc"
  requires_compatibilities = var.launch_type == "EC2" ? [] : ["FARGATE"]
  // Fargate requires that 'cpu' be defined at the task level.
  cpu = var.launch_type == "EC2" ? null: var.task_definition.cpu
  memory = var.launch_type == "EC2" ? null: var.task_definition.memory
  dynamic "runtime_platform" {
    for_each = var.task_definition.runtimePlatform != null ? [var.task_definition.ephemeralStorage] : []
    content {
      operating_system_family = var.task_definition.runtimePlatform.operatingSystemFamily
      cpu_architecture = var.task_definition.runtimePlatform.cpuArchitecture
    }
  }
  dynamic "ephemeral_storage" {
    for_each = var.task_definition.ephemeralStorage != null ? [var.task_definition.ephemeralStorage] : []
    content {
      size_in_gib = var.task_definition.ephemeralStorage.sizeInGiB
    }
  }
  dynamic "volume" {
    for_each = var.task_definition.volumes
    content {
      name = volume.value.name
      dynamic "efs_volume_configuration" {
        for_each = volume.value.efs_volume_configuration == null ? [] : [volume.value.efs_volume_configuration]
        content {
          file_system_id = efs_volume_configuration.value.fileSystemId
          root_directory = efs_volume_configuration.value.rootDirectory
          transit_encryption = efs_volume_configuration.value.transitEncryption
          transit_encryption_port = efs_volume_configuration.value.transitEncryptionPort
          dynamic "authorization_config" {
            for_each = efs_volume_configuration.value.authorizationConfig == null ? [] : [efs_volume_configuration.value.authorization_config]
            content {
              access_point_id = authorization_config.value.accessPointId
              iam = authorization_config.value.iam
            }
          } 
        }
      }
      host_path = volume.value.hostPath
    }
  }
  container_definitions = jsonencode([
    for container_definition in var.task_definition.containerDefinitions: {
        "name" = container_definition.name == null ? var.container_name : container_definition.name,
        "image" = container_definition.image,
        "command" = container_definition.command,
        "essential" = container_definition.essential
        # "command": ["bash", "-c", "while true;do echo \"sleeping\"; sleep 10; done;"],
        "cpu" = var.launch_type == "EC2" ? container_definition.cpu : null,
        "memory" = var.launch_type == "EC2" ? container_definition.memory: null,
        "logConfiguration" = {
          "logDriver" = "awslogs",
          "options" = {
            "awslogs-group" = var.log_group == null ? "ecs/${local.service_name}" : var.log_group, 
            "awslogs-region" = var.aws_region,
            "awslogs-stream-prefix" = var.aws_logs_stream_prefix,
          }
        },
        "environment" = container_definition.environment,
        "secrets" = container_definition.secrets,
        "portMappings" = var.load_balancing != null ? [
          for port_mapping in container_definition.portMappings: {
            "containerPort" = port_mapping.containerPort,
            "hostPort" = var.launch_type == "EC2" ? port_mapping.hostPort : port_mapping.containerPort,
            "protocol":  port_mapping.protocol,
          }
        ] : null,
        "mountPoints" = container_definition.mountPoints,
        "volumesFrom" = container_definition.volumesFrom
    }
  ])
  tags = var.tags
}