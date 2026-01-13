# Route 53 Hosted Zone
resource "aws_route53_zone" "main" {
  name = var.domain_name  # Ej: "kevmendeveloper.com"
  
  # Comentario para identificar la zona
  comment = "Hosted zone for ${var.domain_name}"
  
  # Tags
  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-hosted-zone-${var.environment}"
      Domain = var.domain_name
    }
  )
}