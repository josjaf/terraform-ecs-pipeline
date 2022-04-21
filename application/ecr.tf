resource "aws_ecr_repository" "ecr" {
  name = var.namespace
  # image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

}
resource "aws_ecr_repository_policy" "ecrrepo" {
  repository = aws_ecr_repository.ecr.name
  policy = data.aws_iam_policy_document.developer_policy_doc.json
}

# this is optional for letting cross account ecr
data "aws_iam_policy_document" "developer_policy_doc" {
  statement {
    sid = "DevAccounts"
    effect = "Allow"
    principals {
      identifiers = [for account_id in [data.aws_caller_identity.current.account_id]:
      "arn:aws:iam::${account_id}:root"
      ]
      type = "AWS"
    }
    actions = [
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ecr:BatchCheckLayerAvailability",
      "ecr:PutImage",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload"
    ]
  }
  statement {
    sid = "Self"
    effect = "Allow"
    principals {
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
      ]
      type = "AWS"
    }
    actions = [
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ecr:BatchCheckLayerAvailability",
      "ecr:PutImage",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload"
    ]
  }

}

resource "aws_ssm_parameter" "RepoURI" {
  name = "/${var.namespace}/ecr/uri"
  type = "String"
  value = aws_ecr_repository.ecr.repository_url
  tags = {
    Name = var.namespace
    environment = var.namespace
  }
}
resource "aws_ssm_parameter" "RepoArn" {
  name = "/${var.namespace}/ecr/arn"
  type = "String"
  value = aws_ecr_repository.ecr.arn
  tags = {
    Name = var.namespace
    environment = var.namespace
  }
}
