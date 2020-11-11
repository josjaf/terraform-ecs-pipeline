variable "env" {}
variable "namespace" {}
data "aws_caller_identity" "current" {}
variable "region" {}
variable "ecs_service_name" {
  description = "service name for ecs"
  default = "2048"
}

variable "ecs_cluster_name" {
  description = "cluster name for ecs"
  default = "tf-ecs-cluster"
}