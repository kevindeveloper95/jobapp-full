# 💰 AWS Infrastructure Costs - JobApp

This document provides a comprehensive breakdown of the estimated monthly infrastructure costs for the JobApp project deployed on AWS.

## 📊 Executive Summary

**Total Monthly Cost: $440.94 USD**  
**Total Annual Cost: ~$5,291 USD**

The infrastructure is deployed in the `us-east-1` (N. Virginia) region and includes a production-ready setup with high availability, load balancing, container orchestration, and managed database services.

---

## 📋 Cost Breakdown by Service

| # | Service | Configuration | Monthly Cost (USD) | Cost Source |
|---|---------|---------------|-------------------|-------------|
| 1 | **Elastic Load Balancing** | Application Load Balancers (4x) | $163.81 | jobbapp-costs |
| 2 | **Amazon EKS** | Control Plane (1 cluster) | $73.00 | jobbapp-costs |
| 3 | **Amazon EC2** | Node Groups (4 × t3a.medium) | $64.20 | jobbapp-costs |
| 4 | **Amazon ElastiCache** | Redis (2 nodes) | $49.64 | jobbapp-costs |
| 5 | **Amazon VPC** | NAT Gateway + Network | $35.10 | jobbapp-costs |
| 6 | **AWS Data Transfer** | Egress + Intra-Region | $20.00 | jobbapp-costs |
| 7 | **Amazon RDS PostgreSQL** | db.t3.micro (Single-AZ) | $15.44 | jobbapp-costs |
| 8 | **Amazon RDS MySQL** | db.t3.micro (Single-AZ) | $14.71 | jobbapp-costs |
| 9 | **Amazon Route 53** | DNS (2 hosted zones) | $1.80 | jobbapp-costs |
| 10 | **Amazon EBS** | Persistent Volumes (18 GB gp3) | $1.44 | jobbapp-costs |

**Total: $440.94 USD/month**

---

## 📊 Cost Breakdown by Category

| Category | Monthly Cost (USD) | Percentage | Components |
|----------|-------------------|------------|------------|
| **Compute & Orchestration** | $137.20 | 31.1% | EKS Control Plane ($73.00) + EC2 Node Groups ($64.20) |
| **Load Balancing** | $163.81 | 37.2% | Application Load Balancers (4x) |
| **Data Services** | $79.79 | 18.1% | ElastiCache Redis ($49.64) + RDS PostgreSQL ($15.44) + RDS MySQL ($14.71) |
| **Networking** | $55.10 | 12.5% | VPC NAT Gateway ($35.10) + Data Transfer ($20.00) |
| **Storage** | $1.44 | 0.3% | EBS Persistent Volumes (18 GB) |
| **DNS & Routing** | $1.80 | 0.4% | Route 53 Hosted Zones (2x) |
| **Other (Free)** | $0.00 | 0.0% | Security Groups, IAM, ACM Certificates |

---

## 🏗️ Infrastructure Components

### Compute & Orchestration ($137.20/month - 31.1%)

- **Amazon EKS Control Plane**: $73.00/month
  - Managed Kubernetes control plane
  - High availability across multiple AZs
  - Automatic updates and patching

- **Amazon EC2 Node Groups**: $64.20/month
  - 4 × t3a.medium instances
  - Running Kubernetes worker nodes
  - Auto-scaling enabled

### Load Balancing ($163.81/month - 37.2%)

- **Application Load Balancers**: 4 ALBs
  - Frontend ALB
  - API Gateway ALB
  - Prometheus ALB
  - Grafana ALB
  - High availability and SSL termination

### Data Services ($79.79/month - 18.1%)

- **Amazon ElastiCache Redis**: $49.64/month
  - 2 nodes for high availability
  - Session storage and caching
  - Multi-AZ deployment

- **Amazon RDS PostgreSQL**: $15.44/month
  - db.t3.micro instance
  - Single-AZ deployment
  - Automated backups

- **Amazon RDS MySQL**: $14.71/month
  - db.t3.micro instance
  - Single-AZ deployment
  - Automated backups

### Networking ($55.10/month - 12.5%)

- **Amazon VPC NAT Gateway**: $35.10/month
  - High availability NAT gateway
  - Enables outbound internet access for private subnets
  - Data processing charges included

- **AWS Data Transfer**: $20.00/month
  - Egress traffic to internet
  - Intra-region data transfer between AZs
  - Estimated based on moderate traffic

### Storage ($1.44/month - 0.3%)

- **Amazon EBS Volumes**: $1.44/month
  - 18 GB gp3 volumes for Kubernetes PVCs
  - MySQL, PostgreSQL, MongoDB, RabbitMQ persistent storage

### DNS & Routing ($1.80/month - 0.4%)

- **Amazon Route 53**: $1.80/month
  - 2 hosted zones
  - DNS queries (first 1M queries/month free)
  - Health checks and routing

### Free Services ($0.00/month)

- Security Groups
- IAM Roles and Policies
- ACM Certificates
- VPC, Subnets, Route Tables
- Internet Gateway

---

## 💡 Cost Optimization Recommendations

### Immediate Optimizations

1. **Reserved Instances for EC2**
   - Current: $64.20/month (On-Demand)
   - With 1-year Reserved: ~$38/month (40% savings)
   - With 3-year Reserved: ~$26/month (60% savings)
   - **Potential savings: $26-38/month**

2. **Reserved Instances for RDS**
   - Current: $30.15/month (On-Demand)
   - With 1-year Reserved: ~$18/month (40% savings)
   - **Potential savings: $12/month**

