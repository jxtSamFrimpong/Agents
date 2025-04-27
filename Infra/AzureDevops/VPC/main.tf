module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "exeter-dev"
  cidr = "10.10.0.0/16"

  azs             = ["eu-central-1a", "eu-central-1b", "eu-central-1c"]
  private_subnets = ["10.10.11.0/24", "10.10.12.0/24", "10.10.13.0/24"]
  public_subnets  = ["10.10.21.0/24", "10.10.22.0/24", "10.10.23.0/24"]

  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false
  enable_vpn_gateway     = false

  enable_dns_hostnames = true
  enable_dns_support   = true

  public_subnet_private_dns_hostname_type_on_launch = "ip-name"
  private_subnet_private_dns_hostname_type_on_launch = "ip-name"
  map_public_ip_on_launch = true

  public_subnet_tags = {
    Type                              = "exeter-dev-public"
    "kubernetes.io/role/elb" = 1
    "karpenter.sh/discovery" = "exeter-dev"
  }
  private_subnet_tags = {
    Type                     = "exeter-dev-private"
    "kubernetes.io/role/internal-elb" = 1
    "karpenter.sh/discovery" = "exeter-dev"
  }

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}