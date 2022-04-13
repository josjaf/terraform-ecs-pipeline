data "aws_vpc" "VPC" {
  filter {
    name   = "tag:Name"
    values = [
      var.vpc_tag
    ]
  }
}
# for the alb

data "aws_subnets" "public_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.VPC.id]
  }
  filter {
    name = "tag:${lookup(var.vpc_tags_public_subnets, "key" )}"
    values = [
      lookup(var.vpc_tags_public_subnets, "value" )]
  }
}
# backend
data "aws_subnets" "private_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.VPC.id]
  }
  filter {
    name = "tag:${lookup(var.vpc_tags_private_subnets, "key" )}"
    values = [
      lookup(var.vpc_tags_private_subnets, "value" )]
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
data "aws_caller_identity" "current" {}