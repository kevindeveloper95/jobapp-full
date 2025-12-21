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

