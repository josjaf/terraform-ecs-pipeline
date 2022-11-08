resource "aws_ssm_parameter" "ecr" {
  for_each = {
    "ecs/service"        = aws_ecs_service.main.name
    "ecs/cluster"        = aws_ecs_cluster.main.id
    "ecs/taskdefinition" = aws_ecs_task_definition.app.id
  }
  name  = "/${var.namespace}/${each.key}"
  type  = "String"
  value = each.value
  tags  = {
    Name        = var.namespace
    environment = var.namespace
  }
}