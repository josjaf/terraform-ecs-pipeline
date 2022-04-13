resource "aws_s3_bucket" "codepipeline_bucket" {
  bucket_prefix = var.namespace
}
resource "aws_s3_bucket_versioning" "versioning_example" {
  bucket = aws_s3_bucket.codepipeline_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "example" {
  bucket = aws_s3_bucket.codepipeline_bucket.bucket

  rule {
    apply_server_side_encryption_by_default {
        kms_master_key_id = aws_kms_key.main.arn
        sse_algorithm = "aws:kms"
    }
  }
}
resource "aws_s3_bucket_policy" "s3" {
  bucket = aws_s3_bucket.codepipeline_bucket.id
  policy = data.aws_iam_policy_document.s3.json
}

data "aws_iam_policy_document" "s3" {
  statement {
    sid = "s3"
    effect = "Allow"
    principals {
      identifiers = [for account_id in [data.aws_caller_identity.current.account_id]:
      "arn:aws:iam::${account_id}:root"
      ]
      type = "AWS"
    }
    actions = [
      "s3:Get*",
      "s3:List*",
      "s3:Put*"
    ]
    resources = [
      "${aws_s3_bucket.codepipeline_bucket.arn}",
      "${aws_s3_bucket.codepipeline_bucket.arn}/*"
    ]
  }
}

resource "aws_ssm_parameter" "BucketParameter" {
  name = "/${var.namespace}/bucket"
  type = "String"
  value = aws_s3_bucket.codepipeline_bucket.id
  tags = local.common_tags

}
//!Sub '${AWS::AccountId}.dkr.ecr.${AWS::Region}.amazonaws.com/${ECR}'

resource "aws_s3_bucket_public_access_block" "example" {
  depends_on = [aws_s3_bucket.codepipeline_bucket, aws_s3_bucket_policy.s3]
  bucket = aws_s3_bucket.codepipeline_bucket.id
  ignore_public_acls = true
  restrict_public_buckets = true
  block_public_acls = true
  block_public_policy = true
}
