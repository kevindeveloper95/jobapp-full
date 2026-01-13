variable "project_name" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "domain_name" {
  description = "Domain name for the certificate (e.g., jobberapp.kevmendeveloper.com)"
  type        = string
}

variable "hosted_zone_id" {
  description = "ID of the Route 53 hosted zone for DNS validation"
  type        = string
}

variable "subject_alternative_names" {
  description = "List of subject alternative names (SANs) for the certificate (e.g., ['*.jobberapp.kevmendeveloper.com'])"
  type        = list(string)
  default     = []
}

variable "validate_certificate" {
  description = "Whether to automatically validate the certificate using Route 53"
  type        = bool
  default     = true
}

variable "certificate_transparency_logging" {
  description = "Enable certificate transparency logging"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}