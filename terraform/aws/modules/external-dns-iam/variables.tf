variable "project_name" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

# Variables para IRSA (IAM Roles for Service Accounts)
variable "oidc_provider_arn" {
  description = "ARN of the OIDC Provider from EKS module (for IRSA)"
  type        = string
}

variable "oidc_issuer_url" {
  description = "URL of the OIDC issuer from EKS cluster (for IRSA)"
  type        = string
}

variable "service_accounts" {
  description = "List of Service Accounts that can assume this role. Format: namespace:service-account-name"
  type = list(object({
    namespace = string
    name      = string
  }))
  default = [
    {
      namespace = "production"
      name      = "frontend-external-dns"
    }
  ]
}

