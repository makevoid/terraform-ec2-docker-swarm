resource "aws_vpc" "env-01-vpc" {
  assign_generated_ipv6_cidr_block = "false"
  cidr_block                       = "10.1.0.0/16"
  enable_classiclink               = "false"
  enable_classiclink_dns_support   = "false"
  enable_dns_hostnames             = "false"
  enable_dns_support               = "true"
  instance_tenancy                 = "default"

  tags = {
    Name = "env-01-vpc"
  }
}
