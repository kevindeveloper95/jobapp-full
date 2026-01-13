# Output values for JobApp Terraform configuration

output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "vpc_cidr_block" {
  description = "CIDR block of the VPC"
  value       = module.vpc.vpc_cidr_block
}

output "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  value       = module.vpc.internet_gateway_id
}

output "mysql_security_group_id" {
  description = "ID of the MySQL security group"
  value       = module.security_groups.mysql_security_group_id
}

output "postgres_security_group_id" {
  description = "ID of the PostgreSQL security group"
  value       = module.security_groups.postgres_security_group_id
}

output "redis_security_group_id" {
  description = "ID of the Redis security group"
  value       = module.security_groups.redis_security_group_id
}

output "db_subnet_group_id" {
  description = "ID of the DB subnet group"
  value       = module.db_subnet_group.db_subnet_group_id
}

output "db_subnet_group_name" {
  description = "Name of the DB subnet group"
  value       = module.db_subnet_group.db_subnet_group_name
}

output "prometheus_ebs_policy_arn" {
  description = "ARN of the Prometheus EBS IAM policy"
  value       = module.prometheus_iam_policy.prometheus_ebs_policy_arn
}

output "mysql_endpoint" {
  description = "RDS MySQL endpoint"
  value       = module.rds_mysql.db_instance_endpoint
}

output "mysql_port" {
  description = "RDS MySQL port"
  value       = module.rds_mysql.db_instance_port
}

output "postgres_endpoint" {
  description = "RDS PostgreSQL endpoint"
  value       = module.rds_postgres.db_instance_endpoint
}

output "postgres_port" {
  description = "RDS PostgreSQL port"
  value       = module.rds_postgres.db_instance_port
}

output "key_pair_name" {
  description = "Name of the EC2 Key Pair"
  value       = module.key_pair.key_name
}

output "elasticache_subnet_group_name" {
  description = "Name of the ElastiCache subnet group"
  value       = module.elasticache_subnet_group.elasticache_subnet_group_name
}

output "elasticache_subnet_group_id" {
  description = "ID of the ElastiCache subnet group"
  value       = module.elasticache_subnet_group.elasticache_subnet_group_id
}

# ElastiCache Redis Outputs
output "redis_endpoint" {
  description = "Primary endpoint (address) for the Redis cluster"
  value       = module.elasticache_redis.redis_endpoint
}

output "redis_primary_endpoint" {
  description = "Primary endpoint address for the Redis cluster"
  value       = module.elasticache_redis.redis_primary_endpoint
}

output "redis_reader_endpoint" {
  description = "Reader endpoint address for the Redis cluster (for read replicas)"
  value       = module.elasticache_redis.redis_reader_endpoint
}

output "redis_port" {
  description = "Port number for Redis (default: 6379)"
  value       = module.elasticache_redis.redis_port
}

output "redis_arn" {
  description = "ARN of the ElastiCache Redis replication group"
  value       = module.elasticache_redis.redis_arn
}

# Route 53 Outputs
# ⚠️ COMENTADO: El Hosted Zone principal fue creado manualmente, estos outputs no están disponibles
# Si importas el recurso a Terraform, descomenta estos outputs
# output "hosted_zone_id" {
#   description = "ID of the Route 53 hosted zone"
#   value       = module.route53_hosted_zone.hosted_zone_id
# }
# 
# output "hosted_zone_name_servers" {
#   description = "Name servers for the hosted zone (configure these in your domain registrar)"
#   value       = module.route53_hosted_zone.hosted_zone_name_servers
# }

# Route 53 Outputs para Subdominios
output "jobberapp_hosted_zone_id" {
  description = "ID of the Route 53 hosted zone for jobberapp.kevmendeveloper.com"
  value       = module.route53_hosted_zone_jobberapp.hosted_zone_id
}

output "jobberapp_hosted_zone_name_servers" {
  description = "Name servers for jobberapp.kevmendeveloper.com (configure these in the parent hosted zone)"
  value       = module.route53_hosted_zone_jobberapp.hosted_zone_name_servers
}

output "api_hosted_zone_id" {
  description = "ID of the Route 53 hosted zone for api.jobberapp.kevmendeveloper.com"
  value       = module.route53_hosted_zone_api.hosted_zone_id
}

output "api_hosted_zone_name_servers" {
  description = "Name servers for api.jobberapp.kevmendeveloper.com (configure these in the parent hosted zone)"
  value       = module.route53_hosted_zone_api.hosted_zone_name_servers
}

# ACM Certificate Outputs
output "jobberapp_certificate_arn" {
  description = "ARN of the ACM certificate for jobberapp.kevmendeveloper.com"
  value       = module.acm_certificate_jobberapp.certificate_arn
}

output "api_certificate_arn" {
  description = "ARN of the ACM certificate for api.jobberapp.kevmendeveloper.com"
  value       = module.acm_certificate_api.certificate_arn
}

# AWS Load Balancer Controller IAM Outputs
output "load_balancer_controller_policy_arn" {
  description = "ARN of the AWS Load Balancer Controller IAM policy"
  value       = module.load_balancer_controller_iam_policy.load_balancer_controller_policy_arn
}

output "load_balancer_controller_role_arn" {
  description = "ARN of the IAM role for AWS Load Balancer Controller (use in Service Account annotation)"
  value       = module.load_balancer_controller_iam_policy.load_balancer_controller_role_arn
}

# External DNS IAM Outputs
output "external_dns_policy_arn" {
  description = "ARN of the External DNS IAM policy"
  value       = module.external_dns_iam_policy.external_dns_policy_arn
}

output "external_dns_role_arn" {
  description = "ARN of the IAM role for External DNS (use in Service Account annotation)"
  value       = module.external_dns_iam_policy.external_dns_role_arn
}

