

output "lb" {
  value = aws_alb.main.dns_name
}

output "service" {
  value = aws_ecs_service.main.name
}

output "ecs_execution_role_arn" {
  value = aws_iam_role.ecs-execution-role.arn

}

output "ecs_task_role_arn" {
  value = aws_iam_role.ecs-task-role.arn

}

output "task_version_2048" {
  value = aws_ecs_task_definition.app.revision
}

output "cluster" {
  value = aws_ecs_cluster.main.name
}
