locals {
  # Common tags to be assigned to all resources
  common_tags = {
    namespace = var.namespace
    env = var.env
    terraform = "true"
  }
}