output "certificate_arn" {
  description = "ARN of the ACM certificate"
  value       = aws_acm_certificate.main.arn
}

output "certificate_domain_name" {
  description = "Domain name of the certificate"
  value       = aws_acm_certificate.main.domain_name
}

output "certificate_validation_status" {
  description = "Validation status of the certificate"
  value       = var.validate_certificate ? aws_acm_certificate_validation.main[0].id : "Not validated"
}