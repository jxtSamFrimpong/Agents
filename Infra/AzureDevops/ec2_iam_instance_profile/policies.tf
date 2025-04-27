data "aws_iam_policy_document" "additional_policies" {
  for_each = local.additional_policies
  statement {
    sid = each.key

    actions = lookup(each.value, "actions")

    resources = lookup(each.value, "resources")

    dynamic "condition" {
      for_each = lookup(each.value, "conditions")
      content {
        test     = condition.value.test
        variable = condition.value.variable
        values   = condition.value.values
      }
    }
  }
}

resource "aws_iam_policy" "this" {
  for_each = data.aws_iam_policy_document.additional_policies
  name     = "${lookup(lookup(local.additional_policies, each.key), "name")}-InstanceProfilePolicy"
  path     = lookup(lookup(local.additional_policies, each.key), "path", "iam/policies/ec2-instance-profile/${lookup(lookup(local.additional_policies, each.key), "name")}/")
  policy   = each.value.json

  tags = merge(
    var.tags,
    {
      Name = "${lookup(lookup(local.additional_policies, each.key), "name")}-InstanceProfilePolicy"
    }
  )
}


resource "aws_iam_role_policy_attachment" "this" {
  for_each   = aws_iam_policy.this
  role       = aws_iam_role.this.name
  policy_arn = each.value.arn
}

resource "aws_iam_role_policy_attachment" "AmazonSSMManagedInstanceCore" {
  role       = aws_iam_role.this.name
  policy_arn = local.AmazonSSMManagedInstanceCore
}

resource "aws_iam_role_policy_attachment" "AmazonSSMPatchAssociation" {
  role       = aws_iam_role.this.name
  policy_arn = local.AmazonSSMPatchAssociation
}

resource "aws_iam_role_policy_attachment" "CloudWatchAgentServerPolicy" {
  role       = aws_iam_role.this.name
  policy_arn = local.CloudWatchAgentServerPolicy
}
