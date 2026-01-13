# Terraform Infrastructure as Code

This directory contains Terraform configurations to manage the infrastructure for the JobApp project using Infrastructure as Code (IaC).

## 📁 Directory Structure

```
terraform/
└── aws/                    # AWS infrastructure configuration
    ├── main.tf             # Main configuration
    ├── variables.tf        # Variable definitions
    ├── outputs.tf          # Output values
    ├── terraform.tfvars.example  # Example variables
    ├── .gitignore          # Git ignore rules
    ├── README.md           # Detailed documentation
    └── modules/            # Reusable Terraform modules
        ├── vpc/            # VPC module
        ├── eks/            # EKS cluster module
        └── security-groups/ # Security groups module
```

## 🚀 Quick Start

1. **Navigate to AWS directory**
   ```bash
   cd terraform/aws
   ```

2. **Copy example variables**
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

3. **Edit variables**
   ```bash
   # Edit terraform.tfvars with your values
   ```

4. **Initialize Terraform**
   ```bash
   terraform init
   ```

5. **Review plan**
   ```bash
   terraform plan
   ```

6. **Apply configuration**
   ```bash
   terraform apply
   ```

For detailed instructions, see [terraform/aws/README.md](./aws/README.md) (if available).

## 💰 Infrastructure Costs

The estimated monthly infrastructure cost is **$440.94 USD/month** (~$5,291/year).

For detailed cost information:
- **[Infrastructure Costs Summary](./aws/INFRASTRUCTURE-COSTS.md)** - Executive summary with cost breakdown by service and category
- **[AWS Pricing Calculator Guide](./aws/AWS-PRICING-CALCULATOR-GUIDE.md)** - Step-by-step guide for using AWS Pricing Calculator

## 📚 What's Included

### Current Modules

- **VPC Module**: Creates VPC, subnets, Internet Gateway, NAT Gateway
- **EKS Module**: Creates EKS cluster and managed node groups
- **Security Groups Module**: Creates security groups for EKS

### Planned Modules

- Route 53 and DNS configuration
- ACM certificates for SSL/TLS
- CloudFront distribution
- RDS databases (if needed)
- ElastiCache (if needed)
- IAM roles and policies
- CloudWatch monitoring

## 🎯 Goals

The goal of this Terraform configuration is to:

1. **Recreate existing infrastructure** that was created manually or with eksctl
2. **Version control** infrastructure changes
3. **Enable reproducibility** across environments
4. **Simplify management** of AWS resources
5. **Learn Terraform** and Infrastructure as Code best practices

## 📖 Resources

- [Terraform Documentation](https://www.terraform.io/docs)
- [AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Terraform Best Practices](https://www.terraform.io/docs/cloud/guides/recommended-practices/index.html)

---

**Status**: 🚧 Work in Progress - Learning and Implementation Phase

