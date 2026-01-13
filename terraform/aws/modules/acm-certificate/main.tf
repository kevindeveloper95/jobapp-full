# ACM Certificate
resource "aws_acm_certificate" "main" {
  domain_name       = var.domain_name
  validation_method = "DNS"  # Validación por DNS (automática con Route 53)

  # Si quieres incluir subdominios (wildcard)
  subject_alternative_names = var.subject_alternative_names

  # Opciones del certificado
  options {
    certificate_transparency_logging_preference = var.certificate_transparency_logging ? "ENABLED" : "DISABLED"
  }

  # Tags
  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-cert-${var.environment}"
      Domain = var.domain_name
    }
  )

  # Esperar a que se valide (opcional, puede tomar tiempo)
  lifecycle {
    create_before_destroy = true
  }
}

# Validación automática del certificado usando Route 53
resource "aws_acm_certificate_validation" "main" {
  count = var.validate_certificate ? 1 : 0

  certificate_arn = aws_acm_certificate.main.arn

  # Validación automática usando Route 53
  validation_record_fqdns = [
    for record in aws_route53_record.cert_validation : record.fqdn
  ]

  timeouts {
    create = "5m"
  }
}

# Registros DNS para validación (automático)
resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.main.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = var.hosted_zone_id
}