# Module for creating an ECS service

Inspired by:
* https://github.com/cn-terraform/terraform-aws-ecs-fargate-service

## Important Note

This Terraform chart is opinionated in that it assumed you will be deploying your ECS service with some other method e.g. AWS CodeDeploy or https://github.com/silinternational/ecs-deploy. So, the task definition is ignored (in the service) after the initial deployment. If you change the task definiton, it will create a new definition in the state, but it will not be updated in the service (which would create a rolling deployment).

Additionally, the module accepts a camel-cased task definition, instead of the typical Terraform underscore. This is so a JSON task definition can be used like so:
```
module "service" {
    ...
    task_definition = jsondecode(templatefile("${path.module}/task-definition.json", {
      ENV = var.environment,
      ACCOUNT_ID = local.account_id,
      FRONTEND_DOMAIN = local.frontend_domain,
      BACKEND_DOMAIN = local.backend_domain,
      IMAGE = "<account id>.dkr.ecr.us-west-2.amazonaws.com/<image name>:latest"
    }))
    ...
}
```
This allows you to use the same task definition file in a deploy script, which might look like this:
```
deploy_with_codedeploy() {
  ENV=$1
  DEPLOY_COMMIT=$2
  if [ ! -z "$DEPLOY_COMMIT" ];
  then
    MAIN_CONTAINS_COMMIT=$(git branch --contains $DEPLOY_COMMIT | grep main | wc -l)
    if [ "$ENV" == "prd" ] && [ $MAIN_CONTAINS_COMMIT != 1 ]; then print_error_and_exit "Commit $DEPLOY_COMMIT not contained in main. Only main can be deployed to production."; fi 
  fi

  ACCOUNT_ID=$(aws sts get-caller-identity | jq ".Account" | sed s/\"//g)
  if [ ! -z $DEPLOY_COMMIT ]; then IMAGE="<IMG ACCOUNT ID>.dkr.ecr.us-west-2.amazonaws.com\/<YOUR IMAGE>:$DEPLOY_COMMIT"; else IMAGE="<IMG ACCOUNT ID>.dkr.ecr.us-west-2.amazonaws.com\/<YOUR IMAGE>:latest"; fi

  NEW_TASK_DEFINITION=$(\
    cat infrastructure/task-definition.json \
    | sed s/\${ENV}/$ENV/g \
    | sed s/\${ACCOUNT_ID}/$ACCOUNT_ID/g \
    | sed s/\${IMAGE}/$IMAGE/g \
  )
  if [ "$?" != "0" ]; then print_error_and_exit "Failed to generate task definition JSON"; fi
  NEW_TASK_DEFINITION_ARN=$(aws ecs register-task-definition --region us-west-2  --cli-input-json "$NEW_TASK_DEFINITION" | jq ".taskDefinition.taskDefinitionArn" | sed s/\"//g)
  if [ "$?" != "0" ]; then print_error_and_exit "Failed to create new task definition"; fi
  APPSPEC=$(echo "{\"version\":1,\"Resources\":[{\"TargetService\":{\"Type\":\"AWS::ECS::Service\",\"Properties\":{\"TaskDefinition\":\"${NEW_TASK_DEFINITION_ARN}\",\"LoadBalancerInfo\":{\"ContainerName\":\"<YOUR APPLICATION>-${ENV}\",\"ContainerPort\":3500}}}}]}" | jq -Rs .)
  REVISION='{"revisionType":"AppSpecContent","appSpecContent":{"content":'${APPSPEC}'}}'
  aws deploy --region us-west-2 create-deployment --application-name "<YOUR APPLICATION>-$ENV" --deployment-group-name "<YOUR APPLICATION>-$ENV" --revision "$REVISION"
}
```
example task definition json:
```
{
  "containerDefinitions": [
    {
      "name": "<APP NAME>-${ENV}",
      "image": "${IMAGE}",
      "portMappings": [
        {
          "containerPort": 3500,
          "hostPort": 3500,
          "protocol": "tcp"
        }
      ],
      "essential": true,
      "environment": [
        {
          "name": "NODE_ENV",
          "value": "${ENV}"
        },
        {
          "name": "APP_NAME",
          "value": "<APP NAME>"
        }
      ],
      "mountPoints": [],
      "volumesFrom": [],
      "secrets": [
        {
          "name": "DATABASE_PASSWORD",
          "valueFrom": "/museflow/${ENV}/aurora-rds/<APP NAME>-${ENV}/app_password"
        },
        {
          "name": "DATABASE_USERNAME",
          "valueFrom": "/museflow/${ENV}/aurora-rds/<APP NAME>-${ENV}/app_username"
        },
        {
          "name": "DATABASE_HOST",
          "valueFrom": "/museflow/${ENV}/aurora-rds/<APP NAME>-${ENV}/rw-endpoint"
        }
      ],
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "ecs/<APP NAME>-usw2-${ENV}",
          "awslogs-region": "us-west-2",
          "awslogs-stream-prefix": "ecs"
        }
      },
      "dependsOn": [{
				"containerName": "aws-otel-collector",
				"condition": "START"
			}]
    },
    {
      "name": "aws-otel-collector",
      "image": "public.ecr.aws/aws-observability/aws-otel-collector:latest",
      "essential": true,
      "portMappings": [
        {
          "containerPort": 2000,
          "hostPort": 2000,
          "protocol": "udp"
        },
        {
          "containerPort": 4317,
          "hostPort": 4317,
          "protocol": "tcp"
        },
        {
          "containerPort": 4318,
          "hostPort": 4318,
          "protocol": "tcp"
        }
      ],
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-create-group": "True",
          "awslogs-group": "/ecs/ecs-aws-otel-sidecar-collector",
          "awslogs-region": "us-west-2",
          "awslogs-stream-prefix": "ecs"
        }
      },
      "secrets": [
        {
          "name": "AOT_CONFIG_CONTENT",
          "valueFrom": "/<org name>/${ENV}/otel/config"
        }
      ]
    }
  ],
  "family": "museflow",
  "taskRoleArn": "arn:aws:iam::${ACCOUNT_ID}:role/...",
  "executionRoleArn": "arn:aws:iam::${ACCOUNT_ID}:role/...",
  "networkMode": "awsvpc",
  "volumes": [],
  "placementConstraints": [],
  "requiresCompatibilities": [
    "FARGATE"
  ],
  "cpu": "512",
  "memory": "1024"
}
```

