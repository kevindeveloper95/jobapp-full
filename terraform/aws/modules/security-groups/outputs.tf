# Security Groups Module Outputs

output "mysql_security_group_id" {
  description = "ID of the MySQL security group"
  value       = aws_security_group.mysql.id
}

output "postgres_security_group_id" {
  description = "ID of the PostgreSQL security group"
  value       = aws_security_group.postgres.id
}

output "redis_security_group_id" {
  description = "ID of the Redis security group"
  value       = aws_security_group.redis.id
}