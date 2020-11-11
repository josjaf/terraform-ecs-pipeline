resource "aws_ecr_repository" "ecr" {
  name = var.namespace
  # image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}
resource "aws_ssm_parameter" "RepoURI" {
  name = "/${var.namespace}/ecr/uri"
  type = "String"
  value = aws_ecr_repository.ecr.repository_url
  tags = {
    Name = var.namespace
    environment = var.namespace
  }
}
resource "aws_ssm_parameter" "RepoArn" {
  name = "/${var.namespace}/ecr/arn"
  type = "String"
  value = aws_ecr_repository.ecr.arn
  tags = {
    Name = var.namespace
    environment = var.namespace
  }
}
