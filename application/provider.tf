provider "aws" {
  region  = var.region

#  default_tags {
#    tags = {
#      namespace = var.namespace
#      env       = var.env
#    }
#  }
}
terraform {
  required_providers {
    aws = {
      source       = "hashicorp/aws"
    }
  }
  required_version = ">= 0.15"
}
