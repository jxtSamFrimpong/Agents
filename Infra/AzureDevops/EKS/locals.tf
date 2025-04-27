locals {
  node_class_config = yamldecode(templatefile("${path.module}/manifests/karpenter-node-class.yaml.tpl", {
    karpenterNodeClassName = "exeter-dev-node-class"
    karpenterNamespace = "karpenter"
    clusterName = "exeter-dev"
    karpenterNodeRoleArn = module.eks.eks_managed_node_groups["exeter-dev-test-karpenter"].iam_role_arn
    karpenterNodeInstanceProfileName = module.karpenter.instance_profile_name
    kmsKeyID = module.eks.kms_key_id
  }))

  node_pool_config = yamldecode(templatefile("${path.module}/manifests/karpenter-node-pools.yaml.tpl", {
    karpenterNodePoolName = "exeter-dev-karpenter-pool"
    karpenterNamespace = "karpenter"
    clusterName = "exeter-dev"
    karpenterNodeClassName = "exeter-dev-node-class"
  }))
}