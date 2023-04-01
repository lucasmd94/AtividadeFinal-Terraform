resource "aws_rds_cluster" "db_cluster" {
  cluster_identifier     = "database-${terraform.workspace == "dev" ? var.db_name.dev : (terraform.workspace == "prod" ? var.db_name.prod : var.db_name.prod)}"
  engine                 = "aurora"
  engine_version         = "5.6.mysql_aurora.1.22.4"
  database_name          = "dbadmin"
  master_username        = "masteradmin"
  master_password        = "adm0@"
  vpc_security_group_ids = var.aws_web_security_group

  serverlessv2_scaling_configuration {
    max_capacity = terraform.workspace == "prod" ? 2.0 : 0.5
    min_capacity = terraform.workspace == "prod" ? 1.0 : 0.5
  }
}

resource "aws_rds_cluster_instance" "db_cluster" {
  cluster_identifier = aws_rds_cluster.db_cluster.id
  instance_class     = "db.serverless"
  engine             = aws_rds_cluster.db_cluster.engine
  engine_version     = aws_rds_cluster.db_cluster.engine_version
}