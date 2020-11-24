data "aws_vpc" "VPC" {
  filter {
    name = "vpc-id"
    values = [
      var.vpc_id]
  }
}
data "aws_subnet_ids" "public_subnets" {
  vpc_id = var.vpc_id
  filter {
    name = "tag:Network"
    values = [
      "Public"]
  }
}
data "aws_subnet_ids" "private_subnets" {
  vpc_id = var.vpc_id
  filter {
    name = "tag:Network"
    values = [
      "Private"]
  }
}
data "aws_ssm_parameter" "ecr" {
  name = "/${var.namespace}/ecr/uri"
}
data "aws_ssm_parameter" "ecrarn" {
  name = "/${var.namespace}/ecr/arn"
}
### Security

# ALB Security group
# This is the group you need to edit if you want to restrict access to your application
resource "aws_security_group" "lb" {
  name        = "tf-ecs-alb"
  description = "controls access to the ALB"
  vpc_id      = data.aws_vpc.VPC.id

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Traffic to the ECS Cluster should only come from the ALB
resource "aws_security_group" "ecs_tasks" {
  name        = "tf-ecs-tasks"
  description = "allow inbound access from the ALB only"
  vpc_id      = data.aws_vpc.VPC.id

  ingress {
    protocol        = "tcp"
    from_port       = "${var.app_port}"
    to_port         = "${var.app_port}"
    security_groups = ["${aws_security_group.lb.id}"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

### ALB

resource "aws_alb" "main" {
  name            = "tf-ecs-chat"
  subnets         = data.aws_subnet_ids.public_subnets.ids
  security_groups = ["${aws_security_group.lb.id}"]
}

resource "aws_alb_target_group" "app" {
  name        = "tf-ecs-chat"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = data.aws_vpc.VPC.id
  target_type = "ip"
}

# Redirect all traffic from the ALB to the target group
resource "aws_alb_listener" "front_end" {
  load_balancer_arn = "${aws_alb.main.id}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_alb_target_group.app.id}"
    type             = "forward"
  }
}

### ECS

resource "aws_ecs_cluster" "main" {
  name = var.ecs_cluster_name
}

# name here has to match what codepipeline and codebuild is publishing in the imagedefinitions.json
# you cannot update name
resource "aws_ecs_task_definition" "app" {
  family                   = "2048"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "${var.fargate_cpu}"
  memory                   = "${var.fargate_memory}"
  execution_role_arn = aws_iam_role.ecs-execution-role.arn # this is the role for ecs to pull images
//  task_role_arn = aws_iam_role.ecs-task-role.arn

  container_definitions = <<DEFINITION
[
  {
    "cpu": ${var.fargate_cpu},
    "image": "${data.aws_ssm_parameter.ecr.value}:2048",
    "memory": ${var.fargate_memory},
    "name": "${var.ecs_service_name}",
    "networkMode": "awsvpc",
    "portMappings": [
      {
        "containerPort": ${var.app_port},
        "hostPort": ${var.app_port}
      }
    ]
  }
]
DEFINITION
}

resource "aws_ecs_service" "main" {
  name            = var.ecs_service_name
  cluster         = "${aws_ecs_cluster.main.id}"
  task_definition = "${aws_ecs_task_definition.app.arn}"
  desired_count   = "${var.app_count}"
  launch_type     = "FARGATE"

  network_configuration {
    security_groups = ["${aws_security_group.ecs_tasks.id}"]
    subnets         = data.aws_subnet_ids.private_subnets.ids
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = "${aws_alb_target_group.app.id}"
    container_name   = "${var.ecs_service_name}"
    container_port   = "${var.app_port}"
  }

  depends_on = [
    "aws_alb_listener.front_end",
  ]
}
resource "aws_ssm_parameter" "serviceparameter" {
  name = "/${var.namespace}/ecs/service"
  type = "String"
  value = aws_ecs_service.main.name
  tags = {
    Name = var.namespace
    environment = var.namespace
  }
}
resource "aws_ssm_parameter" "clusterparameter" {
  name = "/${var.namespace}/ecs/cluster"
  type = "String"
  value = aws_ecs_cluster.main.id
  tags = {
    Name = var.namespace
    environment = var.namespace
  }
}
