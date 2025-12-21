output "db_instance_id" {
  description = "ID of the RDS PostgreSQL instance"
  value       = aws_db_instance.postgres.id
}

output "db_instance_endpoint" {
  description = "Endpoint for the RDS PostgreSQL instance"
  value       = aws_db_instance.postgres.endpoint
}

output "db_instance_address" {
  description = "Address (hostname) of the RDS PostgreSQL instance"
  value       = aws_db_instance.postgres.address
}

output "db_instance_port" {
  description = "Port for the RDS PostgreSQL instance"
  value       = aws_db_instance.postgres.port
}

output "database_name" {
  description = "Name of the database"
  value       = aws_db_instance.postgres.db_name
}

output "db_instance_arn" {
  description = "ARN of the RDS PostgreSQL instance"
  value       = aws_db_instance.postgres.arn
}