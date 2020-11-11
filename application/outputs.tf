output "ecr_url" {
  value = aws_ecr_repository.ecr.repository_url
}

output "lb" {
  value = aws_alb.main.dns_name
}

output "service_name_2048" {
  value = aws_ecs_service.main.name
}