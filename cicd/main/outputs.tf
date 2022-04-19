output "ecr_uri" {
  value = data.aws_ssm_parameter.ecr_uri.id
}
output "pipeline_bucket" {
  value = aws_s3_bucket.codepipeline_bucket.bucket
}