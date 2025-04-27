# output "profile_name" {
#   description = "The name of the IAM instance profile."
#   value       = aws_iam_instance_profile.this.name
# }

# output "profile_arn" {
#   description = "The ARN assigned by AWS to the IAM instance profile."
#   value       = aws_iam_instance_profile.this.arn
# }

# output "profile_id" {
#   description = "The ID of the IAM instance profile."
#   value       = aws_iam_instance_profile.this.id
# }

# output "profile_unique_id" {
#   description = "The unique ID of the IAM instance profile."
#   value       = aws_iam_instance_profile.this.unique_id
# }

output "role_arn" {
  value = aws_iam_role.this.arn
}

output "role_create_date" {
  value = aws_iam_role.this.create_date
}

output "role_name" {
  value = aws_iam_role.this.name
}

output "role_unique_id" {
  value = aws_iam_role.this.unique_id
}

