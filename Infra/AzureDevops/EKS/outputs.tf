output "irsa_role_arn" {
  value = module.karpenter.iam_role_arn
}

output "irsa_role_name" {
  value = module.karpenter.iam_role_name
}

output "karpenter_sqs_name" {
  value = module.karpenter.queue_name
}

# output "karpenter_node_pool_yaml_body" {
#   value = local.node_pool_config
# }

# output "karpenter_node_class_yaml_body" {
#   value = local.node_class_config
# }

output "node_instance_profile_name" {
  value = module.karpenter.instance_profile_name
}