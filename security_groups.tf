resource "aws_security_group" "env-01-sg-bas" {
  description = "Allows access from Internet to Bastion"

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = "0"
    protocol    = "-1"
    self        = "false"
    to_port     = "0"
  }

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = "22"
    protocol    = "tcp"
    self        = "false"
    to_port     = "22"
  }

  name = "env-01-sg-bas"

  tags = {
    Name = "env-01-sg-bas"
  }

  vpc_id = aws_vpc.env-01-vpc.id
}

resource "aws_security_group" "env-01-sg-vms" {
  description = "Manages SSH access between vms"

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = "0"
    protocol    = "-1"
    self        = "false"
    to_port     = "0"
  }

  ingress {
    cidr_blocks = ["10.1.0.0/16"]
    from_port   = "22"
    protocol    = "tcp"
    self        = "false"
    to_port     = "22"
  }

  name = "env-01-sg-vms"

  tags = {
    Name = "env-01-sg-vms"
  }

  vpc_id = aws_vpc.env-01-vpc.id
}

resource "aws_security_group" "env-01-lb-sg" {
  description = "Allow internet traffic to reach load balancer"

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = "0"
    protocol    = "-1"
    self        = "false"
    to_port     = "0"
  }

  ingress {
    cidr_blocks      = ["0.0.0.0/0"]
    from_port        = "80"
    ipv6_cidr_blocks = ["::/0"]
    protocol         = "tcp"
    self             = "false"
    to_port          = "80"
  }

  name = "env-01-lb-sg"

  tags = {
    Name = "env-01-lb-sg"
  }

  vpc_id = aws_vpc.env-01-vpc.id
}


resource "aws_security_group" "env-01-sg-swarm" {
  description = "Allows Docker swarm communication between swarm master VMs and allows traffic from load balancer to reach the swarm VMs"

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = "0"
    protocol    = "-1"
    self        = "false"
    to_port     = "0"
  }

  ingress {
    cidr_blocks = ["10.1.0.0/16"]
    from_port   = "2377"
    protocol    = "tcp"
    self        = "false"
    to_port     = "2377"
  }

  ingress {
    cidr_blocks = ["10.1.0.0/16"]
    from_port   = "4789"
    protocol    = "udp"
    self        = "false"
    to_port     = "4789"
  }

  ingress {
    cidr_blocks = ["10.1.0.0/16"]
    from_port   = "7946"
    protocol    = "tcp"
    self        = "false"
    to_port     = "7946"
  }

  ingress {
    cidr_blocks = ["10.1.0.0/16"]
    from_port   = "7946"
    protocol    = "udp"
    self        = "false"
    to_port     = "7946"
  }

  ingress {
    from_port       = "80"
    protocol        = "tcp"
    security_groups = [aws_security_group.env-01-lb-sg.id]
    self            = "false"
    to_port         = "80"
  }

  name = "env-01-sg-swarm"

  tags = {
    Name = "env-01-sg-swarm"
  }

  vpc_id = aws_vpc.env-01-vpc.id
}

resource "aws_security_group" "env-01-db-sg" {
  description = "Created by RDS management console"

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = "0"
    protocol    = "-1"
    self        = "false"
    to_port     = "0"
  }

  ingress {
    from_port       = "5432"
    protocol        = "tcp"
    security_groups = [aws_security_group.env-01-sg-swarm.id]
    self            = "false"
    to_port         = "5432"
  }

  name = "env-01-db-sg"

  tags = {
    Name = "env-01-db-sg"
  }

  vpc_id = aws_vpc.env-01-vpc.id
}
