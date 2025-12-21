# ============================================================================
# EKS CLUSTER
# ============================================================================
# El cluster EKS es el "cerebro" de Kubernetes. Gestiona:
# - API Server (endpoint para kubectl)
# - etcd (base de datos del cluster)
# - Scheduler (decide dónde ejecutar pods)
# - Controller Manager (gestiona el estado deseado)
# ============================================================================
resource "aws_eks_cluster" "main" {
  # Nombre del cluster (auto-generado si no se proporciona)
  name     = var.cluster_name != "" ? var.cluster_name : "${var.project_name}-eks-${var.environment}"
  role_arn = aws_iam_role.cluster.arn
  version  = var.cluster_version

  # Configuración de red
  vpc_config {
    # Subnets donde se desplegará el cluster
    # EKS necesita al menos 2 subnets en diferentes AZs
    subnet_ids              = var.subnet_ids
    # Security group para el cluster
    security_group_ids       = [aws_security_group.cluster.id]
    # Endpoint público: permite acceso desde internet
    endpoint_private_access  = true  # Acceso privado (desde VPC)
    endpoint_public_access   = true  # Acceso público (desde internet)
    # Controla si el endpoint público requiere autenticación
    public_access_cidrs     = ["0.0.0.0/0"] # Permite acceso desde cualquier IP
  }

  # Habilitar logging de CloudWatch
  enabled_cluster_log_types = [
    "api",
    "audit",
    "authenticator",
    "controllerManager",
    "scheduler"
  ]

  # Dependencias: El cluster necesita que el IAM role exista primero
  depends_on = [
    aws_iam_role_policy_attachment.cluster_policy
  ]

  tags = merge(
    var.tags,
    {
      Name = var.cluster_name != "" ? var.cluster_name : "${var.project_name}-eks-${var.environment}"
      Type = "eks-cluster"
    }
  )
}

# ============================================================================
# EKS NODE GROUPS
# ============================================================================
# Los node groups son grupos de instancias EC2 que ejecutan tus aplicaciones
# Puedes tener múltiples node groups con diferentes configuraciones
# ============================================================================
resource "aws_eks_node_group" "main" {
  for_each = var.node_groups

  # Nombre del node group
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "${var.project_name}-${each.key}-${var.environment}"
  node_role_arn   = aws_iam_role.nodes.arn
  subnet_ids      = var.subnet_ids

  # Configuración de escalado
  scaling_config {
    desired_size = each.value.desired_size
    min_size     = each.value.min_size
    max_size     = each.value.max_size
  }

  # Tipo de instancias (puedes especificar múltiples para diversidad)
  instance_types = each.value.instance_types

  # Tamaño del disco raíz
  disk_size = each.value.disk_size

  # Tipo de capacidad
  # ON_DEMAND: Instancias normales (más caras, más estables)
  # SPOT: Instancias con descuento (más baratas, pueden ser terminadas)
  capacity_type = each.value.capacity_type

  # Configuración de acceso remoto (SSH)
  remote_access {
    # Key pair para SSH (opcional, solo si quieres acceso SSH)
    ec2_ssh_key = var.key_pair_name != "" ? var.key_pair_name : null
    # Security groups adicionales para SSH (ya incluido en el SG de nodos)
    source_security_group_ids = [aws_security_group.nodes.id]
  }

  # Labels para los nodos (útil para scheduling de pods)
  # Ejemplo: {"node-type": "general", "environment": "production"}
  labels = merge(
    {
      "node-group" = each.key
    },
    each.value.labels
  )

  # Taints para los nodos (evita que ciertos pods se ejecuten aquí)
  # Ejemplo: {"key": "dedicated", "value": "gpu", "effect": "NO_SCHEDULE"}
  dynamic "taint" {
    for_each = each.value.taints
    content {
      key    = taint.value.key
      value  = taint.value.value
      effect = taint.value.effect
    }
  }

  # Actualización de nodos
  update_config {
    max_unavailable = 1 # Máximo de nodos que pueden estar indisponibles durante actualizaciones
  }

  # Dependencias: El node group necesita que el cluster y los roles existan
  depends_on = [
    aws_eks_cluster.main,
    aws_iam_role_policy_attachment.nodes_eks_worker_node_policy,
    aws_iam_role_policy_attachment.nodes_eks_cni_policy,
    aws_iam_role_policy_attachment.nodes_ecr_readonly
  ]

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-${each.key}-node-group-${var.environment}"
      Type = "eks-node-group"
    }
  )
}
