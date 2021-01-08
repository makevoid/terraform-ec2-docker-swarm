output "elb_hostname" {
  value = aws_lb.env-01-elb-app.dns_name
}

output "bastion_public_ip" {
  value = aws_instance.env-01-vm-bas.public_ip
}

output "db_hostname" {
  value = aws_db_instance.env-01-db-1.address
}
# TODO: run dnsimple to configure env-01-db.abdev.run cname

output "db_database_name" {
  value = aws_db_instance.env-01-db-1.name
}

resource "local_file" "elb_hostname_output" {
  content  = aws_lb.env-01-elb-app.dns_name
  filename = "output_elb_hostname.txt"
}

resource "local_file" "bastion_public_ip_output" {
  content  = aws_instance.env-01-vm-bas.public_ip
  filename = "output_bastion_public_ip.txt"
}

resource "local_file" "db_hostname_output" {
  content  = aws_db_instance.env-01-db-1.address
  filename = "output_db_hostname.txt"
}
