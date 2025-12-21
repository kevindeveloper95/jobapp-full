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

variable "prometheus_namespace" {
  description = "Kubernetes namespace where Prometheus Service Account will be created"
  type        = string
  default     = "monitoring"
}

variable "prometheus_service_account" {
  description = "Name of the Prometheus Service Account in Kubernetes"
  type        = string
  default     = "prometheus"
}