resource "aws_s3_bucket" "codepipeline_bucket" {
  bucket_prefix = var.namespace
  acl    = "private"
  versioning {
    enabled = true
  }
}

resource "aws_ssm_parameter" "BucketParameter" {
  name = "/${var.namespace}/bucket"
  type = "String"
  value = aws_s3_bucket.codepipeline_bucket.id
  tags = {
    Name = var.namespace
    environment = var.namespace
  }
}
//!Sub '${AWS::AccountId}.dkr.ecr.${AWS::Region}.amazonaws.com/${ECR}'

resource "aws_s3_bucket_public_access_block" "example" {
  bucket = aws_s3_bucket.codepipeline_bucket.id
  ignore_public_acls = true
  restrict_public_buckets = true
  block_public_acls = true
  block_public_policy = true
}
