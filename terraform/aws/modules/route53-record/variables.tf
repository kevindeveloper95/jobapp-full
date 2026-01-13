variable "hosted_zone_id" {
  description = "ID of the Route 53 hosted zone"
  type        = string
}

variable "record_name" {
  description = "Name of the DNS record (e.g., kevmendeveloper.com, www.kevmendeveloper.com)"
  type        = string
}

variable "record_type" {
  description = "Type of DNS record (A, AAAA, CNAME, etc.)"
  type        = string
  default     = "A"
}

variable "alias_target" {
  description = "Alias target configuration (for ALB, CloudFront, etc.)"
  type = object({
    name                   = string
    zone_id                = string
    evaluate_target_health = bool
  })
  default = null
}

variable "records" {
  description = "List of record values (for non-alias records)"
  type        = list(string)
  default     = null
}

variable "ttl" {
  description = "TTL (Time To Live) for the record in seconds"
  type        = number
  default     = 300
}

variable "comment" {
  description = "Comment for the record"
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}