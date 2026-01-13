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

variable "service_account_namespace" {
  description = "Kubernetes namespace where Load Balancer Controller Service Account will be created"
  type        = string
  default     = "kube-system"
}

variable "service_account_name" {
  description = "Name of the Load Balancer Controller Service Account in Kubernetes"
  type        = string
  default     = "aws-load-balancer-controller"
}