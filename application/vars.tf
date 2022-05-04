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

variable "vpc_tag" {}
variable "vpc_tags_public_subnets" {}
variable "vpc_tags_private_subnets" {}
variable "vpc_tags_isolated_subnets" {}
