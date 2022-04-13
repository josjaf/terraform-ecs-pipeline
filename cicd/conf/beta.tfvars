bucket = "lg-tf-state"
key = "terraform/terraform-ecs-cicd.tf"
env = "dev"
namespace = "terraform-ecs"
vpc_id = "vpc-08fd11e62526795f1"
region = "us-east-1"
bucket_region = "us-east-1"
key_name = "josjaffe"
image_receipe_version = "1.0.0"
vpc_tags_isolated_subnets = {
  key   = "Network"
  value = "Isolated"
}

vpc_tags_private_subnets = {
  key   = "Network"
  value = "Private"
}
vpc_tags_public_subnets = {

  key   = "Network"
  value = "Public"
}
