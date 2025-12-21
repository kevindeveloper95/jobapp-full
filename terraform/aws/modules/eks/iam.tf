# ----------------------------------------------------------------------------
# OIDC IDENTITY PROVIDER FOR IRSA (IAM Roles for Service Accounts)
# ----------------------------------------------------------------------------
# Este recurso crea el OIDC Provider que permite que los pods de Kubernetes
# asuman roles de IAM usando Service Accounts (IRSA).
#
# ⚠️ IMPORTANTE: Este es el equivalente en Terraform del comando:
#    eksctl utils associate-iam-oidc-provider --cluster=<name> --approve
#
# ¿Para qué sirve?
# - Permite que pods (como Prometheus) asuman roles de IAM
# - Evita tener que hardcodear credenciales AWS en los pods
# - Es más seguro y sigue el principio de "least privilege"
#
# Ejemplo de uso:
# - Prometheus necesita acceso a CloudWatch y EBS para monitoreo
# - En lugar de poner credenciales en el pod, creas un IAM Role
# - El Service Account de Prometheus asume ese rol automáticamente
# ----------------------------------------------------------------------------

# Data source para obtener la URL del OIDC issuer del cluster
# Esta URL la genera automáticamente AWS cuando creas el cluster EKS
# ⚠️ IMPORTANTE: Este data source se ejecuta DESPUÉS de que el cluster esté creado
#    debido a la dependencia implícita en la URL
data "tls_certificate" "eks" {
  url = aws_eks_cluster.main.identity[0].oidc[0].issuer

  # Dependencia explícita: Asegurar que el cluster esté completamente creado
  # antes de intentar leer los certificados
  depends_on = [aws_eks_cluster.main]
}

# Crear el OIDC Identity Provider en IAM
# Esto "registra" el cluster EKS como un proveedor de identidad OIDC
resource "aws_iam_openid_connect_provider" "eks" {
  # URL del issuer (viene del cluster EKS)
  url = aws_eks_cluster.main.identity[0].oidc[0].issuer

  # Thumbprints de los certificados (requerido por AWS)
  # Estos certificados validan que el issuer es legítimo
  client_id_list = ["sts.amazonaws.com"]

  # Thumbprints de los certificados del issuer
  thumbprint_list = [data.tls_certificate.eks.certificates[0].sha1_fingerprint]

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-eks-oidc-provider-${var.environment}"
      Purpose = "IRSA"
    }
  )

  # Dependencia: El cluster debe existir antes de crear el OIDC Provider
  depends_on = [aws_eks_cluster.main]
}



# ============================================================================
# IAM ROLES AND POLICIES FOR EKS
# ============================================================================

# ----------------------------------------------------------------------------
# IAM ROLE FOR EKS CLUSTER (Control Plane)
# ----------------------------------------------------------------------------
# Este rol permite que el control plane de EKS gestione recursos de AWS
# en tu nombre (crear ENIs, security groups, etc.)
# ----------------------------------------------------------------------------
resource "aws_iam_role" "cluster" {
  name = "${var.project_name}-eks-cluster-role-${var.environment}"

  # Trust Policy: Permite que el servicio EKS asuma este rol
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com" # Solo EKS puede asumir este rol
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-eks-cluster-role-${var.environment}"
      Type = "eks-cluster-role"
    }
  )
}

# Adjuntar la política necesaria para que el cluster funcione
# Esta política permite al cluster crear y gestionar recursos de red
resource "aws_iam_role_policy_attachment" "cluster_policy" {
  role       = aws_iam_role.cluster.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

# ----------------------------------------------------------------------------
# IAM ROLE FOR EKS NODES (Worker Nodes)
# ----------------------------------------------------------------------------
# Este rol permite que los nodos EC2 se comuniquen con el cluster EKS
# y accedan a servicios de AWS (ECR, CloudWatch, etc.)
# ----------------------------------------------------------------------------
resource "aws_iam_role" "nodes" {
  name = "${var.project_name}-eks-node-role-${var.environment}"

  # Trust Policy: Permite que instancias EC2 asuman este rol
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com" # Solo instancias EC2 pueden asumir este rol
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-eks-node-role-${var.environment}"
      Type = "eks-node-role"
    }
  )
}

# Política 1: Permite que los nodos se registren con el cluster EKS
resource "aws_iam_role_policy_attachment" "nodes_eks_worker_node_policy" {
  role       = aws_iam_role.nodes.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

# Política 2: Permite que los nodos configuren la red (CNI plugin)
# El CNI plugin crea interfaces de red para los pods
resource "aws_iam_role_policy_attachment" "nodes_eks_cni_policy" {
  role       = aws_iam_role.nodes.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

# Política 3: Permite que los nodos descarguen imágenes de ECR (Docker registry)
resource "aws_iam_role_policy_attachment" "nodes_ecr_readonly" {
  role       = aws_iam_role.nodes.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

# Política 4: Permite acceso a SSM (opcional, útil para debugging)
# Te permite conectarte a los nodos sin SSH usando AWS Systems Manager
resource "aws_iam_role_policy_attachment" "nodes_ssm_policy" {
  role       = aws_iam_role.nodes.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# ----------------------------------------------------------------------------
# SECURITY GROUP FOR EKS CLUSTER
# ----------------------------------------------------------------------------
# Controla el tráfico de red hacia y desde el cluster
# ----------------------------------------------------------------------------
resource "aws_security_group" "cluster" {
  name        = "${var.project_name}-eks-cluster-sg-${var.environment}"
  description = "Security group for EKS cluster"
  vpc_id      = var.vpc_id

  # INGRESS RULE 1: HTTPS desde los nodos (puerto 443)
  # Los nodos necesitan comunicarse con la API del cluster
  ingress {
    description     = "HTTPS from nodes to cluster API"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.nodes.id] # Solo desde los nodos
  }

  # INGRESS RULE 2: HTTPS desde la VPC (para kubectl desde tu máquina)
  # Si estás en la VPC, puedes usar kubectl directamente
  ingress {
    description = "HTTPS from VPC (for kubectl)"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_block]
  }

  # EGRESS: Permitir todo el tráfico saliente
  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-eks-cluster-sg-${var.environment}"
      Type = "eks-cluster"
    }
  )
}

# ----------------------------------------------------------------------------
# SECURITY GROUP FOR EKS NODES
# ----------------------------------------------------------------------------
# Controla el tráfico de red hacia y desde los nodos
# ----------------------------------------------------------------------------
resource "aws_security_group" "nodes" {
  name        = "${var.project_name}-eks-nodes-sg-${var.environment}"
  description = "Security group for EKS worker nodes"
  vpc_id      = var.vpc_id

  # INGRESS RULE 1: Todo el tráfico desde el cluster
  # Los pods necesitan comunicarse entre sí
  ingress {
    description     = "All traffic from cluster"
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_security_group.cluster.id]
  }

  # INGRESS RULE 2: Todo el tráfico desde otros nodos
  # Los pods en diferentes nodos necesitan comunicarse
  ingress {
    description = "All traffic from other nodes"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true # Permite tráfico desde otros nodos con el mismo security group
  }

  # INGRESS RULE 3: SSH desde la VPC (para debugging)
  ingress {
    description = "SSH from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_block]
  }

  # EGRESS: Permitir todo el tráfico saliente
  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-eks-nodes-sg-${var.environment}"
      Type = "eks-nodes"
    }
  )
}

