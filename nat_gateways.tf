resource "aws_nat_gateway" "env-01-natgw-a" {
  allocation_id = aws_eip.env-01-nat-gw-a-eip.id
  subnet_id     = aws_subnet.env-01-sub-a-pub.id

  tags = {
    Name = "env-01-natgw-a"
  }
}

resource "aws_nat_gateway" "env-01-natgw-b" {
  allocation_id = aws_eip.env-01-nat-gw-b-eip.id
  subnet_id     = aws_subnet.env-01-sub-b-pub.id

  depends_on = [aws_internet_gateway.env-01-igw]

  tags = {
    Name = "env-01-natgw-b"
  }
}
