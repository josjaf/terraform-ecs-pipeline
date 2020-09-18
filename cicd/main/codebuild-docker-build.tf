resource "aws_iam_role" "codebuild-role" {
  name = "${var.namespace}-codebuild"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codebuild.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}
resource "aws_iam_role_policy_attachment" "s3test-attach" {
  role = aws_iam_role.codebuild-role.id
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_role_policy" "codebuildkms" {
  name_prefix = "kms"
  role = aws_iam_role.codebuild-role.id
  policy = <<EOF
{
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "kms:DescribeKey",
        "kms:Decrypt",
        "kms:Encrypt",
        "kms:ReEncrypt*",
        "kms:GenerateDataKey*"
      ],
      "Resource": [
        "${aws_kms_key.main.arn}"
      ]
    }
  ]
}
EOF
}

resource "aws_codebuild_project" "dockerbuild" {
  name = var.namespace
  description = "test_codebuild_project"
  build_timeout = "15"
  service_role = aws_iam_role.codebuild-role.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image = "aws/codebuild/standard:4.0"
    type = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode = true
    environment_variable {
      name = "ecr"
      value = aws_ecr_repository.ecr.repository_url
    }

    environment_variable {
      name = "tag"
      value = var.namespace
    }
  }


  source {
    type = "CODEPIPELINE"
    buildspec = "cicd/pipeline_delivery/docker_build_buildspec.yml"
  }

  source_version = "master"



  tags = {
    env = var.env
  }
}
resource "aws_iam_role_policy" "codebuild_policy" {
  name = "codepipeline_policy"
  role = aws_iam_role.codebuild-role.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect":"Allow",
      "Action": [
        "s3:GetObject",
        "s3:GetObjectVersion",
        "s3:GetBucketVersioning",
        "s3:PutObject"
      ],
      "Resource": [
        "${aws_s3_bucket.codepipeline_bucket.arn}",
        "${aws_s3_bucket.codepipeline_bucket.arn}/*"
      ]
    },
    {
      "Effect":"Allow",
      "Action": [
      "ecr:GetAuthorizationToken",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload",
      "ecr:PutImage",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:GetRepositoryPolicy",
      "ecr:DescribeRepositories",
      "ecr:ListImages",
      "ecr:DescribeImages",
      "ecr:BatchGetImage",
      "ecr:DescribeImageScanFindings",
      "ecr:StartImageScan",
      "ecr:BatchDeleteImage",
      "ecr:SetRepositoryPolicy",
      "ecr:DeleteRepositoryPolicy",
      "ecr:DeleteRepository"
    ],
      "Resource": [
        "${aws_ecr_repository.ecr.arn}"

      ]
    },
    {
      "Effect":"Allow",
      "Action": [
      "ecr:GetAuthorizationToken"

    ],
      "Resource": [
        "*"

      ]
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "jump_linux_ec2_role_policy" {
  name = "AWSLambdaBasicExecutionRole"
  role = aws_iam_role.codebuild-role.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:GetLogEvents",
        "logs:PutLogEvents"
      ],
      "Effect": "Allow",
      "Resource":"arn:aws:logs:*:*:*"
    }
  ]
}
EOF
}
