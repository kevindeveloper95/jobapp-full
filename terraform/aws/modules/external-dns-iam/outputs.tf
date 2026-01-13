# IAM Policy Outputs
output "external_dns_policy_id" {
  description = "ID of the External DNS IAM policy"
  value       = aws_iam_policy.external_dns.id
}

output "external_dns_policy_arn" {
  description = "ARN of the External DNS IAM policy"
  value       = aws_iam_policy.external_dns.arn
}

# IAM Role Outputs (para usar en el Service Account de Kubernetes)
output "external_dns_role_arn" {
  description = "ARN of the IAM role for External DNS (use this in Service Account annotation)"
  value       = aws_iam_role.external_dns.arn
}

output "external_dns_role_name" {
  description = "Name of the IAM role for External DNS"
  value       = aws_iam_role.external_dns.name
}

# Información útil para el Service Account
output "service_account_annotation" {
  description = "Annotation to add to External DNS Service Account in Kubernetes"
  value       = "eks.amazonaws.com/role-arn: ${aws_iam_role.external_dns.arn}"
}

output "service_accounts" {
  description = "List of Service Accounts that can use this role"
  value       = var.service_accounts
}

