output "service" {
  value = module.main.service
}
output "cluster" {
  value = module.main.cluster
}
output "namespace" {
  value = var.namespace
}
output "repo_uri" {
  value = module.main.ecr_uri
}
