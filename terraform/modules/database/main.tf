# Create a security group for the RDS instance
resource "aws_security_group" "db" {
  name        = "secondbrain-${var.environment}-db-sg"
  description = "Security group for RDS database"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = var.db_port
    to_port         = var.db_port
    protocol        = "tcp"
    security_groups = [var.api_security_group_id]
    description     = "Allow database access from API servers"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name = "secondbrain-${var.environment}-db-sg"
  }
}

# Create a DB subnet group
resource "aws_db_subnet_group" "main" {
  name       = "secondbrain-${var.environment}-db-subnet-group"
  subnet_ids = var.subnet_ids

  tags = {
    Name = "secondbrain-${var.environment}-db-subnet-group"
  }
}

# Create the RDS PostgreSQL instance
resource "aws_db_instance" "main" {
  identifier              = "secondbrain-${var.environment}"
  engine                  = "postgres"
  engine_version          = "14"
  instance_class          = var.instance_type
  allocated_storage       = 20
  max_allocated_storage   = 100
  storage_type            = "gp2"
  name                    = var.db_name
  username                = var.db_username
  password                = var.db_password
  port                    = var.db_port
  publicly_accessible     = false
  vpc_security_group_ids  = [aws_security_group.db.id]
  db_subnet_group_name    = aws_db_subnet_group.main.name
  parameter_group_name    = "default.postgres14"
  backup_retention_period = var.environment == "production" ? 7 : 1
  skip_final_snapshot     = var.environment != "production"
  deletion_protection     = var.environment == "production"
  
  # Enable storage encryption for production
  storage_encrypted = var.environment == "production"

  # Enable automated backups for production
  backup_window = "03:00-04:00" # UTC

  # Maintenance window
  maintenance_window = "Mon:04:00-Mon:05:00" # UTC

  tags = {
    Name = "secondbrain-${var.environment}-db"
  }
} 