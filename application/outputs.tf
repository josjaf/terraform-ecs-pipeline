output "ecr_url" {
  value = aws_ecr_repository.ecr.repository_url
}

output "lb" {
  value = aws_alb.main.dns_name
}