resource "aws_iam_role" "codepipeline-role" {
  name = "${var.namespace}-pipeline"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codepipeline.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}
resource "aws_iam_role_policy_attachment" "codepipeline-attach" {
  role = aws_iam_role.codepipeline-role.id
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}
resource "aws_iam_role_policy" "codepipeline_policy" {
  name = "codepipeline_policy"
  role = aws_iam_role.codepipeline-role.id

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
        "s3:PutObject",
        "s3:Get*",
        "s3:Put*"
      ],
      "Resource": [
        "${aws_s3_bucket.codepipeline_bucket.arn}",
        "${aws_s3_bucket.codepipeline_bucket.arn}/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "codebuild:BatchGetBuilds",
        "codebuild:StartBuild"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}


resource "aws_iam_role_policy" "cp-kms" {
  name_prefix = "kms"
  role = aws_iam_role.codepipeline-role.id
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


resource "aws_codepipeline" "codepipeline" {
  name = var.namespace
  role_arn = aws_iam_role.codepipeline-role.arn

  artifact_store {
    location = aws_s3_bucket.codepipeline_bucket.bucket
    type = "S3"

    encryption_key {
      id = aws_kms_key.main.key_id
      type = "KMS"
    }
  }

  stage {
    name = "Source"

    action {
      name = "Source"
      category = "Source"
      owner = "AWS"
      provider = "CodeCommit"
      version = "1"
      output_artifacts = [
        "source_output"]

      configuration = {
        PollForSourceChanges = false
        RepositoryName = aws_codecommit_repository.repo.id
        BranchName = "master"

      }
    }
  }

  stage {
    name = "Build"

    action {
      name = "Build"
      category = "Build"
      owner = "AWS"
      provider = "CodeBuild"
      input_artifacts = [
        "source_output"]
      output_artifacts = ["build_output"]
      version = "1"

      configuration = {
        ProjectName = aws_codebuild_project.dockerbuild.id
      }
    }
  }
  stage {
    name = "Deploy"

    action {
      name = "ECSDeploy"
      run_order = 1
      category = "Deploy"
      owner = "AWS"
      provider = "ECS"
      input_artifacts = [
        "build_output"]
      version = "1"

      configuration = {
        ClusterName = var.ecs_cluster_name
        ServiceName = var.ecs_service_name
        FileName = "imagedefinitions.json"
      }
    }
  }
}
resource "aws_ssm_parameter" "PipelineParameter" {
  name = "${var.namespace}-pipeline"
  type = "String"
  value = aws_codepipeline.codepipeline.id
  tags = {
    Name = var.namespace
    environment = var.namespace
  }
}



