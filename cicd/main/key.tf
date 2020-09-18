#TODO Github issue https://github.com/terraform-providers/terraform-provider-aws/issues/11448



resource "aws_kms_alias" "aalias" {
  name = "alias/${var.namespace}-${var.env}"
  target_key_id = aws_kms_key.main.id
}
resource "aws_kms_key" "main" {
  description = "kms key"
  enable_key_rotation = true
  tags = {
    Name = var.namespace
    environment = var.env
    namepspace = var.namespace
  }
  policy = data.aws_iam_policy_document.default.json
}

data "aws_iam_policy_document" "default" {
  version = "2012-10-17"
  statement {
    sid = "Allow administration of the key"
    effect = "Allow"
    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
    actions = [
      "kms:Create*",
      "kms:Describe*",
      "kms:Enable*",
      "kms:List*",
      "kms:Put*",
      "kms:Update*",
      "kms:Revoke*",
      "kms:Disable*",
      "kms:Get*",
      "kms:Delete*",
      "kms:ScheduleKeyDeletion",
      "kms:CancelKeyDeletion",]
    resources = [
      "*"]
  }

  statement {
    sid = "Allow principals in the account to decrypt log files"
    effect = "Allow"
    principals {
      type = "AWS"
      identifiers = [
        aws_iam_role.codebuild-role.arn,
      aws_iam_role.codepipeline-role.arn]
    }
    actions = [
      "kms:DescribeKey",
      "kms:Decrypt",
      "kms:Encrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*"
    ]
    resources = [
      "*"]
  }

  statement {
    sid = "Allow alias creation during setup"
    effect = "Allow"
    principals {
      type = "AWS"
      identifiers = [
        "*"]
    }
    actions = [
      "kms:CreateAlias"]
    resources = [
      "*"]
  }
}



