# Bastion host

resource "aws_instance" "env-01-vm-bas" {
  ami                         = var.ami_base_vm_debian_10
  associate_public_ip_address = "true"
  availability_zone           = "eu-west-1a"

  credit_specification {
    cpu_credits = "standard"
  }

  disable_api_termination = "false"
  ebs_optimized           = "false"
  get_password_data       = "false"
  hibernation             = "false"
  instance_type           = "t2.small"
  key_name                = var.admin_ssh_key_name # key of the devops/machine that provisions the environment (it's ssh key has access to the environment)

  metadata_options {
    http_endpoint               = "enabled"
    http_put_response_hop_limit = "1"
    http_tokens                 = "optional"
  }

  monitoring = "false"
  private_ip = "10.1.1.4"

  root_block_device {
    delete_on_termination = "true"
    encrypted             = "false" # switch to provisioned iops (3k)
    volume_size           = "30"
    volume_type           = "gp2"
  }

  source_dest_check = "true"
  subnet_id         = aws_subnet.env-01-sub-a-pub.id

  tags = {
    Name = "env-01-vm-bas"
  }

  volume_tags = {
    Name = "env-01-vm-bas-volume-1-main-partition"
  }

  tenancy                = "default"
  vpc_security_group_ids = [aws_security_group.env-01-sg-bas.id]
}

# Docker swarm VM #1 - AZ: A

resource "aws_instance" "env-01-vm-swarm-1" {
  ami                         = var.ami_base_vm_debian_10
  associate_public_ip_address = "false"
  availability_zone           = "eu-west-1a"
  disable_api_termination     = "false"
  ebs_optimized               = "true"
  get_password_data           = "false"
  hibernation                 = "false"
  instance_type               = "c5.large"       # recommended size, use t2.medium to downscale the size (and the cost :D) of the VM
  key_name                    = "id_env_bastion" # NOTE: bastion host key is used to connect, gain root access and provision the vm

  metadata_options {
    http_endpoint               = "enabled"
    http_put_response_hop_limit = "1"
    http_tokens                 = "optional"
  }

  monitoring = "false"
  private_ip = "10.1.3.4"

  root_block_device {
    delete_on_termination = "true"
    encrypted             = "false"
    volume_size           = "80"
    volume_type           = "gp2"
  }

  source_dest_check = "true"
  subnet_id         = aws_subnet.env-01-sub-a-priv.id

  tags = {
    Name = "env-01-vm-swarm-1"
  }

  volume_tags = {
    Name = "env-01-vm-swarm-1-volume-1-main-partition"
  }

  tenancy                = "default"
  vpc_security_group_ids = [aws_security_group.env-01-sg-swarm.id, aws_security_group.env-01-sg-vms.id]
}

# Docker swarm VM #2 - AZ: B

resource "aws_instance" "env-01-vm-swarm-2" {
  ami                         = var.ami_base_vm_debian_10
  associate_public_ip_address = "false"
  availability_zone           = "eu-west-1b"
  disable_api_termination     = "false"
  ebs_optimized               = "true"
  get_password_data           = "false"
  hibernation                 = "false"
  instance_type               = var.compute_ec2_vm_size
  key_name                    = "id_env_bastion"

  metadata_options {
    http_endpoint               = "enabled"
    http_put_response_hop_limit = "1"
    http_tokens                 = "optional"
  }

  monitoring = "false"
  private_ip = "10.1.4.4" # TODO: recheck

  root_block_device {
    delete_on_termination = "true"
    encrypted             = "false"
    volume_size           = "80"
    volume_type           = "gp2"
  }

  source_dest_check = "true"
  subnet_id         = aws_subnet.env-01-sub-b-priv.id

  tags = {
    Name = "env-01-vm-swarm-2"
  }

  volume_tags = {
    Name = "env-01-vm-swarm-2-volume-1-main-partition"
  }

  tenancy                = "default"
  vpc_security_group_ids = [aws_security_group.env-01-sg-swarm.id, aws_security_group.env-01-sg-vms.id]
}
