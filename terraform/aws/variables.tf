# Variable definitions for JobApp Terraform configuration

variable "aws_region" {
  description = "AWS region where resources will be created"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "jobapp"
}

variable "environment" {
  description = "Environment name (dev, staging, production)"
  type        = string
  default     = "production"

  validation {
    condition     = contains(["dev", "staging", "production"], var.environment)
    error_message = "Environment must be one of: dev, staging, production"
  }
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

# RDS MySQL Variables
variable "rds_mysql_database_name" {
  description = "Name of the MySQL database"
  type        = string
  default     = "jobber-auth"
}

variable "rds_mysql_username" {
  description = "Master username for MySQL database"
  type        = string
  default     = "jobberadmin"
}

variable "rds_mysql_password" {
  description = "Master password for MySQL database (use environment variables or AWS Secrets Manager in production)"
  type        = string
  sensitive   = true # Marks this variable as sensitive (hidden in logs)
}

variable "rds_mysql_instance_class" {
  description = "Instance class for RDS MySQL (e.g., db.t3.micro)"
  type        = string
  default     = "db.t3.micro"
}

variable "rds_mysql_allocated_storage" {
  description = "Allocated storage in GB for RDS MySQL"
  type        = number
  default     = 20
}

# RDS PostgreSQL Variables
variable "rds_postgres_database_name" {
  description = "Name of the PostgreSQL database"
  type        = string
  default     = "jobber-auth-postgres"
}

variable "rds_postgres_username" {
  description = "Master username for PostgreSQL database"
  type        = string
  default     = "jobberadmin"
}

variable "rds_postgres_password" {
  description = "Master password for PostgreSQL database (use environment variables or AWS Secrets Manager in production)"
  type        = string
  sensitive   = true # Marks this variable as sensitive (hidden in logs)
}

variable "rds_postgres_instance_class" {
  description = "Instance class for RDS PostgreSQL (e.g., db.t3.micro)"
  type        = string
  default     = "db.t3.micro"
}

variable "rds_postgres_allocated_storage" {
  description = "Allocated storage in GB for RDS PostgreSQL"
  type        = number
  default     = 20
}

variable "ec2_public_key" {
  description = "Public key content for EC2 instances (content of .pub file)"
  type        = string
  sensitive   = true  # Opcional: marca como sensible
}

# EKS Variables
variable "eks_cluster_version" {
  description = "Kubernetes version for the EKS cluster"
  type        = string
  default     = "1.28"
}

variable "eks_cluster_name" {
  description = "Name of the EKS cluster (if not provided, will be auto-generated)"
  type        = string
  default     = ""
}

variable "eks_node_groups" {
  description = "Map of EKS node group configurations"
  type = map(object({
    instance_types = list(string)
    capacity_type  = string # ON_DEMAND or SPOT
    min_size       = number
    max_size       = number
    desired_size   = number
    disk_size      = number
    labels         = map(string)
    taints = list(object({
      key    = string
      value  = string
      effect = string
    }))
  }))
  default = {}
}

# ElastiCache Redis Variables
variable "redis_node_type" {
  description = "Instance type for ElastiCache Redis (e.g., cache.t3.micro, cache.t3.small)"
  type        = string
  default     = "cache.t3.small"
}

variable "redis_engine_version" {
  description = "Redis engine version (e.g., 7.0, 6.2)"
  type        = string
  default     = "7.0"
}

variable "redis_num_cache_clusters" {
  description = "Number of cache clusters (nodes) in the replication group (1-6)"
  type        = number
  default     = 2
}

variable "redis_automatic_failover_enabled" {
  description = "Enable automatic failover for high availability"
  type        = bool
  default     = true
}

variable "redis_multi_az_enabled" {
  description = "Enable Multi-AZ for high availability"
  type        = bool
  default     = true
}

variable "redis_snapshot_retention_limit" {
  description = "Number of days to retain automatic snapshots (0-35)"
  type        = number
  default     = 7
}

variable "redis_snapshot_window" {
  description = "Daily time range for snapshots (e.g., 03:00-05:00)"
  type        = string
  default     = "03:00-05:00"
}

# Route 53 Variables
variable "domain_name" {
  description = "Domain name for Route 53 hosted zone (e.g., kevmendeveloper.com)"
  type        = string
  default     = "kevmendeveloper.com"
}

variable "jobberapp_subdomain" {
  description = "Subdomain for jobberapp (e.g., jobberapp.kevmendeveloper.com)"
  type        = string
  default     = "jobberapp.kevmendeveloper.com"
}

variable "api_subdomain" {
  description = "Subdomain for API (e.g., api.jobberapp.kevmendeveloper.com)"
  type        = string
  default     = "api.jobberapp.kevmendeveloper.com"
}

variable "main_hosted_zone_id" {
  description = "ID of the main Route 53 hosted zone (kevmendeveloper.com) - created manually"
  type        = string
}

# Route 53 ALB Variables (para cuando crees los Load Balancers)
variable "main_alb_dns_name" {
  description = "DNS name of the main ALB (e.g., dualstack.jobber-frontend-1234567890.us-east-1.elb.amazonaws.com)"
  type        = string
  default     = null
}

variable "main_alb_zone_id" {
  description = "Zone ID of the main ALB (e.g., Z35SXDOTRQ7X7K)"
  type        = string
  default     = null
}

variable "www_alb_dns_name" {
  description = "DNS name of the www ALB (optional, if different from main ALB)"
  type        = string
  default     = null
}

variable "www_alb_zone_id" {
  description = "Zone ID of the www ALB (optional, if different from main ALB)"
  type        = string
  default     = null
}