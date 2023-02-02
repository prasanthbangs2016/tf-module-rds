resource "aws_rds_cluster" "main" {
  cluster_identifier      = "roboshop-${var.env}-rds"
  engine                  = "mysql"
  engine_version          = var.rds_engine_version
  availability_zones      = ["us-west-2a", "us-west-2b", "us-west-2c"]
  database_name           = "dummy"
  master_username         = local.username
  master_password         = local.password
  backup_retention_period = 5
  preferred_backup_window = "07:00-09:00"
}

resource "aws_rds_cluster_instance" "cluster_instances" {
  count              = var.rds_cluster_instance_count
  identifier         = "${var.env}-rds-${count.index}"
  cluster_identifier = aws_rds_cluster.main.id
  instance_class     = var.rds_instance_class
  engine             = aws_rds_cluster.main.engine
  engine_version     = aws_rds_cluster.main.engine_version
}

resource "aws_db_subnet_group" "main" {
  name       = "Roboshop-${var.env}-db-grp"
  subnet_ids = var.db_subnet_ids
  tags = {
    Name = "Roboshop-${var.env}-RDS-Db-SBgrp"
  }
}

resource "aws_db_parameter_group" "default" {
  name   = "Roboshop-${var.env}-db-param-grp"
  family = "mysql5.7"

#  parameter {
#    name  = "character_set_server"
#    value = "utf8"
#  }
#
#  parameter {
#    name  = "character_set_client"
#    value = "utf8"
#  }
}

resource "aws_security_group" "rds" {
  name        = "roboshop-${var.env}-rds"
  description = "roboshop-${var.env}-rds"
  vpc_id      = var.vpc_id

  ingress {
    description      = "rds-mysql"
    from_port        = 3306
    to_port          = 3306
    protocol         = "tcp"
    cidr_blocks      = [var.vpc_cidr_block]

  }


  tags = {
    Name = "Roboshop-${var.env}-rds"
  }
}