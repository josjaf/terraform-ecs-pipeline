#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_capacity_provider
resource "aws_iam_role" "ecsExecutionRole" {
  name = "${var.namespace}-asg-ecs-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": ["ec2.amazonaws.com"]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

  tags = local.common_tags
}
resource "aws_iam_role" "ecsTaskRole" {
  name = "${var.namespace}-ecs-task"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": ["ecs-tasks.amazonaws.com"]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

  tags = local.common_tags
}


resource "aws_iam_role_policy_attachment" "AmazonecsExecutionRolePolicy" {
  role       = aws_iam_role.ecsExecutionRole.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}
resource "aws_iam_role_policy_attachment" "AmazonecsTaskRolePolicy" {
  role       = aws_iam_role.ecsTaskRole.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}
resource "aws_iam_instance_profile" "ecs_instance_profile" {
  name = "${var.namespace}-ecs"
  path = "/"
  role = aws_iam_role.ecsExecutionRole.name
}



resource "aws_iam_role_policy" "ecs-exec" {
  name = "ecs-exec"
  role = aws_iam_role.ecsExecutionRole.id
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "ssmmessages:CreateControlChannel",
                "ssmmessages:CreateDataChannel",
                "ssmmessages:OpenControlChannel",
                "ssmmessages:OpenDataChannel"
            ],
            "Effect": "Allow",
            "Resource": "*"
        }
    ]
}
EOF
}

data "aws_ami" "ecs_ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn-ami-*-amazon-ecs-optimized"]
  }
}

resource "aws_autoscaling_group" "main" {
  name = "${var.namespace}-main"
#  protect_from_scale_in = true
  launch_template {
    id = aws_launch_template.launch_template.id
    version = "$Latest"
  }
  termination_policies = [
    "OldestLaunchConfiguration",
    "Default"]
  vpc_zone_identifier = data.aws_subnets.private_subnets.ids

  desired_capacity = var.ec2_app_count
  max_size = var.ec2_app_count * length(data.aws_subnets.private_subnets)
  min_size = 0

  lifecycle {
    create_before_destroy = true
  }

  tag {
    key                 = "AmazonECSManaged"
    value               = true
    propagate_at_launch = true
  }
  dynamic "tag" {
    for_each = merge(
    local.common_tags,
    tomap({
      "Name" = "${var.namespace}"
      "terraform" = "true"
    })
    )
    content {
      key = tag.key
      value = tag.value
      propagate_at_launch = true
    }
  }
}

resource "aws_launch_template" "launch_template" {
  name = "/${var.namespace}"
  description = var.namespace
  update_default_version = true
  image_id = data.aws_ami.ecs_ami.id
  instance_type = "t3.medium"
  #https://github.com/hashicorp/terraform-provider-aws/issues/4570
  //  network_interfaces {
  //      associate_public_ip_address = true
  //      security_groups = [aws_security_group.ec2.id]
  //  }
  //  block_device_mappings {
  //    device_name = "/dev/sda1"
  //
  //    ebs {
  //      encrypted = true
  //      delete_on_termination = true
  //    }
  //  }
  iam_instance_profile {
    name = aws_iam_instance_profile.ecs_instance_profile.id
  }

  vpc_security_group_ids = [
    aws_security_group.ecs_tasks.id
  ]

  //  user_data = base64encode(data.template_file.init.rendered)
  user_data = base64encode(<<EOF
#!/bin/bash
# The cluster this agent should check into.
echo 'ECS_CLUSTER=${aws_ecs_cluster.main.name}' >> /etc/ecs/ecs.config
# Disable privileged containers.
echo 'ECS_DISABLE_PRIVILEGED=true' >> /etc/ecs/ecs.config
  EOF
  )


  //  metadata_options {
  //    http_endpoint = "enabled"
  //    http_tokens = "required"
  //  }
  tags = merge(
  local.common_tags,
  tomap({
    "Name" = "${var.namespace}-ecs"
  })
  )
  tag_specifications {
    resource_type = "instance"
    tags = merge(
    local.common_tags,
    tomap({
      "Name" = "${var.namespace}"

    })
    )
  }
  tag_specifications {
    resource_type = "volume"
    tags = merge(
    local.common_tags,
    tomap({
      "Name" = "${var.namespace}"
    })
    )
  }

}


resource "aws_ecs_task_definition" "ec2" {
  family = "2048ec2"
  network_mode = "awsvpc"
  requires_compatibilities = [
    "EC2"]
  cpu = var.fargate_cpu
  memory = var.fargate_memory
  execution_role_arn = aws_iam_role.ecs-execution-role.arn
  # this is the role for ecs to pull images
  //  task_role_arn = aws_iam_role.ecs-task-role.arn
  tags = merge(
  local.common_tags,
  tomap({
    "Name" = "${var.namespace}"
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

resource "aws_ecs_service" "ec2service" {
  name = "EC2-Service"
  cluster = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.ec2.arn
  #desired_count = var.app_count
  desired_count = var.ec2_app_count
  launch_type = "EC2"

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


#resource "aws_ecs_capacity_provider" "test" {
#  name = "test"
#
#  auto_scaling_group_provider {
#    auto_scaling_group_arn         = aws_autoscaling_group.main.arn
#    managed_termination_protection = "ENABLED"
#
#    managed_scaling {
#      maximum_scaling_step_size = 1000
#      minimum_scaling_step_size = 1
#      status                    = "ENABLED"
#      target_capacity           = 10
#    }
#  }
#}