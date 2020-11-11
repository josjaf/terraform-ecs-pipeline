
variable "app_image" {
  description = "Docker image to run in the ECS cluster"
  default     = "805159726499.dkr.ecr.us-east-1.amazonaws.com/terraform-ecs:terraform-ecs"
}

variable "app_port" {
  description = "Port exposed by the docker image to redirect traffic to"
  default     = 80
}

variable "app_count" {
  description = "Number of docker containers to run"
  default     = 2
}

variable "fargate_cpu" {
  description = "Fargate instance CPU units to provision (1 vCPU = 1024 CPU units)"
  default     = "256"
}

variable "fargate_memory" {
  description = "Fargate instance memory to provision (in MiB)"
  default     = "512"
}

variable "ecs_service_name" {
  description = "service name for ecs"
  default = "2048"
}

variable "ecs_cluster_name" {
  description = "cluster name for ecs"
  default = "tf-ecs-cluster"
}