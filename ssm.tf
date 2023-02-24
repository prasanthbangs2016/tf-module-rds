resource "aws_ssm_parameter" "mysql" {
  name  = "mutable.rds.${var.env}.DB_HOST"
  type  = "String"
  value = aws_rds_cluster.main.endpoint

}