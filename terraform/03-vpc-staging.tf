# VPC to serve as CloudEndure Target for spinning up sites that are external (publicly available)

module "vpc_staging" {
  source  = "terraform-aws-modules/vpc/aws"
  version = ">= 2.0"

  name = "cloud-endure-staging"

  cidr = "10.0.0.0/16"

  azs                 = ["us-east-1b"]
  public_subnets      = ["10.0.1.0/24"]
  private_subnets     = []

  enable_dns_support   = true
  enable_dns_hostnames = true
  enable_nat_gateway   = false

  tags = local.common_tags
}
