resource "aws_s3_bucket" "codepipeline_bucket" {
  bucket_prefix = var.namespace
  acl = "private"
  versioning {
    enabled = true
  }
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = aws_kms_key.main.arn
        sse_algorithm     = "aws:kms"
      }
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
      identifiers = [for account_id in var.ecr_accounts:
      "arn:aws:iam::${account_id}:role/josjaffe@amazon.com"
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
