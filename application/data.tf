data "aws_vpc" "VPC" {
  filter {
    name = "vpc-id"
    values = [
    var.vpc_id]
  }
}

# for the alb
data "aws_subnet_ids" "public_subnets" {
  vpc_id = var.vpc_id
  filter {
    name = "tag:Network"
    values = [
    "Public"]
  }
}
# backend
data "aws_subnet_ids" "private_subnets" {
  vpc_id = var.vpc_id
  filter {
    name = "tag:Network"
    values = [
    "Private"]
  }
}
# get the ecr uri for the image
data "aws_ssm_parameter" "ecr" {
  name = "/${var.namespace}/ecr/uri"
}
# get the ecr arn for iam permissions to pull the image from the repo
data "aws_ssm_parameter" "ecrarn" {
  name = "/${var.namespace}/ecr/arn"
}