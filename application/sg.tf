### Security

# ALB Security group
# This is the group you need to edit if you want to restrict access to your application
resource "aws_security_group" "lb" {
  name = "${var.namespace}-alb"
  description = "controls access to the ALB"
  vpc_id = data.aws_vpc.VPC.id

  ingress {
    protocol = "tcp"
    from_port = 80
    to_port = 80
    cidr_blocks = [
      "0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [
      "0.0.0.0/0"]
  }
  tags = merge(
  local.common_tags,
  tomap({
    "Name" = "${var.namespace}-alb"
  })
  )
}

# Traffic to the ECS Cluster should only come from the ALB
resource "aws_security_group" "ecs_tasks" {
  name = "${var.namespace}-tasks"
  description = "allow inbound access from the ALB only"
  vpc_id = data.aws_vpc.VPC.id

  ingress {
    protocol = "tcp"
    from_port = var.app_port
    to_port = var.app_port
    security_groups = [
      "${aws_security_group.lb.id}"]
  }

  egress {
    protocol = "-1"
    from_port = 0
    to_port = 0
    cidr_blocks = [
      "0.0.0.0/0"]
  }
  tags = merge(
  local.common_tags,
  tomap({
    "Name" = "${var.namespace}-tasks"
  })
  )
}