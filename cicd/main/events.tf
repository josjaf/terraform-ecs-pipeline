
resource "aws_cloudwatch_event_rule" "codecommittocodepipeline" {
//  name_prefix = "${var.namespace}-pipeline"
  description = "codecommit to codepipeline"
  event_pattern = <<PATTERN
{
  "source": [
    "aws.codecommit"
  ],
  "detail-type": [
    "CodeCommit Repository State Change"
  ],
  "resources": [
  "${aws_codecommit_repository.repo.arn}"
  ],
  "detail": {
    "event": [
      "referenceCreated",
      "referenceUpdated"
      ],
    "referenceType": ["branch"],
    "referenceName": ["master"]

  }
}
PATTERN
}

resource "aws_iam_role" "events-role-codecommit-codepipeline" {
  name_prefix = "${var.namespace}-events"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "events.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}
resource "aws_iam_role_policy" "startpipeline" {
  name_prefix = "codepipeline"
  role = aws_iam_role.events-role-codecommit-codepipeline.id
  policy = <<EOF
{
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "codepipeline:StartPipelineExecution"
      ],
      "Resource": [
        "${aws_codepipeline.codepipeline.arn}"
      ]
    }
  ]
}
EOF
}

resource "aws_cloudwatch_event_target" "yada" {
  target_id = "cccp"
  rule = aws_cloudwatch_event_rule.codecommittocodepipeline.name
  arn = aws_codepipeline.codepipeline.arn
  role_arn = aws_iam_role.events-role-codecommit-codepipeline.arn
}
