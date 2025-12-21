# Terraform Infrastructure as Code - JobApp

This directory contains Terraform configurations to recreate and manage the AWS infrastructure for the JobApp project.

## 📋 Table of Contents

- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [Project Structure](#project-structure)
- [Getting Started](#getting-started)
- [Configuration](#configuration)
- [Usage](#usage)
- [Modules](#modules)
- [Best Practices](#best-practices)
- [Troubleshooting](#troubleshooting)

## Overview

This Terraform configuration recreates the AWS infrastructure that was previously created manually or with eksctl. It includes:

- **VPC** with public and private subnets
- **EKS Cluster** with managed node groups
- **Security Groups** for network security
- **IAM Roles** for service accounts (IRSA)
- **Route 53** and DNS configuration (to be added)
- **ACM Certificates** for SSL/TLS (to be added)
- **CloudFront** distribution (to be added)

## Prerequisites

Before you begin, ensure you have:

1. **Terraform installed** (>= 1.0)
   ```bash
   # Check version
   terraform version
   
   # Install from: https://www.terraform.io/downloads
   ```

2. **AWS CLI configured**
   ```bash
   aws configure
   # Or set environment variables:
   # AWS_ACCESS_KEY_ID
   # AWS_SECRET_ACCESS_KEY
   # AWS_DEFAULT_REGION
   ```

3. **AWS Account** with appropriate permissions:
   - VPC creation and management
   - EKS cluster creation
   - IAM role and policy management
   - EC2 instance management
   - Route 53 access (if using)

4. **kubectl installed** (for Kubernetes management)
   ```bash
   kubectl version --client
   ```

## Project Structure

```
terraform/aws/
├── main.tf                 # Main Terraform configuration
├── variables.tf            # Variable definitions
├── outputs.tf              # Output values
├── terraform.tfvars.example # Example variables file
├── .gitignore             # Git ignore rules
├── README.md              # This file
└── modules/               # Reusable Terraform modules
    ├── vpc/               # VPC module
    ├── eks/               # EKS cluster module
    └── security-groups/   # Security groups module
```

## Getting Started

### 1. Clone and Navigate

```bash
cd terraform/aws
```

### 2. Copy Example Variables

```bash
cp terraform.tfvars.example terraform.tfvars
```

### 3. Edit Variables

Edit `terraform.tfvars` with your specific values:

```hcl
aws_region  = "us-east-1"
project_name = "jobapp"
environment  = "dev"
```

### 4. Initialize Terraform

```bash
terraform init
```

This will:
- Download required providers (AWS)
- Initialize the backend (if configured)
- Download modules

### 5. Review the Plan

```bash
terraform plan
```

This shows what Terraform will create/modify/destroy.

### 6. Apply Configuration

```bash
terraform apply
```

Type `yes` when prompted to confirm.

## Configuration

### Variables

Key variables you can customize in `terraform.tfvars`:

- `aws_region`: AWS region (default: us-east-1)
- `project_name`: Project name (default: jobapp)
- `environment`: Environment name (dev/staging/production)
- `vpc_cidr`: VPC CIDR block (default: 10.0.0.0/16)
- `eks_cluster_version`: Kubernetes version
- `eks_node_groups`: Node group configuration

### Environment-Specific Configurations

You can create separate variable files:

```bash
# Development
terraform apply -var-file="dev.tfvars"

# Production
terraform apply -var-file="production.tfvars"
```

## Usage

### Common Commands

```bash
# Initialize
terraform init

# Plan changes
terraform plan

# Apply changes
terraform apply

# Destroy infrastructure
terraform destroy

# Format code
terraform fmt

# Validate configuration
terraform validate

# Show current state
terraform show

# List resources
terraform state list
```

### Updating kubeconfig

After creating the EKS cluster:

```bash
# Use the output command
aws eks update-kubeconfig --region us-east-1 --name jobapp-dev

# Or use Terraform output
terraform output -raw kubeconfig_command | bash
```

### Working with Modules

Modules are located in `modules/` directory. Each module should have:

- `main.tf` - Main resources
- `variables.tf` - Module variables
- `outputs.tf` - Module outputs
- `README.md` - Module documentation

## Modules

### VPC Module

Creates:
- VPC with specified CIDR
- Public and private subnets across AZs
- Internet Gateway
- NAT Gateway (optional)
- Route tables

### EKS Module

Creates:
- EKS Cluster
- Managed Node Groups
- IAM Roles for service accounts
- Security groups

### Security Groups Module

Creates:
- Security groups for EKS cluster
- Security groups for node groups
- Security groups for ALB/NLB (if needed)

## Best Practices

### 1. State Management

**Option A: Local State (Development)**
- State stored locally in `terraform.tfstate`
- Simple but not suitable for teams

**Option B: Remote State (Recommended)**
- Use S3 backend with DynamoDB for locking
- Uncomment and configure backend in `main.tf`

```hcl
backend "s3" {
  bucket         = "jobapp-terraform-state"
  key            = "aws/terraform.tfstate"
  region         = "us-east-1"
  encrypt        = true
  dynamodb_table = "terraform-state-lock"
}
```

### 2. Workspaces

Use Terraform workspaces for multiple environments:

```bash
# Create workspace
terraform workspace new dev
terraform workspace new staging
terraform workspace new production

# Switch workspace
terraform workspace select dev

# List workspaces
terraform workspace list
```

### 3. Version Control

- ✅ Commit `.tf` files
- ✅ Commit `terraform.tfvars.example`
- ❌ Never commit `terraform.tfvars` (contains secrets)
- ❌ Never commit `.tfstate` files
- ✅ Consider committing `.terraform.lock.hcl`

### 4. Code Organization

- Use modules for reusable components
- Keep resources organized by service
- Use consistent naming conventions
- Document complex configurations

### 5. Security

#### Managing Sensitive Credentials

**For Portfolio/Development Projects (Free & Professional):**

This project uses Terraform's `sensitive = true` flag to protect credentials:

1. **Never commit `terraform.tfvars`** - It's in `.gitignore`
2. **Use `terraform.tfvars.example`** - Contains example values (safe to commit)
3. **Mark sensitive variables** - All password variables use `sensitive = true`

**Setting up credentials:**

```bash
# Option 1: Create terraform.tfvars (recommended for local development)
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your actual values

# Option 2: Use environment variables (alternative)
# PowerShell:
$env:TF_VAR_rds_mysql_password = "YourSecurePassword123!"
# Bash:
export TF_VAR_rds_mysql_password="YourSecurePassword123!"
```

**What gets committed to Git:**
- ✅ `terraform.tfvars.example` (example values only)
- ✅ All `.tf` files (no actual passwords)
- ❌ `terraform.tfvars` (your actual credentials - in .gitignore)
- ❌ `.tfstate` files (may contain sensitive data - in .gitignore)

**For Production:**
- Use AWS Secrets Manager (costs ~$0.40/month per secret)
- Use Terraform Cloud/Enterprise for team collaboration
- Use IAM roles with least privilege
- Enable encryption for state files
- Review `terraform plan` before applying

## Troubleshooting

### Common Issues

**Issue: Provider authentication errors**
```bash
# Verify AWS credentials
aws sts get-caller-identity

# Check AWS CLI configuration
aws configure list
```

**Issue: State lock errors**
```bash
# If state is locked (from previous failed operation)
# Check DynamoDB table or S3 for lock file
# Remove lock manually if safe to do so
```

**Issue: Resource already exists**
```bash
# Import existing resource
terraform import aws_vpc.example vpc-12345678

# Or use terraform import for existing resources
```

**Issue: Module not found**
```bash
# Re-initialize modules
terraform init -upgrade
```

### Getting Help

- [Terraform AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Terraform Documentation](https://www.terraform.io/docs)
- [AWS EKS User Guide](https://docs.aws.amazon.com/eks/)

## Next Steps

1. **Create Modules**: Implement VPC, EKS, and Security Groups modules
2. **Add Route 53**: Configure DNS and hosted zones
3. **Add ACM**: SSL/TLS certificate management
4. **Add CloudFront**: CDN configuration
5. **Add RDS/ElastiCache**: If using managed databases
6. **Add Monitoring**: CloudWatch, alarms, etc.
7. **CI/CD Integration**: Terraform in CI/CD pipeline

## Migration from eksctl

If you have existing infrastructure created with eksctl:

1. **Export existing resources** (if possible)
2. **Import into Terraform** using `terraform import`
3. **Gradually migrate** resources to Terraform
4. **Test thoroughly** before destroying eksctl resources

Example import:
```bash
# Import EKS cluster
terraform import module.eks.aws_eks_cluster.main jobapp-dev

# Import node group
terraform import module.eks.aws_eks_node_group.main jobapp-dev:nodegroup-main
```

---

**Note**: This is a starting point. You'll need to implement the actual module code in `modules/` directory based on your infrastructure requirements.

**Status**: 🚧 Work in Progress

