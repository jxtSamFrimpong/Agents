module "auth" {
  source  = "terraform-aws-modules/eks/aws//modules/aws-auth"
  version = "~> 20.0"

  manage_aws_auth_configmap = true

  aws_auth_roles = [
    {
      rolearn  = "arn:aws:iam::046853805690:role/exeter/dev/iam/roles/ec2InstanceProfile/DefaultEC2SSM/EC2SSM-DefaultEC2SSM-InstanceProfileRole"
      username = "EC2SSM-DefaultEC2SSM-InstanceProfile"
      groups   = ["system:bootstrappers", "system:nodes", "system:masters"]
    },
    {
      rolearn  = module.eks.eks_managed_node_groups["exeter-dev-test-karpenter"].iam_role_arn
      username = "system:node:{{EC2PrivateDNSName}}"
      groups = [
        "system:bootstrappers",
        "system:nodes",
      ]
    }
  ]

  aws_auth_users = [
    {
      userarn  = "arn:aws:iam::046853805690:user/iam-dev"
      username = "iam-dev"
      groups   = ["system:masters"]
    },
    {
      userarn  = "arn:aws:iam::046853805690:root"
      username = "root-user"
      groups   = ["system:masters"]
    }
  ]

  aws_auth_accounts = [
    "046853805690"
  ]

  create_aws_auth_configmap = false
}