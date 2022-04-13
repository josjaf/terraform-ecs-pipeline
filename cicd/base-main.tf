terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
//      version = "3.1.0"
    }
  }
  required_version = ">= 0.13"
}

provider "aws" {
  region = var.region
}
variable "namespace" {
  type = string
}
variable "env" {
  type = string
}
data "aws_caller_identity" "current" {}


variable "bucket" {}
variable "region" {}
variable "bucket_region" {}
variable "key" {}
variable "vpc_tags_isolated_subnets" {}
variable "vpc_tags_private_subnets" {}
variable "vpc_tags_public_subnets" {}

terraform {
  backend "s3" {
    bucket = var.bucket
    key    = var.key
    region = var.region
  }
}
//terraform {
//  backend "http" {
//  }
//}
variable "key_name" {}
variable "image_receipe_version" {}
module "codepipeline-docker" {
  source    = "./main"
  env       = var.env
  namespace = var.namespace
  region = var.region
}

resource "aws_s3_bucket" "main" {
  bucket_prefix = var.namespace
  force_destroy = true

}
#module "imagebuilder_container" {
#  source = "./image_builder"
#  namespace = var.namespace
#  aws_region = var.region
#  ebs_root_vol_size = 100
#  current_account_id = data.aws_caller_identity.current.account_id
#  vpc_id = var.vpc_id
#  key_name = var.key_name
#  image_receipe_version = "1.0.1"
#  s3_bucket = aws_s3_bucket.main.id
#  vpc_tags_public_subnets = var.vpc_tags_public_subnets
#  vpc_tags_private_subnets = var.vpc_tags_private_subnets
#}