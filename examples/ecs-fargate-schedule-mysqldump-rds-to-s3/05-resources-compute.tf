#################
# ECS Resources #
#################

resource "aws_cloudwatch_log_group" "app_task_loggrp" {
  name = "/ecs/${var.sys_name}-app-task"
}

resource "aws_ecs_cluster" "app_cluster" {
  name = "${var.sys_name}-app-cluster" # Naming the cluster
}

data "aws_iam_policy_document" "ecs_task_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "app_ecsTaskExecutionRole" {
  name               = "${var.sys_name}-app-ecsTaskExecutionRole"
  assume_role_policy = "${data.aws_iam_policy_document.ecs_task_assume_role_policy.json}"
}

resource "aws_iam_role_policy_attachment" "app_ecsTaskExecutionRole_policy" {
  role       = "${aws_iam_role.app_ecsTaskExecutionRole.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

data "aws_ecr_image" "app_image" {
  depends_on      = [null_resource.docker_build_push_to_ecr_repo]
  repository_name = "${aws_ecr_repository.app_img_repo.name}"
  image_tag       = "${var.app_img_tag}"
}

resource "aws_ecs_task_definition" "app_taskdef" {
  depends_on = [null_resource.docker_build_push_to_ecr_repo]

  family                   = "${var.sys_name}-app-taskdef" # Naming our task
  container_definitions    = <<DEFINITION
  [
    {
      "name": "${var.sys_name}-app-task",
      "image": "${aws_ecr_repository.app_img_repo.repository_url}@${data.aws_ecr_image.app_image.image_digest}",
      "essential": true,
      "memory": 512,
      "cpu": 256,
      "logConfiguration": {
        "logDriver": "awslogs",
        "secretOptions": null,
        "options": {
          "awslogs-group": "${aws_cloudwatch_log_group.app_task_loggrp.name}",
          "awslogs-region": "${var.aws_region}",
          "awslogs-stream-prefix": "ecs"
        }
      }
    }
  ]
  DEFINITION
  requires_compatibilities = ["FARGATE"] # Stating that we are using ECS Fargate
  network_mode             = "awsvpc"    # Using awsvpc as our network mode as this is required for Fargate
  memory                   = 512         # Specifying the memory our container requires
  cpu                      = 256         # Specifying the CPU our container requires
  execution_role_arn       = "${aws_iam_role.app_ecsTaskExecutionRole.arn}"
}
