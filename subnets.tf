data "aws_availability_zones" "available" {}

resource "aws_subnet" "env-01-sub-a-pub" {
  assign_ipv6_address_on_creation = "false"
  cidr_block                      = "10.1.1.0/24"
  map_public_ip_on_launch         = "false"
  availability_zone               = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "env-01-sub-a-pub"
  }

  vpc_id = aws_vpc.env-01-vpc.id
}

resource "aws_subnet" "env-01-sub-b-pub" {
  assign_ipv6_address_on_creation = "false"
  cidr_block                      = "10.1.2.0/24"
  map_public_ip_on_launch         = "false"
  availability_zone               = data.aws_availability_zones.available.names[1]

  tags = {
    Name = "env-01-sub-b-pub"
  }

  vpc_id = aws_vpc.env-01-vpc.id
}

resource "aws_subnet" "env-01-sub-a-priv" {
  assign_ipv6_address_on_creation = "false"
  cidr_block                      = "10.1.3.0/24"
  map_public_ip_on_launch         = "false"
  availability_zone               = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "env-01-sub-a-priv"
  }

  vpc_id = aws_vpc.env-01-vpc.id
}

resource "aws_subnet" "env-01-sub-b-priv" {
  assign_ipv6_address_on_creation = "false"
  cidr_block                      = "10.1.4.0/24"
  map_public_ip_on_launch         = "false"
  availability_zone               = data.aws_availability_zones.available.names[1]

  tags = {
    Name = "env-01-sub-b-priv"
  }

  vpc_id = aws_vpc.env-01-vpc.id
}
