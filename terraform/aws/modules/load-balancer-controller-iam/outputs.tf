# IAM Policy Outputs
output "load_balancer_controller_policy_id" {
  description = "ID of the AWS Load Balancer Controller IAM policy"
  value       = aws_iam_policy.load_balancer_controller.id
}

output "load_balancer_controller_policy_arn" {
  description = "ARN of the AWS Load Balancer Controller IAM policy"
  value       = aws_iam_policy.load_balancer_controller.arn
}

# IAM Role Outputs (para usar en el Service Account de Kubernetes)
output "load_balancer_controller_role_arn" {
  description = "ARN of the IAM role for AWS Load Balancer Controller (use this in Service Account annotation)"
  value       = aws_iam_role.load_balancer_controller.arn
}

output "load_balancer_controller_role_name" {
  description = "Name of the IAM role for AWS Load Balancer Controller"
  value       = aws_iam_role.load_balancer_controller.name
}

# Información útil para el Service Account
output "service_account_annotation" {
  description = "Annotation to add to Load Balancer Controller Service Account in Kubernetes"
  value       = "eks.amazonaws.com/role-arn: ${aws_iam_role.load_balancer_controller.arn}"
}

output "service_account_namespace" {
  description = "Kubernetes namespace where the Service Account should be created"
  value       = var.service_account_namespace
}

output "service_account_name" {
  description = "Name of the Service Account in Kubernetes"
  value       = var.service_account_name
}