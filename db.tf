resource "aws_db_instance" "env-01-db-1" {

  # database configuration

  name     = "db_1"
  username = "postgres"
  password = "antani123" # TODO: replace DB password with a secure one

  # infrastructure configuration

  identifier                          = "env-01-db-1"
  multi_az                            = "true"
  publicly_accessible                 = "false"
  db_subnet_group_name                = aws_db_subnet_group.env-01-db-subnet-group.name
  vpc_security_group_ids              = [aws_security_group.env-01-db-sg.id]
  instance_class                      = "db.t3.small" # c5.large to scale up production
  allocated_storage                   = "30"          # generic ssd option - use 100GB / 1TB to scale up i/o # I know it's silly as your snapshots will take more time, that's how aws is - for proper scaling convert to provisioned iops (above 100GB or with very high traffic)
  storage_encrypted                   = "true"
  engine                              = "postgres"
  engine_version                      = "12.4"
  backup_retention_period             = "7"
  backup_window                       = "01:00-01:30"
  copy_tags_to_snapshot               = "true"
  auto_minor_version_upgrade          = "true"
  maintenance_window                  = "tue:02:00-tue:02:30"
  ca_cert_identifier                  = "rds-ca-2019"
  storage_type                        = "gp2"
  deletion_protection                 = "false"
  iam_database_authentication_enabled = "false"
  license_model                       = "postgresql-license"
  max_allocated_storage               = "0"
  option_group_name                   = "default:postgres-12"
  parameter_group_name                = "default.postgres12"
  performance_insights_enabled        = "false"
  port                                = "5432"
  final_snapshot_identifier           = "deleteme1"
  # skip_final_snapshot                 = true

  # iops                              = "4000" # enable this for provisiond iops ssds (4k is ~200 per month)

  # security:
  #
  # kms_key_id                            = "arn:aws:kms:eu-west-1:xxxxxxxxxxxxxxxxxx"

  # optional:
  #
  # monitoring_interval                   = "60"
  # monitoring_role_arn                   = "arn:aws:iam::379937780633:role/rds-monitoring-role"
  # performance_insights_enabled          = "true"
  # performance_insights_kms_key_id       = "arn:aws:kms:eu-west-1:xxxxxxxxxxxxxxxxxx"
  # performance_insights_retention_period = "7"
}

resource "aws_db_subnet_group" "env-01-db-subnet-group" {
  name        = "env-01-db-subnet-group"
  description = "DB subnet group (private subnets) - provisioned via terraform"
  subnet_ids = [
    aws_subnet.env-01-sub-a-priv.id,
    aws_subnet.env-01-sub-b-priv.id,
  ]
}
