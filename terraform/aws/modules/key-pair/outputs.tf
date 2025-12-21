output "key_name" {
  description = "Name of the AWS Key Pair"
  value       = aws_key_pair.main.key_name
}

output "key_pair_id" {
  description = "ID of the AWS Key Pair"
  value       = aws_key_pair.main.id
}