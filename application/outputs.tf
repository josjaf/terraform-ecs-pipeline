

output "lb" {
  value = aws_alb.main.dns_name
}

output "service_name_2048" {
  value = aws_ecs_service.main.name
}