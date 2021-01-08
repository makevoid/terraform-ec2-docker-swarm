resource "aws_eip" "env-01-eip-bastion" {
  network_border_group = var.region
  public_ipv4_pool     = "amazon"
  vpc                  = "true"

  tags = {
    Name = "env-01-eip-bastion"
  }

  # TODO: flag to enable this in production
  #
  # lifecycle {
  #   prevent_destroy = true
  # }
}

resource "aws_eip_association" "env-01-eip-bastion-ip-assoc" {
  instance_id   = aws_instance.env-01-vm-bas.id
  allocation_id = aws_eip.env-01-eip-bastion.id
}

resource "aws_eip" "env-01-nat-gw-a-eip" {
  network_border_group = var.region
  public_ipv4_pool     = "amazon"
  vpc                  = "true"

  tags = {
    Name = "env-01-nat-gw-a-eip"
  }
}

resource "aws_eip" "env-01-nat-gw-b-eip" {
  network_border_group = var.region
  public_ipv4_pool     = "amazon"
  vpc                  = "true"

  tags = {
    Name = "env-01-nat-gw-b-eip"
  }
}
