locals {
  service_name = "fern"
}

resource "random_password" "database_password" {
  length           = 16
  special          = true
  override_special = "_%@"
}

resource "aws_ssm_parameter" "database_url" {
  name        = "/${local.service_name}/database/url"
  description = "Database URL for ${local.service_name} RDS instance"
  type        = "SecureString"
  value       = "postgresql://user:password@host:port/dbname" # This is a placeholder value, the actual value will be set by the module
}

resource "aws_security_group" "rds" {
  name        = "${local.service_name}-rds-db-sg"
  description = "Allow inbound traffic to RDS"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "Allow inbound traffic to RDS"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "${local.service_name}-rds-db-sg"
    Service = local.service_name
  }
}

resource "aws_db_subnet_group" "default" {
  name_prefix = "${local.service_name}-rds-db-subnet-group"
  subnet_ids  = data.aws_subnets.default.ids

  lifecycle {
    create_before_destroy = true # This is needed to avoid the error: Error: Error deleting DB Subnet Group: DBSubnetGroupInUse: The DB Subnet Group cannot be deleted because it is used by one or more DB Instances.  
  }

  tags = {
    Name = "${local.service_name}-rds-db-subnet-group"
  }
}

resource "aws_kms_key" "default" {
  description             = "KMS key/SSM"
  deletion_window_in_days = 10
  enable_key_rotation     = true

  tags = {
    Name = "${local.service_name}-db-kms-key"
  }

}

resource "aws_db_instance" "default" {
  db_name             = local.service_name
  identifier          = "${local.service_name}-rds-db-instance"
  allocated_storage   = 20
  storage_type        = "gp3"
  engine              = "postgres"
  engine_version      = "17.2"
  instance_class      = "db.t3.micro"
  username            = "fern_admin"
  password            = random_password.database_password.result
  skip_final_snapshot = true
  storage_encrypted   = true # Needed for RDS to use the KMS key at rest

  publicly_accessible    = true
  vpc_security_group_ids = [aws_security_group.rds.id]
  db_subnet_group_name   = aws_db_subnet_group.default.name

  kms_key_id = aws_kms_key.default.arn

  tags = {
    Name = "${local.service_name}-rds-db-instance"
  }
}