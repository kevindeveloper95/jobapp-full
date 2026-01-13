# ============================================================================
# IAM POLICY FOR EXTERNAL DNS
# ============================================================================
# Esta política permite que External DNS gestione registros DNS en Route 53
# Permite crear, actualizar y eliminar registros DNS automáticamente
# ============================================================================
resource "aws_iam_policy" "external_dns" {
  name        = "${var.project_name}-allow-external-dns-policy-${var.environment}"
  description = "IAM policy for External DNS to manage Route 53 DNS records"
  
  # Política para External DNS - Permisos para Route 53
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "route53:ChangeResourceRecordSets"
        ]
        Resource = [
          "arn:aws:route53:::hostedzone/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "route53:ListHostedZones",
          "route53:ListResourceRecordSets",
          "route53:ListTagsForResource"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "route53:GetChange"
        ]
        Resource = "arn:aws:route53:::change/*"
      }
    ]
  })

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-allow-external-dns-policy-${var.environment}"
      Purpose = "External-DNS"
    }
  )
}

# ============================================================================
# IAM ROLE FOR EXTERNAL DNS (IRSA)
# ============================================================================
# Este rol permite que el Service Account de External DNS
# asuma permisos de AWS sin necesidad de credenciales hardcodeadas
# ============================================================================
resource "aws_iam_role" "external_dns" {
  name = "${var.project_name}-allow-external-dns-role-${var.environment}"

  # Trust Policy: Define quién puede asumir este rol
  # Permite múltiples Service Accounts usar el mismo role
  # Crea un statement por cada Service Account
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      for sa in var.service_accounts : {
        Effect = "Allow"
        Principal = {
          Federated = var.oidc_provider_arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${replace(var.oidc_issuer_url, "https://", "")}:sub" = "system:serviceaccount:${sa.namespace}:${sa.name}"
            "${replace(var.oidc_issuer_url, "https://", "")}:aud"   = "sts.amazonaws.com"
          }
        }
      }
    ]
  })

  tags = merge(
    var.tags,
    {
      Name    = "${var.project_name}-allow-external-dns-role-${var.environment}"
      Purpose = "External-DNS-IRSA"
    }
  )
}

# ============================================================================
# ATTACH POLICY TO ROLE
# ============================================================================
resource "aws_iam_role_policy_attachment" "external_dns" {
  role       = aws_iam_role.external_dns.name
  policy_arn = aws_iam_policy.external_dns.arn
}

