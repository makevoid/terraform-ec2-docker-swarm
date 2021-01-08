resource "aws_route_table" "env-01-rt-pub" {
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.env-01-igw.id
  }

  tags = {
    Name = "env-01-rt-pub"
  }

  vpc_id = aws_vpc.env-01-vpc.id
}

resource "aws_route_table" "env-01-rt-priv" {
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.env-01-natgw-a.id
  }

  tags = {
    Name = "env-01-rt-priv"
  }

  vpc_id = aws_vpc.env-01-vpc.id
}

# assoc:

# public

resource "aws_route_table_association" "env-01-rtassoc-a-pub" {
  route_table_id = aws_route_table.env-01-rt-pub.id
  subnet_id      = aws_subnet.env-01-sub-a-pub.id
}

resource "aws_route_table_association" "env-01-rtassoc-b-pub" {
  route_table_id = aws_route_table.env-01-rt-pub.id
  subnet_id      = aws_subnet.env-01-sub-b-pub.id
}

# private

resource "aws_route_table_association" "env-01-rtassoc-a-priv" {
  route_table_id = aws_route_table.env-01-rt-priv.id
  subnet_id      = aws_subnet.env-01-sub-a-priv.id
}

resource "aws_route_table_association" "env-01-rtassoc-b-priv" {
  route_table_id = aws_route_table.env-01-rt-priv.id
  subnet_id      = aws_subnet.env-01-sub-b-priv.id
}
