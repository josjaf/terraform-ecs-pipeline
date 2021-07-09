data "aws_vpc" "VPC" {
  filter {
    name = "vpc-id"
    values = [
    var.vpc_id]
  }
}
data "aws_subnet_ids" "public_subnets" {
  vpc_id = var.vpc_id
  filter {
    name = "tag:Network"
    values = [
    "Public"]
  }
}
data "aws_subnet_ids" "private_subnets" {
  vpc_id = var.vpc_id
  filter {
    name = "tag:Network"
    values = [
    "Private"]
  }
}
data "aws_ssm_parameter" "ecr" {
  name = "/${var.namespace}/ecr/uri"
}
data "aws_ssm_parameter" "ecrarn" {
  name = "/${var.namespace}/ecr/arn"
}