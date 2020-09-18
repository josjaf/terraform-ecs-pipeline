terraform {
//  required_providers {
//    aws = {
//      source  = "hashicorp/aws"
//      version = "3.1.0"
//    }
//  }
//  required_version = ">= 0.13"
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


variable "bucket" {}
variable "region" {}
variable "bucket_region" {}
variable "key" {}
terraform {
  backend "s3" {
    bucket = var.bucket
    key    = var.key # hard coding since this is a less disposable
    region = var.bucket_region
  }
}


module "codepipeline-docker" {
  source    = "./main"
  env       = var.env
  namespace = var.namespace
}