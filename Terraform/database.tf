# VPCの作成
resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
}

# サブネットの作成
resource "aws_subnet" "my_subnet1" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "ap-northeast-1a"
}

# サブネットの作成
resource "aws_subnet" "my_subnet2" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "ap-northeast-1c"
}

resource "aws_security_group" "rds_sg" {
  vpc_id      = aws_vpc.my_vpc.id
  name        = "${local.prefix}-rds-sg"
  description = "Allow PostgreSQL access"

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # すべてのトラフィックを許可
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-rds-sg" })
  )
}

# RDS用のサブネットグループを作成
resource "aws_db_subnet_group" "my_db_subnet_group" {
  name       = "${local.prefix}-db-subnet-group"
  subnet_ids = [aws_subnet.my_subnet1.id, aws_subnet.my_subnet2.id]

  tags = {
    Name = "My DB Subnet Group"
  }
}

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

  db_subnet_group_name   = aws_db_subnet_group.my_db_subnet_group.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-main" })
  )
}

output "db_instance_endpoint" {
  description = "The connection endpoint"
  value       = try(aws_db_instance.postgres.endpoint, null)
}
