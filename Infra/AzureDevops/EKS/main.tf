module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.36"

  cluster_name    = "exeter-dev"
  cluster_version = "1.31"

  cluster_addons = {
    coredns                = {
      most_recent = true
    }
    eks-pod-identity-agent = {
      most_recent = true
    }
    kube-proxy             = {
      most_recent = true
    }
    vpc-cni                = {
      most_recent = true
    }
  }

  create_iam_role = true

  cluster_endpoint_public_access = true
  cluster_endpoint_public_access_cidrs = ["0.0.0.0/0"]
  enable_cluster_creator_admin_permissions = true

  vpc_id                   = "vpc-06e2765871c16a6a4"
  subnet_ids               = ["subnet-02f08990ff42b9e6e", "subnet-0445abb714ec8207a", "subnet-0fde7e528d043edbb"]
  control_plane_subnet_ids = ["subnet-02f08990ff42b9e6e", "subnet-0445abb714ec8207a", "subnet-0fde7e528d043edbb"]

  # EKS Managed Node Group(s)
  eks_managed_node_group_defaults = {
    ami_type               = "AL2023_x86_64_STANDARD"
    instance_types = ["m6i.large", "m5.large", "m5n.large", "m5zn.large"]
    ebs_optimized        = true
  }

  eks_managed_node_groups = {
    exeter-dev-test-karpenter = {
      min_size     = 1
      max_size     = 10
      desired_size = 2
      name         = "exeter-dev-test-karpenter"

      

      capacity_type  = "SPOT"
      iam_role_name  = "exeter-dev-test-karpenter"

      ##https://docs.aws.amazon.com/prescriptive-guidance/latest/patterns/connect-to-an-amazon-ec2-instance-by-using-session-manager.html
      iam_role_additional_policies = {
        AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
        PricingPolicy                = aws_iam_policy.Pricing.arn
        Ec2TypeOffersPolicy          = aws_iam_policy.Ec2TypeOffers.arn
      }

      labels = {
        Environment = "dev"
        GithubRepo  = "terraform-aws-eks"
        GithubOrg   = "terraform-aws-modules"
        nodegroup = "exeter-dev-test-karpenter"
      }
    }
  }



  authentication_mode = "API_AND_CONFIG_MAP"


  # Ensure the IAM role used by Terraform has permissions to manage the aws-auth ConfigMap
  iam_role_additional_policies = {
    eks-cluster-policy = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
    eks-service-policy = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  }

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }

  cluster_security_group_tags = {
    Environment = "dev"
    "karpenter.sh/discovery" = "exeter-dev"
  }

  node_security_group_tags = {
    Environment = "dev"
    "karpenter.sh/discovery" = "exeter-dev"
  }
}


#https://github.com/terraform-aws-modules/terraform-aws-eks/blob/v19.21.0/examples/karpenter/main.tf
#https://github.com/aws/karpenter-provider-aws/blob/main/charts/karpenter/README.md
#https://docs.aws.amazon.com/eks/latest/best-practices/karpenter.html
module "karpenter" {
  source  = "terraform-aws-modules/eks/aws//modules/karpenter"
  version = "~> 20.36"

  cluster_name = module.eks.cluster_name
  
  create_iam_role = true
  create_node_iam_role = false
  create_instance_profile = true
  
  create_pod_identity_association = true
  enable_irsa = true
  create_access_entry = false
  
  node_iam_role_arn = module.eks.eks_managed_node_groups["exeter-dev-test-karpenter"].iam_role_arn
  # node_iam_role_additional_policies = {
  #   AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  #   PricingPolicy                = aws_iam_policy.Pricing.arn
  #   Ec2TypeOffersPolicy          = aws_iam_policy.Ec2TypeOffers.arn
  # }
  

  irsa_oidc_provider_arn          = module.eks.oidc_provider_arn
  irsa_namespace_service_accounts = ["karpenter:karpenter"]

    


  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}

resource "aws_iam_policy" "Pricing" {
  name        = "PricingPolicy"
  description = "IAM policy to allow access to AWS Pricing API"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "pricing:GetProducts"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_policy" "Ec2TypeOffers" {
  name        = "Ec2TypeOffersPolicy"
  description = "IAM policy to allow access to EC2 DescribeInstanceTypeOfferings API"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "ec2:DescribeInstanceTypeOfferings"
        Resource = "*"
      },
      {
        Effect   = "Allow"
        Action   = "ec2:DescribeInstanceTypes"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "Pricing" {
  role       = module.karpenter.iam_role_name
  policy_arn = aws_iam_policy.Pricing.arn
}

resource "aws_iam_role_policy_attachment" "Ec2TypeOffers" {
  role       = module.karpenter.iam_role_name
  policy_arn = aws_iam_policy.Ec2TypeOffers.arn
}



resource "kubernetes_namespace" "karpenter" {
  metadata {
    annotations = {
      name = "karpenter"
    }

    name = "karpenter"
  }

  depends_on = [module.eks]
}
resource "kubernetes_service_account" "karpenter" {
  metadata {
    name      = "karpenter"
    namespace = "karpenter" #kubernetes_namespace.karpenter.metadata[0].name

    annotations = {
      "eks.amazonaws.com/role-arn" = module.karpenter.iam_role_arn
      "meta.helm.sh/release-name" = "karpenter"
      "meta.helm.sh/release-namespace" = "karpenter"
    }

    labels = {
      "app.kubernetes.io/managed-by" = "Helm"
    }
  }

  automount_service_account_token = true

  depends_on = [module.eks, kubernetes_namespace.karpenter]
}


resource "helm_release" "karpenter" {
  namespace        = "karpenter"
  create_namespace = false

  name                = "karpenter"
  repository          = "oci://public.ecr.aws/karpenter"
  repository_username = data.aws_ecrpublic_authorization_token.token.user_name
  repository_password = data.aws_ecrpublic_authorization_token.token.password
  chart               = "karpenter"
  version             = "1.4.0"

  values = [
    <<-EOT
    settings:
      clusterName: ${module.eks.cluster_name}
      clusterEndpoint: ${module.eks.cluster_endpoint}
      interruptionQueueName: ${module.karpenter.queue_name}
    serviceAccount:
      create: false
      name: karpenter
    EOT
  ]

  depends_on = [
    module.eks,
    kubernetes_service_account.karpenter,
    aws_iam_role_policy_attachment.Pricing,
    aws_iam_role_policy_attachment.Ec2TypeOffers,
    kubernetes_namespace.karpenter
  ]

  timeout = 300
}

