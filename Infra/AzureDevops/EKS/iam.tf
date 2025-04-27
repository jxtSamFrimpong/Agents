data "aws_iam_policy_document" "kms_access" {
  statement {
    actions   = [
        "kms:CreateGrant",
        "kms:Decrypt",
        "kms:DescribeKey",
        "kms:GenerateDataKeyWithoutPlainText",
        "kms:ReEncrypt"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "kms_access" {
    name = "kms-access"
    policy = "${data.aws_iam_policy_document.kms_access.json}"
}

resource "aws_iam_role_policy_attachment" "kms_access_karpenter" {
  role       = module.karpenter.iam_role_name
  policy_arn = aws_iam_policy.kms_access.arn
}

resource "aws_iam_role_policy_attachment" "kms_access_node" {
  role       = module.eks.eks_managed_node_groups["exeter-dev-test-karpenter"].iam_role_name
  policy_arn = aws_iam_policy.kms_access.arn
}

