resource "aws_iam_role" "this" {
  name                 = "EC2SSM-${var.instance_name}-InstanceProfileRole"
  description          = "Role for ${var.instance_name} instance profile to allow SSM and other service access"
  max_session_duration = var.max_session_duration
  path                 = local.role_path

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  tags = merge(
    var.tags,
    {
      Name = "${"EC2SSM-${var.instance_name}-InstanceProfileRole"}"
    }
  )
}
