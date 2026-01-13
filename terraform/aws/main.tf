terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Uncomment and configure when using remote state (S3, Terraform Cloud, etc.)
  # backend "s3" {
  #   bucket         = "jobapp-terraform-state"
  #   key            = "aws/terraform.tfstate"
  #   region         = "us-east-1"
  #   encrypt        = true
  #   dynamodb_table = "terraform-state-lock"
  # }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "JobApp"
      Environment = var.environment
      ManagedBy   = "Terraform"
      CreatedBy   = "Infrastructure Team"
    }
  }
}

# Get available availability zones
data "aws_availability_zones" "available" {
  state = "available"
}

module "vpc" {
  source = "./modules/vpc"

  project_name       = var.project_name
  environment        = var.environment
  vpc_cidr           = var.vpc_cidr
  availability_zones = data.aws_availability_zones.available.names

  tags = {
    Name = "${var.project_name}-vpc-${var.environment}"
  }
}

module "security_groups" {
  source = "./modules/security-groups"

  project_name = var.project_name
  environment  = var.environment
  vpc_id       = module.vpc.vpc_id
  vpc_cidr     = module.vpc.vpc_cidr_block

  tags = {
    Name = "${var.project_name}-security-groups-${var.environment}"
  }
}

module "db_subnet_group" {
  source = "./modules/db-subnet-group"

  project_name = var.project_name
  environment  = var.environment
  subnet_ids = [
    module.vpc.private_subnet_1_id,
    module.vpc.private_subnet_2_id
  ]

  tags = {
    Name = "${var.project_name}-db-subnet-group-${var.environment}"
  }
}

module "rds_mysql" {
  source = "./modules/rds-aurora-mysql"

  project_name            = var.project_name
  environment             = var.environment
  database_name           = var.rds_mysql_database_name
  master_username         = var.rds_mysql_username
  master_password         = var.rds_mysql_password # From terraform.tfvars (sensitive)
  instance_class          = var.rds_mysql_instance_class
  allocated_storage       = var.rds_mysql_allocated_storage
  db_subnet_group_name    = module.db_subnet_group.db_subnet_group_name
  mysql_security_group_id = module.security_groups.mysql_security_group_id

  tags = {
    Name = "${var.project_name}-mysql-${var.environment}"
  }
}


module "rds_postgres" {
  source = "./modules/rds-aurora-postgresql"

  project_name               = var.project_name
  environment                = var.environment
  database_name              = var.rds_postgres_database_name
  master_username            = var.rds_postgres_username
  master_password            = var.rds_postgres_password # From terraform.tfvars (sensitive)
  instance_class             = var.rds_postgres_instance_class
  allocated_storage          = var.rds_postgres_allocated_storage
  db_subnet_group_name       = module.db_subnet_group.db_subnet_group_name
  postgres_security_group_id = module.security_groups.postgres_security_group_id

  tags = {
    Name = "${var.project_name}-postgres-${var.environment}"
  }
}

# Key Pair for EC2 SSH access
# ⚠️ IMPORTANTE: Antes de aplicar, debes generar las claves SSH y agregar
#    ec2_public_key en terraform.tfvars. Ver instrucciones en modules/key-pair/main.tf
module "key_pair" {
  source = "./modules/key-pair"

  project_name = var.project_name
  environment  = var.environment
  public_key   = var.ec2_public_key

  tags = {
    Name = "${var.project_name}-key-${var.environment}"
  }
}

# EKS Cluster
# ⚠️ IMPORTANTE: Asegúrate de tener configurado eks_node_groups en terraform.tfvars
#    antes de ejecutar terraform apply
module "eks" {
  source = "./modules/eks"

  project_name    = var.project_name
  environment     = var.environment
  cluster_name    = var.eks_cluster_name
  cluster_version = var.eks_cluster_version
  vpc_id          = module.vpc.vpc_id
  vpc_cidr_block  = module.vpc.vpc_cidr_block
  # Usar subnets privadas para los nodos (más seguro)
  subnet_ids      = [
    module.vpc.private_subnet_1_id,
    module.vpc.private_subnet_2_id
  ]
  # Key pair para SSH a los nodos (opcional)
  key_pair_name   = module.key_pair.key_name
  # Configuración de node groups
  node_groups     = var.eks_node_groups

  tags = {
    Name = "${var.project_name}-eks-${var.environment}"
  }
}

