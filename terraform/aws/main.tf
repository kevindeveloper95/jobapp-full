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


