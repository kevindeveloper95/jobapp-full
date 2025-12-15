# AWS Infrastructure - Jobber

This directory contains the documentation and configuration for the AWS infrastructure for the Jobber project.

---

## 📋 Documentation Index

### 1. [Networking (VPC, Subnets, Security Groups)](README-NETWORKING.md)
- VPC configuration
- Public and private subnets
- Security Groups
- NAT Gateway (if applicable)

### 2. [EKS Cluster Setup](README-EKS.md)
- EKS cluster creation
- Nodegroup configuration
- Installation and verification commands

### 2.1. [EKS Command Reference](EKS-COMMAND-REFERENCE.md)
- Quick reference for eksctl commands
- IAM Service Accounts management
- Controller and add-on installation
- Scaling and operations commands

### 3. [Databases](README-DATABASES.md)
- RDS (if used)
- ElastiCache (if used)
- Databases in Kubernetes
- Architectural decisions

### 4. [Security](README-SECURITY.md)
- IAM Roles and Policies
- IRSA (IAM Roles for Service Accounts)
- Secrets Management
- Critical Security Groups

### 5. [DNS and Route 53](README-DNS-ROUTE53.md)
- Route 53 Hosted Zone configuration
- Original domain configuration
- SSL/TLS certificates with ACM (wildcards)
- CloudFront Distribution
- DNS records and verification

### 6. [Costs and Resources](COSTOS-Y-RECURSOS.md)
- Capacity planning
- Required resources calculation
- Scenario comparison (Production vs Demo)
- Cost optimization strategies

### 7. [Troubleshooting](../../../docs/troubleshooting/README.md)
- Common problem solution guides
- Diagnostic commands
- Problems resolved by category

---

## 🏗️ File Structure

```
infrastructure/
├── README.md                    ← This file (index)
├── README-NETWORKING.md         ← Networking and VPC
├── README-EKS.md               ← EKS Cluster (complete guide)
├── EKS-COMMAND-REFERENCE.md    ← Quick reference for EKS commands
├── README-DATABASES.md         ← Databases
├── README-SECURITY.md          ← Security and IAM
├── README-DNS-ROUTE53.md       ← DNS, Route 53, CloudFront and Certificates
├── COSTOS-Y-RECURSOS.md        ← Cost and resource planning
└── eksctl-config.yaml          ← eksctl configuration (optional)
```

---

## 🚀 Quick Start

1. Review [README-NETWORKING.md](README-NETWORKING.md) to understand the network architecture
2. Follow [README-EKS.md](README-EKS.md) to create the cluster
3. Configure security according to [README-SECURITY.md](README-SECURITY.md)
4. Review [README-DATABASES.md](README-DATABASES.md) for databases
5. Configure DNS and certificates according to [README-DNS-ROUTE53.md](README-DNS-ROUTE53.md)

**Having issues?** Check the [Troubleshooting Guide](../../../docs/troubleshooting/README.md) for quick solutions.

---

## 📝 Notes

- This documentation assumes basic knowledge of AWS and Kubernetes
- All commands are tested in `us-east-1` (adjust region if necessary)
- For local development, see `../minikube/`

---

## 🔗 References

- [AWS EKS Documentation](https://docs.aws.amazon.com/eks/)
- [eksctl Documentation](https://eksctl.io/)
- [AWS VPC Documentation](https://docs.aws.amazon.com/vpc/)



