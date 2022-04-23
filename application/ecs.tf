### ALB

resource "aws_alb" "main" {
  name = "tf-ecs-chat"
  subnets = data.aws_subnets.public_subnets.ids
  security_groups = [
    "${aws_security_group.lb.id}"]
  tags = merge(
  local.common_tags,
  tomap({
    "Name" = "${var.namespace}"
  })
  )
}

resource "aws_alb_target_group" "app" {
  name = "tf-ecs-chat"
  port = 80
  protocol = "HTTP"
  vpc_id = data.aws_vpc.VPC.id
  target_type = "ip"
}

# Redirect all traffic from the ALB to the target group
resource "aws_alb_listener" "front_end" {
  load_balancer_arn = aws_alb.main.id
  port = "80"
  protocol = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.app.id
    type = "forward"
  }
}

### ECS

resource "aws_ecs_cluster" "main" {
  name = var.namespace
  tags = merge(
  local.common_tags,
  tomap({
    "Name" = "${var.namespace}"
  })
  )
}

# name here has to match what codepipeline and codebuild is publishing in the imagedefinitions.json
# you cannot update name

resource "aws_cloudwatch_log_group" "log_grouo" {
  name_prefix = var.namespace
  retention_in_days = 14
  tags = merge(
  local.common_tags,
  tomap({
    "Name" = "${var.namespace}"
  })
  )
}
resource "aws_ecs_task_definition" "app" {
  family = "2048"
  network_mode = "awsvpc"
  requires_compatibilities = [
    "FARGATE"]
  cpu = var.fargate_cpu
  memory = var.fargate_memory
  # this is the role for ecs to pull images

  execution_role_arn = aws_iam_role.ecs-execution-role.arn
  //  task_role_arn = aws_iam_role.ecs-task-role.arn
  tags = merge(
  local.common_tags,
  tomap({
    "Name" = "${var.namespace}",
    "tf" = "true"
  })
  )
  container_definitions = <<DEFINITION
[
  {
    "cpu": ${var.fargate_cpu},
    "image": "${aws_ecr_repository.ecr.repository_url}:2048",
    "memory": ${var.fargate_memory},
    "name": "${var.ecs_service_name}",
    "networkMode": "awsvpc",
    "portMappings": [
      {
        "containerPort": ${var.app_port},
        "hostPort": ${var.app_port}
      }
    ],
    "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
            "awslogs-group": "${aws_cloudwatch_log_group.log_grouo.name}",
            "awslogs-region": "${var.region}",
            "awslogs-stream-prefix": "2048"
        }
    }
  }
]
DEFINITION
}


resource "aws_ecs_service" "main" {
  name = var.ecs_service_name
  cluster = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.app.arn
  desired_count = 0
  launch_type = "FARGATE"

  network_configuration {
    security_groups = [
      "${aws_security_group.ecs_tasks.id}"]
    subnets = data.aws_subnets.private_subnets.ids
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.app.id
    container_name = var.ecs_service_name
    container_port = var.app_port
  }

  depends_on = [
    aws_alb_listener.front_end,
  ]
  tags = merge(
  local.common_tags,
  tomap({
    "Name" = "${var.namespace}"
  })
  )
}

