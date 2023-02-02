resource "aws_rds_cluster" "main" {
  cluster_identifier      = "roboshop-${var.env}-rds"
  engine                  = "aurora-mysql"
  engine_version          = var.rds_engine_version
  database_name           = "dummy"
  master_username         = local.username
  master_password         = local.password
#  backup_retention_period = 5
#  preferred_backup_window = "07:00-09:00"
  db_subnet_group_name = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  skip_final_snapshot    = true

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
  name       = "roboshop-${var.env}-db-grp"
  subnet_ids = var.db_subnet_ids
  tags = {
    Name = "roboshop-${var.env}-RDS-Db-SBgrp"
  }
}

#resource "aws_db_parameter_group" "default" {
#  name   = "roboshop-${var.env}-db-param-grp"
#  family = "mysql5.7"
#
##  parameter {
##    name  = "character_set_server"
##    value = "utf8"
##  }
##
##  parameter {
##    name  = "character_set_client"
##    value = "utf8"
##  }
#}

resource "aws_security_group" "rds" {
  name        = "roboshop-${var.env}-rds"
  description = "roboshop-${var.env}-rds"
  vpc_id      = var.vpc_id

  ingress {
    description      = "rds-mysql"
    from_port        = 3306
    to_port          = 3306
    protocol         = "tcp"
    cidr_blocks      = [var.vpc_cidr_block,var.WORKSTATION_IP]

  }


  tags = {
    Name = "Roboshop-${var.env}-rds"
  }
}

resource "null_resource" "mysql_schema_apply" {
  provisioner "local-exec" {
    command = <<EOF
curl -s -L -o /tmp/mysql.zip "https://github.com/roboshop-devops-project/mysql/archive/main.zip"
cd /tmp
unzip mysql.zip
cd mysql-main
mysql -h ${aws_rds_cluster.main.enable_http_endpoint} -u ${local.username} -p${local.password} <shipping.sql
EOF

  }
}