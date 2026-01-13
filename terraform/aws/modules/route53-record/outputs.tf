output "record_fqdn" {
  description = "Fully qualified domain name of the record"
  value       = aws_route53_record.main.fqdn
}

output "record_name" {
  description = "Name of the record"
  value       = aws_route53_record.main.name
}