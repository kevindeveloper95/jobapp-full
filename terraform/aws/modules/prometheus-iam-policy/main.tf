# ============================================================================
# IAM POLICY FOR PROMETHEUS
# ============================================================================
# Define los permisos que Prometheus necesita para monitorear EBS y CloudWatch
# ============================================================================
resource "aws_iam_policy" "prometheus_ebs" {
  name        = "${var.project_name}-prometheus-ebs-policy-${var.environment}"
  description = "IAM policy for Prometheus to monitor EBS volumes and CloudWatch metrics"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:DescribeVolumes",
          "ec2:DescribeVolumeStatus",
          "ec2:DescribeVolumeAttribute",
          "ec2:DescribeSnapshots",
          "ec2:DescribeSnapshotAttribute",
          "cloudwatch:GetMetricStatistics",
          "cloudwatch:ListMetrics"
        ]
        Resource = "*"
      }
    ]
  })

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-prometheus-ebs-policy-${var.environment}"
      Purpose = "Prometheus"
    }
  )
}

# ============================================================================
# IAM ROLE FOR PROMETHEUS (IRSA - IAM Roles for Service Accounts)
# ============================================================================
# Este rol permite que el Service Account de Prometheus en Kubernetes
# asuma permisos de AWS sin necesidad de credenciales hardcodeadas
# ============================================================================
resource "aws_iam_role" "prometheus" {
  name = "${var.project_name}-prometheus-role-${var.environment}"

  # Trust Policy: Define quién puede asumir este rol
  # En este caso, solo el Service Account de Prometheus en el namespace especificado
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          # El OIDC Provider del cluster EKS (viene del módulo EKS)
          Federated = var.oidc_provider_arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            # Solo el Service Account específico puede usar este rol
            # Formato: "system:serviceaccount:<namespace>:<service-account-name>"
            "${replace(var.oidc_issuer_url, "https://", "")}:sub" = "system:serviceaccount:${var.prometheus_namespace}:${var.prometheus_service_account}"
            "${replace(var.oidc_issuer_url, "https://", "")}:aud"   = "sts.amazonaws.com"
          }
        }
      }
    ]
  })

  tags = merge(
    var.tags,
    {
      Name    = "${var.project_name}-prometheus-role-${var.environment}"
      Purpose = "Prometheus-IRSA"
    }
  )
}

# ============================================================================
# ATTACH POLICY TO ROLE
# ============================================================================
# Asocia la IAM Policy al IAM Role
# Ahora el rol tiene los permisos definidos en la policy
# ============================================================================
resource "aws_iam_role_policy_attachment" "prometheus_ebs" {
  role       = aws_iam_role.prometheus.name
  policy_arn = aws_iam_policy.prometheus_ebs.arn
}

