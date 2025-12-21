variable "project_name" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "public_key" {
  description = "Public key content (content of .pub file, not the file path)"
  type        = string
  sensitive   = true  # Opcional: marca como sensible
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}