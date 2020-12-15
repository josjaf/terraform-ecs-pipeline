output "ecr_uri" {
  value = aws_ecr_repository.ecr.repository_url
}
output "pipeline_bucket" {
  value = aws_s3_bucket.codepipeline_bucket.bucket
}