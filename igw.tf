resource "aws_internet_gateway" "env-01-igw" {
  tags = {
    Name = "env-01-igw"
  }

  vpc_id = aws_vpc.env-01-vpc.id
}
