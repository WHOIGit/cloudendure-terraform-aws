# VPC to serve as CloudEndure Target for spinning up sites that are external (publicly available)

module "vpc_internal" {
  source  = "terraform-aws-modules/vpc/aws"
  version = ">= 2.0"

  name = "cloud-endure-target-internal"

  cidr = "10.0.0.0/16"

  azs                 = ["us-east-1a"]
  public_subnets      = ["10.0.1.0/24"]
  private_subnets     = []

  enable_dns_support   = true
  enable_dns_hostnames = true
  enable_nat_gateway   = false

  public_dedicated_network_acl = true
  public_inbound_acl_rules = concat(
    local.network_acls["default_inbound"],
    local.network_acls["public_inbound"],
  )
  public_outbound_acl_rules = concat(
    local.network_acls["default_outbound"],
    local.network_acls["public_outbound"],
  )

  tags = local.common_tags
}

locals {
  network_acls = {
    default_inbound = [
      {
        rule_number = 900
        rule_action = "allow"
        from_port   = 1024
        to_port     = 65535
        protocol    = "tcp"
        cidr_block  = "0.0.0.0/0"
      },
    ]
    default_outbound = [
      {
        rule_number = 900
        rule_action = "allow"
        from_port   = 1024
        to_port     = 65535
        protocol    = "tcp"
        cidr_block  = "0.0.0.0/0"
      },
    ]
    public_inbound = [
      {
        rule_number = 100
        rule_action = "allow"
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_block  = "0.0.0.0/0"
      },
      {
        rule_number = 110
        rule_action = "allow"
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_block  = "0.0.0.0/0"
      },
      {
        rule_number = 120
        rule_action = "allow"
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_block  = "0.0.0.0/0"
      },
      {
        rule_number     = 140
        rule_action     = "allow"
        from_port       = 80
        to_port         = 80
        protocol        = "tcp"
        ipv6_cidr_block = "::/0"
      },
    ]
    public_outbound = [
      {
        rule_number = 100
        rule_action = "allow"
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_block  = "0.0.0.0/0"
      },
      {
        rule_number = 110
        rule_action = "allow"
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_block  = "0.0.0.0/0"
      },
      {
        rule_number = 130
        rule_action = "allow"
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_block  = "10.0.1.0/24"
      },
      {
        rule_number = 140
        rule_action = "allow"
        icmp_code   = -1
        icmp_type   = 8
        protocol    = "icmp"
        cidr_block  = "10.0.1.0/24"
      },
      {
        rule_number     = 150
        rule_action     = "allow"
        from_port       = 90
        to_port         = 90
        protocol        = "tcp"
        ipv6_cidr_block = "::/0"
      },
    ]
  }
}