Using this strategy, you don't need to define your task definition twice - once in Terraform and once in a deploy script. It's also better than https://github.com/silinternational/ecs-deploy because it allows you to change the environment variables on deployment - instead of only preserving the ones that already exist in the current task definition.

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
    source      = "git@github.com:5t33/ecs-service-module?ref=v1.0.0"
    environment = "tst"
    launch_type = "EC2"
    aws_region  = var.aws_region
    task_execution_role_arn = aws_iam_role.task_role.arn
    name_preffix = "hello-world"
    ecs_cluster_name = "cluster"
    vpc_id = "vpc-123456"
    ecs_cluster_name = var.account
    vpc_id = local.vpc_id
    load_balancing = {
      load_balancer_name = "myorg-main-alb-${var.environment}"
      path_patterns = [ "/*" ]
      listener_port = 443
      target_group = {
        port = 3500
        protocol = "HTTP"
        health_check_path = "/docs"
        health_check_timeout = 2
        health_check_interval = 10
        health_check_unhealthy_threshold = 3
        health_check_healthy_threshold = 2
      }
    }
    container_name = "myorg-${var.environment}"
    container_port = 3500
    task_definition = {
      family = "myorg"
      executionRoleArn = aws_iam_role.task_role.arn
      cpu = 128
      memory = 128
      containerDefinitions = [
        {
          image = local.container_image
          environment = [
            {
              name = "BACKEND_DOMAIN",
              value = local.backend_domain
            },
            {
              name = "NODE_ENV",
              value = var.environment
            },
          ]
          secrets = [
            {
              name = "DATABASE_PASSWORD",
              valueFrom = "/myorg/${var.environment}/aurora-rds/myorg-${var.environment}/app_password"        
            },
            {
              name = "DATABASE_USERNAME",
              valueFrom = "/myorg/${var.environment}/aurora-rds/myorg-${var.environment}/app_username"        
            },
            {
              name = "DATABASE_HOST",
              valueFrom = "/myorg/${var.environment}/aurora-rds/myorg-${var.environment}/rw-endpoint"        
            },
          ],
          portMappings = [
            {
              containerPort = 3500
              hostPort = 3500 // to assign a dynamic port, leave this blank
            }
          ]
        },
      ]
    }

    health_check_grace_period_seconds = 30
    log_retention_days = 30
    desired_count = 1
    tags = {
      Environment = var.environment
    }
    network_configuration = {
      subnets = local.public_subnet_ids // Note - to make this private and not assign public IP you will need ECR VPC endpoints and the ECR repo will need to be in the same region
      security_groups = [aws_security_group.app.id]
      assign_public_ip = true
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
    source      = "git@github.com:5t33/ecs-service-module?ref=v1.0.0"
    environment = var.environment
    enable_execute_command = true
    launch_type = "FARGATE"
    aws_region  = var.region
    name_preffix = "myorg"
    ecs_cluster_name = var.account
    vpc_id = local.vpc_id
    load_balancing = {
      load_balancer_name = "myorg-main-alb-${var.environment}"
      path_patterns = [ "/*" ]
      listener_port = 443
      target_group = {
        port = 3500
        protocol = "HTTP"
        health_check_path = "/docs"
        health_check_timeout = 2
        health_check_interval = 10
        health_check_unhealthy_threshold = 3
        health_check_healthy_threshold = 2
      }
    }
    container_name = "myorg-${var.environment}"
    container_port = 3500
    task_definition = {
      family = "myorg"
      executionRoleArn = aws_iam_role.task_role.arn
      cpu = 512
      memory = 1024
      containerDefinitions = [
        {
          image = local.container_image
          environment = [
            {
              name = "BACKEND_DOMAIN",
              value = local.backend_domain
            },
            {
              name = "NODE_ENV",
              value = var.environment
            },
          ]
          secrets = [
            {
              name = "DATABASE_PASSWORD",
              valueFrom = "/myorg/${var.environment}/aurora-rds/myorg-${var.environment}/app_password"        
            },
            {
              name = "DATABASE_USERNAME",
              valueFrom = "/myorg/${var.environment}/aurora-rds/myorg-${var.environment}/app_username"        
            },
            {
              name = "DATABASE_HOST",
              valueFrom = "/myorg/${var.environment}/aurora-rds/myorg-${var.environment}/rw-endpoint"        
            },
          ],
          portMappings = [
            {
              containerPort = 3500
            }
          ]
        },
      ]
    }

    health_check_grace_period_seconds = 30
    log_retention_days = 30
    desired_count = 1
    tags = {
      Environment = var.environment
    }
    network_configuration = {
      subnets = local.public_subnet_ids // Note - to make this private and not assign public IP you will need ECR VPC endpoints and the ECR repo will need to be in the same region
      security_groups = [aws_security_group.app.id]
      assign_public_ip = true
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
                "ec2:Vpc": "vpc-123456",
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

## Blue/Green deployment with Codedeploy

In order to specify B/G deployment with codedeploy, include the following option:
```
module "hello-world" {
  ...
  create_blue_green_deploy_tgs = true
  ...
}
```
This will ensure your service is created with two target groups that can be used as blue/green groups in codedeploy.


## Autoscaling

```
module "hello-world" {
  ...
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
        scale_down_step = -1
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
        evaluation_periods = 1
        namespace = "AWS/ECS"
        tags = {
          environment = var.environment
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
        evaluation_periods = 3
        datapoints_to_alarm = 3
        namespace = "AWS/ECS"
        tags = {
          environment = var.environment
        }
        metric_queries = []
      }
    ]
}
```
