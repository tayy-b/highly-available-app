
resource "aws_db_subnet_group" "postgres" {
  name = "timestamp-postgres"
 //db instance in  private subnets to prevent public access
  subnet_ids = [
    aws_subnet.private_a.id, 
    aws_subnet.private_b.id
  ]
}

resource "aws_db_instance" "postgres" {
  identifier = "timestamp-postgres-instance"

  engine         = "postgres"
  engine_version = "17"
  instance_class        = "db.t3.micro"
  allocated_storage     = 20
  storage_type          = "gp3"
  publicly_accessible   = false
  skip_final_snapshot   = true
  deletion_protection   = false
#   multi_az              = true //enable multi-AZ for high availability in prod

  db_name  = var.db_name
  username = var.db_username
  password = var.db_password

  db_subnet_group_name = aws_db_subnet_group.postgres.name
  vpc_security_group_ids = [
    aws_security_group.database.id
  ]
}