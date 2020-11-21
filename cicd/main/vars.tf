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

variable "ecr_accounts" {
  description = "ecr accounts"
  default = ["805159726499","253737654488" ]
}

locals {
  # Common tags to be assigned to all resources
  common_tags = {
    env = var.env
    namespace   = var.namespace
  }
}