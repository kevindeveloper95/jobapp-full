variable "project_name" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "subnet_group_name" {
  description = "Name of the ElastiCache subnet group"
  type        = string
}

variable "redis_security_group_id" {
  description = "ID of the Redis security group"
  type        = string
}

variable "node_type" {
  description = "Instance type for ElastiCache Redis (e.g., cache.t3.micro, cache.t3.small)"
  type        = string
  default     = "cache.t3.small"
}

variable "engine_version" {
  description = "Redis engine version (e.g., 7.0, 6.2)"
  type        = string
  default     = "7.0"
}

variable "num_cache_clusters" {
  description = "Number of cache clusters (nodes) in the replication group (1-6)"
  type        = number
  default     = 2
}

variable "automatic_failover_enabled" {
  description = "Enable automatic failover for high availability"
  type        = bool
  default     = true
}

variable "multi_az_enabled" {
  description = "Enable Multi-AZ for high availability"
  type        = bool
  default     = true
}

variable "snapshot_retention_limit" {
  description = "Number of days to retain automatic snapshots (0-35)"
  type        = number
  default     = 7
}

variable "snapshot_window" {
  description = "Daily time range for snapshots (e.g., 03:00-05:00)"
  type        = string
  default     = "03:00-05:00"
}

variable "final_snapshot_identifier" {
  description = "Name of the final snapshot before deletion (optional)"
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}