# Prometheus IAM Policy and Role (IRSA)
# ⚠️ IMPORTANTE: Este módulo depende del módulo EKS porque necesita el OIDC Provider
#    El módulo EKS debe crearse primero para que el OIDC Provider exista
module "prometheus_iam_policy" {
  source = "./modules/prometheus-iam-policy"

  project_name = var.project_name
  environment  = var.environment

  # Variables para IRSA (necesita el OIDC Provider del módulo EKS)
  oidc_provider_arn = module.eks.cluster_oidc_provider_arn
  oidc_issuer_url    = module.eks.cluster_oidc_issuer_url

  # Configuración del Service Account de Prometheus en Kubernetes
  # Puedes cambiar estos valores si tu Service Account tiene otro nombre/namespace
  prometheus_namespace        = "monitoring"
  prometheus_service_account  = "prometheus"

  tags = {
    Name = "${var.project_name}-prometheus-iam-policy-${var.environment}"
  }
}

# AWS Load Balancer Controller IAM Policy and Role (IRSA)
# ⚠️ IMPORTANTE: Este módulo depende del módulo EKS porque necesita el OIDC Provider
module "load_balancer_controller_iam_policy" {
  source = "./modules/load-balancer-controller-iam"

  project_name = var.project_name
  environment  = var.environment

  # Variables para IRSA (necesita el OIDC Provider del módulo EKS)
  oidc_provider_arn = module.eks.cluster_oidc_provider_arn
  oidc_issuer_url    = module.eks.cluster_oidc_issuer_url

  # Configuración del Service Account del Load Balancer Controller en Kubernetes
  service_account_namespace = "kube-system"
  service_account_name      = "aws-load-balancer-controller"

  tags = {
    Name = "${var.project_name}-load-balancer-controller-iam-policy-${var.environment}"
  }
}

# External DNS IAM Policy and Role (IRSA)
# ⚠️ IMPORTANTE: Este módulo depende del módulo EKS porque necesita el OIDC Provider
module "external_dns_iam_policy" {
  source = "./modules/external-dns-iam"

  project_name = var.project_name
  environment  = var.environment

  # Variables para IRSA (necesita el OIDC Provider del módulo EKS)
  oidc_provider_arn = module.eks.cluster_oidc_provider_arn
  oidc_issuer_url    = module.eks.cluster_oidc_issuer_url

  # Configuración de Service Accounts de External DNS en Kubernetes
  # Todos estos Service Accounts pueden usar el mismo role
  service_accounts = [
    {
      namespace = "production"
      name      = "frontend-external-dns"
    },
    {
      namespace = "production"
      name      = "gateway-external-dns"
    },
    {
      namespace = "prometheus"
      name      = "prometheus-external-dns"
    },
    {
      namespace = "grafana"
      name      = "grafana-external-dns"
    }
  ]

  tags = {
    Name = "${var.project_name}-allow-external-dns-iam-policy-${var.environment}"
  }
}

module "elasticache_subnet_group" {
  source = "./modules/elasticache-subnet-group"
  
  project_name = var.project_name
  environment  = var.environment
  subnet_ids = [
    module.vpc.private_subnet_1_id,
    module.vpc.private_subnet_2_id
  ]
  
  tags = {
    Name = "${var.project_name}-elasticache-subnet-group-${var.environment}"
  }
}

module "elasticache_redis" {
  source = "./modules/elasticache-redis"
  
  project_name              = var.project_name
  environment               = var.environment
  subnet_group_name         = module.elasticache_subnet_group.elasticache_subnet_group_name  # ← CONEXIÓN CON SUBNET GROUP
  redis_security_group_id   = module.security_groups.redis_security_group_id
  
  # Configuración del cluster
  node_type                 = var.redis_node_type  # Necesitarás agregar esto a variables.tf
  engine_version            = var.redis_engine_version
  num_cache_clusters        = var.redis_num_cache_clusters
  automatic_failover_enabled = var.redis_automatic_failover_enabled
  multi_az_enabled          = var.redis_multi_az_enabled
  
  # Backup
  snapshot_retention_limit   = var.redis_snapshot_retention_limit
  snapshot_window           = var.redis_snapshot_window
  
  tags = {
    Name = "${var.project_name}-redis-${var.environment}"
  }
}

