provider "aws" {
  region = var.region
#  assume_role {
#    role_arn = var.role_arn
#  }
#  default_tags {
#    tags = {
#      namespace = var.namespace
#      env = element(split("-", var.namespace), 2) # extract the word beta, dev, etc
#    }
#  }
}


terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.12.0"
    }
  }
}
