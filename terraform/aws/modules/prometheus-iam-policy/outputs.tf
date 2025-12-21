# IAM Policy Outputs
output "prometheus_ebs_policy_id" {
  description = "ID of the Prometheus EBS IAM policy"
  value       = aws_iam_policy.prometheus_ebs.id
}

output "prometheus_ebs_policy_arn" {
  description = "ARN of the Prometheus EBS IAM policy"
  value       = aws_iam_policy.prometheus_ebs.arn
}

# IAM Role Outputs (para usar en el Service Account de Kubernetes)
output "prometheus_role_arn" {
  description = "ARN of the IAM role for Prometheus (use this in Service Account annotation)"
  value       = aws_iam_role.prometheus.arn
}

output "prometheus_role_name" {
  description = "Name of the IAM role for Prometheus"
  value       = aws_iam_role.prometheus.name
}

# Información útil para el Service Account
output "service_account_annotation" {
  description = "Annotation to add to Prometheus Service Account in Kubernetes"
  value       = "eks.amazonaws.com/role-arn: ${aws_iam_role.prometheus.arn}"
}

output "service_account_namespace" {
  description = "Kubernetes namespace where the Service Account should be created"
  value       = var.prometheus_namespace
}

output "service_account_name" {
  description = "Name of the Service Account in Kubernetes"
  value       = var.prometheus_service_account
}