3. **ElastiCache Reserved Nodes**
   - Current: $49.64/month (On-Demand)
   - With 1-year Reserved: ~$30/month (40% savings)
   - **Potential savings: $20/month**

**Total potential savings with Reserved Instances: ~$58-70/month (13-16% reduction)**

### Long-term Optimizations

1. **ALB Consolidation**
   - Consider consolidating Prometheus and Grafana ALBs if internal-only access is acceptable
   - Potential savings: ~$40/month

2. **EKS Fargate** (if applicable)
   - Pay only for running pods
   - No EC2 instance management
   - Cost-effective for variable workloads

3. **Data Transfer Optimization**
   - Implement CloudFront CDN to reduce origin data transfer
   - Use S3 for static assets
   - Potential savings: ~$10-15/month

4. **Database Optimization**
   - Consider Aurora Serverless for variable workloads
   - Implement connection pooling
   - Monitor and optimize query performance

---

## 📈 Cost Scaling Factors

### Variable Costs (Based on Usage)

- **Data Transfer**: Scales with traffic volume
  - First 100 GB/month: Free
  - Next 40 TB: $0.09/GB
  - Monitor and optimize based on actual usage

- **Route 53 DNS Queries**: Scales with traffic
  - First 1M queries/month: Free
  - Additional: $0.40 per million queries

- **EBS Storage**: Scales with data growth
  - Current: 18 GB at $0.10/GB-month
  - Monitor database growth and implement cleanup policies

### Fixed Costs (24/7 Uptime)

- EKS Control Plane: $73/month (fixed)
- EC2 Instances: $64.20/month (scales with instance count)
- NAT Gateway: $35.10/month (fixed)
- ALBs: $163.81/month (fixed per ALB)
- RDS Instances: $30.15/month (fixed per instance)
- ElastiCache: $49.64/month (fixed per node)

---

## 📝 Cost Estimation Methodology

### Assumptions

- **Region**: us-east-1 (N. Virginia)
- **Pricing Model**: On-Demand (no Reserved Instances)
- **Uptime**: 24/7 (730 hours/month)
- **Traffic**: Conservative estimates for production workloads
- **High Availability**: Multi-AZ deployment where applicable

### Data Sources

- **jobbapp-costs**: All infrastructure services (EKS, EC2, RDS, ElastiCache, VPC, ALBs, Data Transfer, Route 53, EBS PVCs)

### Calculation Notes

- All costs are monthly estimates
- Annual costs assume 12 months of operation
- Costs may vary based on:
  - Actual usage patterns
  - Reserved Instance commitments
  - Data transfer volumes
  - Scaling requirements
  - AWS pricing changes

---

## 🔍 Cost Monitoring & Alerts

### Recommended AWS Cost Management Tools

1. **AWS Cost Explorer**
   - Track spending by service, tag, or time period
   - Forecast future costs
   - Identify cost anomalies

2. **AWS Budgets**
   - Set monthly cost budgets
   - Configure alerts at 50%, 80%, and 100% thresholds
   - Track actual vs. forecasted costs

3. **AWS Cost Anomaly Detection**
   - Automatically detect unusual spending
   - Get alerts for unexpected cost increases

### Recommended Budget Alerts

- **Monthly Budget**: $450 USD (2% buffer)
- **Alert Thresholds**:
  - 50% of budget: $225 USD
  - 80% of budget: $360 USD
  - 100% of budget: $450 USD

---

## 📊 Cost Comparison: On-Demand vs. Reserved

| Service | On-Demand | 1-Year Reserved | 3-Year Reserved | Savings |
|---------|-----------|-----------------|-----------------|---------|
| EC2 (4× t3a.medium) | $64.20 | ~$38.00 | ~$26.00 | 40-60% |
| RDS (MySQL + PostgreSQL) | $30.15 | ~$18.00 | ~$12.00 | 40-60% |
| ElastiCache (2 nodes) | $49.64 | ~$30.00 | ~$20.00 | 40-60% |
| **Total Compute/Data** | **$144.99** | **~$86.00** | **~$58.00** | **40-60%** |

**Note**: Reserved Instances require upfront commitment but provide significant savings for predictable workloads.

---

## 🎯 Cost Optimization Roadmap

### Phase 1: Immediate (Month 1-3)
- ✅ Monitor actual usage and costs
- ✅ Set up AWS Budgets and alerts
- ✅ Review and optimize data transfer

### Phase 2: Short-term (Month 4-6)
- 🔄 Purchase Reserved Instances for EC2
- 🔄 Purchase Reserved Instances for RDS
- 🔄 Optimize ALB configuration

### Phase 3: Long-term (Month 7-12)
- 🔄 Evaluate ElastiCache Reserved Nodes
- 🔄 Implement CloudFront CDN
- 🔄 Database optimization and cleanup
- 🔄 Consider Spot Instances for non-critical workloads

---

## 📚 Additional Resources

- [AWS Pricing Calculator](https://calculator.aws/)
- [AWS Cost Management](https://aws.amazon.com/aws-cost-management/)
- [AWS Well-Architected Framework - Cost Optimization Pillar](https://docs.aws.amazon.com/wellarchitected/latest/cost-optimization-pillar/welcome.html)
- [AWS Pricing Calculator Guide](./AWS-PRICING-CALCULATOR-GUIDE.md) - Step-by-step instructions for cost estimation

---

## 📅 Last Updated

**Date**: December 2024  
**Region**: us-east-1 (N. Virginia)  
**Project**: JobApp - Marketplace Platform  
**Status**: Production Ready

---

**Note**: These are estimated costs based on AWS Pricing Calculator. Actual costs may vary based on usage patterns, traffic volume, and AWS pricing changes. Regular monitoring and optimization are recommended.

