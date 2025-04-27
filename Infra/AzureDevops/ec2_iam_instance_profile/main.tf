resource "aws_iam_instance_profile" "this" {
  name = "EC2SSM-${var.instance_name}-InstanceProfile"
  role = aws_iam_role.this.name

  tags = merge(
    var.tags,
    {
      Name = "EC2SSM-${var.instance_name}-InstanceProfile"
    }
  )
}
