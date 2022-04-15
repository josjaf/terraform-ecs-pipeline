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

data "aws_caller_identity" "current" {}