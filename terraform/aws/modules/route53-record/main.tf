# Route 53 Record
resource "aws_route53_record" "main" {
  zone_id = var.hosted_zone_id
  name    = var.record_name
  type    = var.record_type  # A, AAAA, CNAME, etc.

  # Si es un alias (para ALB, CloudFront, etc.)
  dynamic "alias" {
    for_each = var.alias_target != null ? [1] : []
    content {
      name                   = var.alias_target.name
      zone_id                = var.alias_target.zone_id
      evaluate_target_health = var.alias_target.evaluate_target_health
    }
  }

  # Si son valores simples (IPs, CNAME, etc.)
  records = var.records != null ? var.records : null

  ttl     = var.ttl
  comment = var.comment

  tags = merge(
    var.tags,
    {
      Name = var.record_name
      Type = var.record_type
    }
  )
}