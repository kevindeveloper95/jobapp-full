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
