locals {
  role_path = var.set_role_path ? "${var.path}/${var.instance_name}/" : null

  AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  AmazonSSMPatchAssociation    = "arn:aws:iam::aws:policy/AmazonSSMPatchAssociation"
  CloudWatchAgentServerPolicy  = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
  additional_policies          = { for k, v in var.additional_policies : k => v }
}
