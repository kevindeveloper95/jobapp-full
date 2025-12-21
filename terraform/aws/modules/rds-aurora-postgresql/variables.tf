variable "project_name" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "database_name" {
  description = "Name of the database to create"
  type        = string
  default     = "jobber-auth-postgres"
}

variable "master_username" {
  description = "Master username for the database"
  type        = string
  default     = "jobberadmin"
}

variable "master_password" {
  description = "Master password for the database"
  type        = string
  sensitive   = true  # ⚠️ Marca como sensible
}

variable "instance_class" {
  description = "Instance class for RDS PostgreSQL (e.g., db.t3.micro)"
  type        = string
  default     = "db.t3.micro"
}

variable "allocated_storage" {
  description = "Allocated storage in GB"
  type        = number
  default     = 20
}

variable "db_subnet_group_name" {
  description = "Name of the DB subnet group"
  type        = string
}

variable "postgres_security_group_id" {
  description = "ID of the PostgreSQL security group"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}