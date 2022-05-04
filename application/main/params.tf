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
resource "aws_ssm_parameter" "taskdefinition" {
  name = "/${var.namespace}/ecs/taskdefinition"
  type = "String"
  value = aws_ecs_task_definition.app.id
  tags = {
    Name = var.namespace
    environment = var.namespace
  }
}