# ------------------------------
# Database Configuration
# ------------------------------

resource "aws_db_instance" "postgres" {
  identifier              = "${local.prefix}-db"
  db_name                 = "postgres"
  allocated_storage       = 20
  storage_type            = "gp2"
  engine                  = "postgres"
  engine_version          = "16.3"
  instance_class          = "db.t3.micro"
  password                = var.db_password
  username                = var.db_username
  backup_retention_period = 0
  multi_az                = false
  skip_final_snapshot     = true

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-main" })
  )
}

output "db_instance_endpoint" {
  description = "The connection endpoint"
  value       = try(aws_db_instance.postgres.endpoint, null)
}
