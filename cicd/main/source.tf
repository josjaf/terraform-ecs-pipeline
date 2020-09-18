resource "aws_iam_role_policy" "codepipeline_cc_policy" {
  name = "codecommit_policuy"
  role = aws_iam_role.codepipeline-role.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect":"Allow",
      "Action": [
        "codecommit:GetBranch",
        "codecommit:GetCommit",
        "codecommit:UploadArchive",
        "codecommit:GetUploadArchiveStatus",
        "codecommit:CancelUploadArchive"
      ],
      "Resource": [
        "${aws_codecommit_repository.repo.arn}"

      ]
    }
  ]
}
EOF
}

resource "aws_codecommit_repository" "repo" {
  repository_name = var.namespace
}
