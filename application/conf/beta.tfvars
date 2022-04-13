bucket = "lg-tf-state"
key = "terraform/terraform-ecs-app.tf"
env = "dev"
namespace = "terraform-ecs"
vpc_tag = "normandy"
region = "us-east-1"
bucket_region = "us-east-1"
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