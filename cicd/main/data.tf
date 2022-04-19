# get the ecr uri for the image
data "aws_ssm_parameter" "ecr_uri" {
  name = "/${var.namespace}/ecr/uri"
}
# get the ecr arn for iam permissions to pull the image from the repo
data "aws_ssm_parameter" "ecrarn" {
  name = "/${var.namespace}/ecr/arn"
}