# ============================================================================
# EKS MODULE OUTPUTS
# ============================================================================
# Estos outputs permiten que otros módulos o el root accedan a información
# del cluster después de que se cree
# ============================================================================

# Información del Cluster
output "cluster_id" {
  description = "ID of the EKS cluster"
  value       = aws_eks_cluster.main.id
}

output "cluster_arn" {
  description = "ARN of the EKS cluster"
  value       = aws_eks_cluster.main.arn
}

output "cluster_name" {
  description = "Name of the EKS cluster"
  value       = aws_eks_cluster.main.name
}

output "cluster_endpoint" {
  description = "Endpoint URL for the EKS cluster API server"
  value       = aws_eks_cluster.main.endpoint
}

output "cluster_version" {
  description = "Kubernetes version of the EKS cluster"
  value       = aws_eks_cluster.main.version
}

output "cluster_security_group_id" {
  description = "Security group ID attached to the EKS cluster"
  value       = aws_security_group.cluster.id
}

output "cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data required to communicate with the cluster"
  value       = aws_eks_cluster.main.certificate_authority[0].data
  sensitive   = true # Marca como sensible porque contiene certificados
}

output "cluster_oidc_issuer_url" {
  description = "URL of the OIDC identity provider (for IRSA - IAM Roles for Service Accounts)"
  value       = aws_eks_cluster.main.identity[0].oidc[0].issuer
}

output "cluster_oidc_provider_arn" {
  description = "ARN of the OIDC identity provider (for IRSA - IAM Roles for Service Accounts)"
  value       = aws_iam_openid_connect_provider.eks.arn
}

# Información de los Node Groups
output "node_group_ids" {
  description = "Map of node group names to their IDs"
  value = {
    for k, v in aws_eks_node_group.main : k => v.id
  }
}

output "node_group_arns" {
  description = "Map of node group names to their ARNs"
  value = {
    for k, v in aws_eks_node_group.main : k => v.arn
  }
}

output "node_group_status" {
  description = "Map of node group names to their status"
  value = {
    for k, v in aws_eks_node_group.main : k => v.status
  }
}

# IAM Roles
output "cluster_iam_role_arn" {
  description = "ARN of the IAM role used by the EKS cluster"
  value       = aws_iam_role.cluster.arn
}

output "node_iam_role_arn" {
  description = "ARN of the IAM role used by the EKS nodes"
  value       = aws_iam_role.nodes.arn
}

# Security Groups
output "node_security_group_id" {
  description = "Security group ID attached to the EKS nodes"
  value       = aws_security_group.nodes.id
}

# Comando para configurar kubectl (útil para documentación)
# Nota: La región se obtiene del provider, no necesitamos data source aquí
output "kubectl_config_command" {
  description = "Command to configure kubectl to connect to this cluster (update region manually)"
  value       = "aws eks update-kubeconfig --region <REGION> --name ${aws_eks_cluster.main.name}"
}

