output "redis_endpoint" {
  description = "Primary endpoint (address) for the Redis cluster"
  value       = aws_elasticache_replication_group.redis.configuration_endpoint_address
}

output "redis_primary_endpoint" {
  description = "Primary endpoint address for the Redis cluster"
  value       = aws_elasticache_replication_group.redis.primary_endpoint_address
}

output "redis_reader_endpoint" {
  description = "Reader endpoint address for the Redis cluster (for read replicas)"
  value       = aws_elasticache_replication_group.redis.reader_endpoint_address
}

output "redis_port" {
  description = "Port number for Redis (default: 6379)"
  value       = aws_elasticache_replication_group.redis.port
}

output "redis_arn" {
  description = "ARN of the ElastiCache Redis replication group"
  value       = aws_elasticache_replication_group.redis.arn
}

output "redis_replication_group_id" {
  description = "ID of the replication group"
  value       = aws_elasticache_replication_group.redis.replication_group_id
}