# Route 53 Hosted Zone (Principal - Creado manualmente)
# ⚠️ COMENTADO: El Hosted Zone ya fue creado manualmente en AWS
# Si quieres que Terraform lo gestione, descomenta estas líneas y ejecuta:
# terraform import module.route53_hosted_zone.aws_route53_zone.main <HOSTED_ZONE_ID>
# module "route53_hosted_zone" {
#   source = "./modules/route53-hosted-zone"
#   
#   project_name = var.project_name
#   environment  = var.environment
#   domain_name  = var.domain_name
#   
#   tags = {
#     Name = "${var.project_name}-hosted-zone-${var.environment}"
#     Domain = var.domain_name
#   }
# }

# Route 53 Hosted Zone para jobberapp.kevmendeveloper.com
module "route53_hosted_zone_jobberapp" {
  source = "./modules/route53-hosted-zone"
  
  project_name = var.project_name
  environment  = var.environment
  domain_name   = var.jobberapp_subdomain
  
  tags = {
    Name   = "${var.project_name}-hosted-zone-jobberapp-${var.environment}"
    Domain = var.jobberapp_subdomain
    Type   = "subdomain"
  }
}

# Route 53 Hosted Zone para api.jobberapp.kevmendeveloper.com
module "route53_hosted_zone_api" {
  source = "./modules/route53-hosted-zone"
  
  project_name = var.project_name
  environment  = var.environment
  domain_name   = var.api_subdomain
  
  tags = {
    Name   = "${var.project_name}-hosted-zone-api-${var.environment}"
    Domain = var.api_subdomain
    Type   = "subdomain"
  }
}

# Route 53 Records para kevmendeveloper.com
# ⚠️ COMENTADO: Los ALBs aún no están creados
# Cuando crees los ALBs, descomenta estos módulos y completa las variables:
# - main_alb_dns_name: DNS name del ALB principal
# - main_alb_zone_id: Zone ID del ALB principal
# - www_alb_dns_name: DNS name del ALB para www (opcional)
# - www_alb_zone_id: Zone ID del ALB para www (opcional)

# Record para kevmendeveloper.com (apunta al ALB principal)
# module "route53_record_main" {
#   source = "./modules/route53-record"
#   
#   hosted_zone_id = var.main_hosted_zone_id
#   record_name    = "kevmendeveloper.com"
#   record_type    = "A"
#   
#   alias_target = {
#     name                   = var.main_alb_dns_name
#     zone_id                = var.main_alb_zone_id
#     evaluate_target_health = true
#   }
#   
#   tags = {
#     Name = "kevmendeveloper.com"
#     Type = "main-domain"
#   }
# }

# Record para www.kevmendeveloper.com (opcional, apunta al mismo ALB o a otro)
# module "route53_record_www" {
#   source = "./modules/route53-record"
#   
#   hosted_zone_id = var.main_hosted_zone_id
#   record_name    = "www.kevmendeveloper.com"
#   record_type    = "A"
#   
#   alias_target = {
#     name                   = var.www_alb_dns_name != null ? var.www_alb_dns_name : var.main_alb_dns_name
#     zone_id                = var.www_alb_zone_id != null ? var.www_alb_zone_id : var.main_alb_zone_id
#     evaluate_target_health = true
#   }
#   
#   tags = {
#     Name = "www.kevmendeveloper.com"
#     Type = "www-subdomain"
#   }
# }

# ACM Certificates para los subdominios

# Certificado para jobberapp.kevmendeveloper.com
module "acm_certificate_jobberapp" {
  source = "./modules/acm-certificate"
  
  project_name = var.project_name
  environment  = var.environment
  domain_name  = var.jobberapp_subdomain
  hosted_zone_id = module.route53_hosted_zone_jobberapp.hosted_zone_id
  
  # Incluir wildcard para subdominios
  subject_alternative_names = ["*.${var.jobberapp_subdomain}"]
  
  validate_certificate = true
  
  tags = {
    Name   = "${var.project_name}-cert-jobberapp-${var.environment}"
    Domain = var.jobberapp_subdomain
  }
}

# Certificado para api.jobberapp.kevmendeveloper.com
module "acm_certificate_api" {
  source = "./modules/acm-certificate"
  
  project_name = var.project_name
  environment  = var.environment
  domain_name  = var.api_subdomain
  hosted_zone_id = module.route53_hosted_zone_api.hosted_zone_id
  
  validate_certificate = true
  
  tags = {
    Name   = "${var.project_name}-cert-api-${var.environment}"
    Domain = var.api_subdomain
  }
}


