# 💰 AWS Pricing Calculator Guide - JobApp

This guide provides step-by-step instructions on how to estimate all infrastructure costs for the JobApp project using the [AWS Pricing Calculator](https://calculator.aws/).

---

## 📋 Table of Contents

1. [Cost Summary](#cost-summary)
2. [Already Estimated Services](#already-estimated-services)
   - A. [VPC + NAT Gateway](#a-vpc--nat-gateway)
   - B. [EKS Cluster](#b-eks-cluster-control-plane)
   - C. [EKS Node Groups](#c-eks-node-groups-ec2-instances)
   - D. [EBS Volumes EKS](#d-ebs-volumes-for-eks-nodes)
   - E. [RDS MySQL](#e-rds-mysql)
   - F. [RDS PostgreSQL](#f-rds-postgresql)
   - G. [ElastiCache Redis](#g-elasticache-redis)
3. [Services Pending Estimation](#services-pending-estimation)
4. [Step-by-Step Instructions by Service](#step-by-step-instructions-by-service)
   - 1. [Application Load Balancers](#1-application-load-balancers-4x)
   - 2. [Route 53 Hosted Zones](#2-route-53-hosted-zones)
   - 3. [EBS Volumes for PVCs](#3-ebs-volumes-for-pvcs)
   - 4. [Data Transfer OUT](#4-data-transfer-out)
   - 5. [Data Transfer BETWEEN AZs](#5-data-transfer-between-availability-zones)
   - 6. [Route 53 DNS Queries](#6-route-53-dns-queries)
5. [Summary Table](#summary-table)
6. [Checklist](#estimation-checklist)

---

## ✅ Already Estimated Services

These services have already been estimated. Below are the complete instructions on how to estimate them in the AWS Calculator with all fields and values:

---

### A. VPC + NAT Gateway

**Purpose:** Private virtual network with internet access for all services. The NAT Gateway allows resources in private subnets to access the internet securely.

**Code location:** `modules/vpc/main.tf` lines 2, 16, 164

#### Steps in AWS Calculator:

1. **Search:** "NAT Gateway" or "Amazon VPC"
2. **Select:** "Amazon VPC" → "NAT Gateway"
3. **Configure:**
   - **Description:** `NAT Gateway - JobApp VPC`
   - **Region:** `US East (N. Virginia)` or `us-east-1`
   - **Number of NAT Gateways:** `1`
   - **Number of hours per month:** `730` (24/7)
   - **Data processed (GB per month):** Estimate outbound traffic
     - **Value:** `100` (conservative estimate)
     - **Unit:** `GB per month`
   - **Elastic IP:** `1` (associated with NAT Gateway, free if in use)

4. **Expected result:** ~$35/month
   - NAT Gateway: $0.045/hour × 730 hours = $32.85/month
   - Data processed: ~$2-3/month additional

**Note:** VPC, Internet Gateway, Subnets, and Route Tables are **free** (no need to calculate).

---

### B. EKS Cluster (Control Plane)

**Purpose:** Managed Kubernetes service that orchestrates containers, manages the API Server, etcd, scheduler, and controllers.

**Code location:** `modules/eks/main.tf` line 10

#### Steps in AWS Calculator:

1. **Search:** "Amazon EKS" or "Elastic Kubernetes Service"
2. **Select:** "Amazon EKS"
3. **Configure:**
   - **Description:** `EKS Cluster - JobApp`
   - **Region:** `US East (N. Virginia)`
   - **Number of EKS clusters:** `1`
   - **Number of hours per month:** `730` (24/7)
   - **Kubernetes version:** `1.28` (or the version you use)
   - **Control plane logging:** Optional (may generate additional CloudWatch costs)

4. **Expected result:** ~$73/month
   - Control Plane: $0.10/hour × 730 hours = **$73.00/month**

---

### C. EKS Node Groups (EC2 Instances)

**Purpose:** EC2 instances that run Kubernetes pods (applications, microservices).

**Code location:** `modules/eks/main.tf` line 59, `terraform.tfvars.example` lines 51-66

#### Steps in AWS Calculator:

1. **Search:** "Amazon EC2" or "EC2"
2. **Select:** "Amazon EC2"
3. **Configure:**
   - **Description:** `EKS Node Groups - JobApp (4 nodes t3a.medium)`
   - **Region:** `US East (N. Virginia)`
   - **Operating System:** `Linux`
   - **Tenancy:** `Shared`
   - **Instance type:** `t3a.medium`
   - **Number of instances:** `4`
   - **Number of hours per month:** `730` (24/7)
   - **Purchase option:** `On-Demand` (or `Reserved` if you plan to use RI)

4. **Expected result:** ~$64.20/month
   - 4 × t3a.medium: 4 × $0.022/hour × 730 hours = **$64.20/month**
   - Plus EBS volumes (see next section)

---

### D. EBS Volumes for EKS Nodes

**Purpose:** Storage for EKS node disks (operating system and temporary data).

**Code location:** `terraform.tfvars.example` line 58

#### Steps in AWS Calculator:

1. **Search:** "Amazon EBS" or "EBS"
2. **Select:** "Amazon EBS"
3. **Configure:**
   - **Description:** `EBS Volumes - EKS Node Root Disks`
   - **Region:** `US East (N. Virginia)`
   - **Volume type:** `General Purpose SSD (gp3)`
   - **Size:** `20`
   - **Unit:** `GB`
   - **Number of volumes:** `4` (one per node)
   - **Snapshot:** `No` (optional, if you create snapshots it adds cost)

4. **Expected result:** ~$8/month
   - 4 volumes × 20 GB × $0.10/GB-month = **$8.00/month**

---

### E. RDS MySQL

**Purpose:** Relational MySQL database for the authentication service (auth-service).

**Code location:** `modules/rds-aurora-mysql/main.tf`, `terraform.tfvars.example` lines 18-24

#### Steps in AWS Calculator:

1. **Search:** "Amazon RDS" or "RDS"
2. **Select:** "Amazon RDS"
3. **Configure:**
   - **Description:** `RDS MySQL - JobApp Auth Service`
   - **Region:** `US East (N. Virginia)`
   - **Database engine:** `MySQL`
   - **Deployment option:** `Single-AZ` (or `Multi-AZ` if you need high availability)
   - **DB instance class:** `db.t3.micro`
   - **Number of DB instances:** `1`
   - **Number of hours per month:** `730` (24/7)
   - **Allocated storage:** `20`
   - **Unit:** `GB`
   - **Storage type:** `General Purpose SSD (gp3)`
   - **Backup storage:** `7 days retention`
     - Estimate backup size (typically 20% of storage)
     - **Value:** `4` GB (estimate)
   - **Backup window:** `03:00-04:00 UTC` (optional for calculator)

4. **Expected result:** ~$15/month
   - db.t3.micro instance: $0.017/hour × 730 hours = $12.41/month
   - gp3 Storage: 20 GB × $0.115/GB-month = $2.30/month
   - Backups: ~$0.30/month
   - **Total: ~$15/month**

---

### F. RDS PostgreSQL

**Purpose:** Relational PostgreSQL database for the reviews service (analytics).

**Code location:** `modules/rds-aurora-postgresql/main.tf`, `terraform.tfvars.example` lines 27-33

#### Steps in AWS Calculator:

1. **Search:** "Amazon RDS" or "RDS"
2. **Select:** "Amazon RDS"
3. **Configure:**
   - **Description:** `RDS PostgreSQL - JobApp Review Service`
   - **Region:** `US East (N. Virginia)`
   - **Database engine:** `PostgreSQL`
   - **Deployment option:** `Single-AZ` (or `Multi-AZ` if you need high availability)
   - **DB instance class:** `db.t3.micro`
   - **Number of DB instances:** `1`
   - **Number of hours per month:** `730` (24/7)
   - **Allocated storage:** `20`
   - **Unit:** `GB`
   - **Storage type:** `General Purpose SSD (gp3)`
   - **Backup storage:** `7 days retention`
     - **Value:** `4` GB (estimate)

4. **Expected result:** ~$15/month
   - db.t3.micro instance: $0.017/hour × 730 hours = $12.41/month
   - gp3 Storage: 20 GB × $0.115/GB-month = $2.30/month
   - Backups: ~$0.30/month
   - **Total: ~$15/month**

---

### G. ElastiCache Redis

**Purpose:** In-memory cache to improve performance (sessions, frequent data cache).

**Code location:** `modules/elasticache-redis/main.tf`, `terraform.tfvars.example` lines 92-101

#### Steps in AWS Calculator:

1. **Search:** "Amazon ElastiCache" or "ElastiCache"
2. **Select:** "Amazon ElastiCache"
3. **Configure:**
   - **Description:** `ElastiCache Redis - JobApp Cache`
   - **Region:** `US East (N. Virginia)`
   - **Cache engine:** `Redis`
   - **Node type:** `cache.t3.small`
   - **Number of nodes:** `2` (Multi-AZ for high availability)
   - **Number of hours per month:** `730` (24/7)
   - **Backup retention:** `7 days` (optional)
     - Estimate snapshot size
     - **Value:** `1` GB (conservative estimate)

4. **Expected result:** ~$50/month
   - 2 nodes cache.t3.small: 2 × $0.034/hour × 730 hours = **$49.64/month**

---

### H. Security Groups, IAM, ACM (Free)

These services **do not need to be calculated** because they are free:

- **Security Groups:** `modules/security-groups/main.tf` - Free
- **IAM Roles/Policies:** `modules/eks/iam.tf` - Free
- **ACM Certificates:** `main.tf` lines 378-412 - Free
- **VPC, Subnets, Route Tables:** `modules/vpc/main.tf` - Free
- **Internet Gateway:** `modules/vpc/main.tf` line 16 - Free

---

### Summary Table of Already Estimated Services:

| # | Service | Cost/Month | Instructions |
|---|---|---|---|
| 1 | NAT Gateway | $35.10 | [See instructions above](#a-vpc--nat-gateway) |
| 2 | EKS Cluster | $73.00 | [See instructions above](#b-eks-cluster-control-plane) |
| 3 | EKS Node Groups | $64.20 | [See instructions above](#c-eks-node-groups-ec2-instances) |
| 4 | EBS Volumes EKS | $8.00 | [See instructions above](#d-ebs-volumes-for-eks-nodes) |
| 5 | RDS MySQL | $14.71 | [See instructions above](#e-rds-mysql) |
| 6 | RDS PostgreSQL | $15.44 | [See instructions above](#f-rds-postgresql) |
| 7 | ElastiCache Redis | $49.64 | [See instructions above](#g-elasticache-redis) |
| 8 | VPC, IAM, ACM, etc. | $0.00 | Free (no calculation needed) |

**Subtotal Already Estimated Services: ~$260.09/month**

---

## ❌ Services Pending Estimation

Use the AWS Calculator to estimate these services:

### High Priority (Needed for production)
1. ✅ [Application Load Balancers (4x)](#1-application-load-balancers-4x) - **COMPLETED**
2. ⬜ [Route 53 Hosted Zones (2x)](#2-route-53-hosted-zones)
3. ⬜ [EBS Volumes for PVCs](#3-ebs-volumes-for-pvcs)
4. ⬜ [Data Transfer OUT](#4-data-transfer-out)
5. ⬜ [Data Transfer BETWEEN AZs](#5-data-transfer-between-availability-zones)

### Medium Priority (Operational)
6. ⬜ [Route 53 DNS Queries](#6-route-53-dns-queries)

---

## 📝 Step-by-Step Instructions by Service

### 1. Application Load Balancers (4x) ✅

**Purpose:** Distribute incoming traffic to services in EKS (frontend, API, monitoring).

**Quantity:** 4 total ALBs:
- Frontend: `jobber-frontend-ingress`
- Gateway/API: `jobber-gateway-ingress`
- Prometheus: `jobber-prometheus-ingress`
- Grafana: `jobber-grafana-ingress`

**Code location:** `jobber-k8s/AWS/0-frontend/ingress.yaml`, `1-gateway/ingress.yaml`, etc.

#### Steps in AWS Calculator:

1. **Search:** "Elastic Load Balancing" or "Application Load Balancer"
2. **Select:** "Elastic Load Balancing" → "Application Load Balancer"
3. **Configure:**
   - **Description:** `ALBs - JobApp (4 Load Balancers)`
   - **Region:** `US East (N. Virginia)` or `us-east-1`
   - **Number of Application Load Balancers:** `4`

   #### LCU Configuration (Load Balancer Capacity Units):

   **Bytes processed (EC2 instances and IP addresses as targets):**
   - **Value:** `460`
   - **Unit:** `GB per month`
   - **Breakdown:**
     - Frontend: 100 GB/month
     - Gateway: 300 GB/month
     - Prometheus: 30 GB/month
     - Grafana: 30 GB/month

   **Average number of new connections per ALB:**
   - **Value:** `105`
   - **Unit:** `per second`
   - **Calculation:** (100 + 300 + 10 + 10) / 4 = 105 average
   - **Breakdown:**
     - Frontend: 100 connections/sec
     - Gateway: 300 connections/sec
     - Prometheus: 10 connections/sec
     - Grafana: 10 connections/sec

   **Average connection duration:**
   - **Value:** `60`
   - **Unit:** `seconds`

   **Average number of requests per second per ALB:**
   - **Value:** `600`
   - **Unit:** `per second`
   - **Breakdown:**
     - Frontend: ~500 req/sec
     - Gateway: ~2000 req/sec
     - Prometheus: ~100 req/sec
     - Grafana: ~100 req/sec
     - Average: 600 req/sec

   **Average number of rule evaluations per request:**
   - **Value:** `0.1`
   - (1 rule every 10 requests on average)

4. **Expected result:** ~$163.81/month for the 4 ALBs

---

### 2. Route 53 Hosted Zones

**Purpose:** DNS management for JobApp domains (name-to-IP resolution).

**Quantity:** 2 Hosted Zones:
- `jobberapp.kevmendeveloper.com`
- `api.jobberapp.kevmendeveloper.com`

**Code location:** `main.tf` lines 298-324

#### Steps in AWS Calculator:

1. **Search:** "Route 53" or "Amazon Route 53"
2. **Select:** "Amazon Route 53"
3. **Configure:**
   - **Description:** `Route 53 - JobApp Hosted Zones`
   - **Region:** `US East (N. Virginia)`

   **Hosted Zones:**
   - **Number of hosted zones:** `2`
   - **Cost:** $0.50/month per hosted zone = **$1.00/month**

4. **Expected result:** ~$1.00/month (hosted zones) + additional queries

---

### 3. EBS Volumes for PVCs

**Purpose:** Persistent storage for databases and queues in Kubernetes (MySQL, PostgreSQL, MongoDB, RabbitMQ).

**Total quantity:** 18 GB
- MySQL PVC: 5 GB
- PostgreSQL PVC: 5 GB
- MongoDB StatefulSet: 5 GB
- RabbitMQ PVC: 3 GB

**Code location:** `jobber-k8s/AWS/` (StatefulSets/PVCs manifests)

#### Steps in AWS Calculator:

1. **Search:** "Amazon EBS" or "EBS"
2. **Select:** "Amazon EBS"
3. **Configure:**
   - **Description:** `EBS Volumes - Kubernetes PVCs`
   - **Region:** `US East (N. Virginia)`
   - **Volume type:** `General Purpose SSD (gp3)`
   - **Size:** `18`
   - **Unit:** `GB`
   - **Number of volumes:** `1` (or the number of PVCs you have)
   - **Snapshot:** `No` (optional, if you create snapshots it adds cost)

4. **Expected result:** ~$1.80/month (18 GB × $0.10/GB-month)

---

### 4. Data Transfer OUT

**Purpose:** Data traffic leaving AWS to the internet (users accessing the application).

**Estimated quantity:** Variable based on traffic

#### Steps in AWS Calculator:

1. **Search:** "Data Transfer" or "EC2 Data Transfer"
2. **Select:** "Data Transfer" or "Amazon EC2 Data Transfer"
3. **Configure:**
   - **Description:** `Data Transfer OUT - JobApp`
   - **Region:** `US East (N. Virginia)`

   **Data Transfer OUT to Internet:**
   - **First 100 GB per month:** Free
   - **Next 40 TB per month (100 GB - 10 TB):** $0.09 per GB
   - **Value:** Estimate based on your expected traffic
     - **Low traffic:** 200-300 GB/month → ~$10-20/month (after the first 100 GB free)
     - **Moderate:** 500-1000 GB/month → ~$36-81/month
     - **High traffic:** 2000+ GB/month → ~$171+/month

   **Recommendation:** Start with **500 GB/month** for conservative estimate
   - **Value:** `500`
   - **Unit:** `GB per month`
   - **Estimated cost:** ~$36/month (first 100 GB free, then $0.09/GB)

4. **Expected result:** ~$20/month (depending on traffic)

---

### 5. Data Transfer BETWEEN Availability Zones

**Purpose:** Communication between services in different AZs (e.g., EKS nodes in different zones, database replicas).

**Estimated quantity:** Variable based on architecture

#### Steps in AWS Calculator:

1. **Search:** "Data Transfer" or "EC2 Data Transfer"
2. **Select:** "Data Transfer" or "Amazon EC2 Data Transfer"
3. **Configure:**
   - **Description:** `Data Transfer BETWEEN AZs - JobApp`
   - **Region:** `US East (N. Virginia)`

   **Data Transfer BETWEEN Availability Zones (same region):**
   - **Price:** $0.01 per GB
   - **Value:** Estimate based on your architecture
     - **Low:** 100-200 GB/month → ~$1-2/month
     - **Moderate:** 500-1000 GB/month → ~$5-10/month
     - **High:** 1500+ GB/month → ~$15+/month

   **Recommendation:** Start with **500 GB/month**
   - **Value:** `500`
   - **Unit:** `GB per month`
   - **Estimated cost:** ~$5/month

4. **Expected result:** ~$20/month (combined with OUT)

---

### 6. Route 53 DNS Queries

**Purpose:** DNS queries (name-to-IP resolution) when users access your domain.

**Estimated quantity:** Variable based on traffic

#### Steps in AWS Calculator:

1. **Search:** "Route 53" or "Amazon Route 53"
2. **Select:** "Amazon Route 53"
3. **Configure:**
   - **Description:** `Route 53 DNS Queries - JobApp`
   - **Region:** `US East (N. Virginia)`

   **DNS Queries:**
   - **First 1 million queries per month:** Free
   - **Next queries:** $0.40 per million queries
   - **Number of queries:** Estimate based on your traffic
     - **Low traffic:** < 1M queries/month → **$0.00** (free)
     - **Moderate:** 2-5M queries/month → $0.40-1.60/month
     - **High traffic:** 10M+ queries/month → $3.60+/month

   **Recommendation:** Start with **2 million queries/month**
   - **Value:** `2000000`
   - **Cost:** First million free, 1M additional × $0.40 = **$0.40/month**

4. **Expected result:** ~$0-5/month (probably free if you have < 1M queries)

---

## 📊 Summary Table

### Already Estimated Services:

| # | Service | Status | Estimated Cost/Month | Instructions |
|---|---|---|---|
| A | NAT Gateway | ✅ COMPLETED | $35.10 | [Section A](#a-vpc--nat-gateway) |
| B | EKS Cluster | ✅ COMPLETED | $73.00 | [Section B](#b-eks-cluster-control-plane) |
| C | EKS Node Groups | ✅ COMPLETED | $64.20 | [Section C](#c-eks-node-groups-ec2-instances) |
| D | EBS Volumes EKS | ✅ COMPLETED | $8.00 | [Section D](#d-ebs-volumes-for-eks-nodes) |
| E | RDS MySQL | ✅ COMPLETED | $14.71 | [Section E](#e-rds-mysql) |
| F | RDS PostgreSQL | ✅ COMPLETED | $15.44 | [Section F](#f-rds-postgresql) |
| G | ElastiCache Redis | ✅ COMPLETED | $49.64 | [Section G](#g-elasticache-redis) |
| - | VPC, IAM, ACM, etc. | ✅ COMPLETED | $0.00 | Free (no calculation needed) |

**Total Already Estimated: ~$260.09/month**

### Services Pending:

| # | Service | Status | Estimated Cost/Month | Priority | Instructions |
|---|---|---|---|---|---|
| 1 | Application Load Balancers (4x) | ✅ COMPLETED | $163.81 | High | [Section 1](#1-application-load-balancers-4x) |
| 2 | Route 53 Hosted Zones (2x) | ⬜ Pending | $1.00 | High | [Section 2](#2-route-53-hosted-zones) |
| 3 | EBS Volumes (PVCs - 18GB) | ⬜ Pending | $1.80 | High | [Section 3](#3-ebs-volumes-for-pvcs) |
| 4 | Data Transfer OUT | ⬜ Pending | $20.00 | High | [Section 4](#4-data-transfer-out) |
| 5 | Data Transfer BETWEEN AZs | ⬜ Pending | $20.00 | High | [Section 5](#5-data-transfer-between-availability-zones) |
| 6 | Route 53 DNS Queries | ⬜ Pending | $0-5 | Medium | [Section 6](#6-route-53-dns-queries) |

**Total Pending: ~$186-191/month**

**Total Estimated: ~$440.94/month**

---

## ✅ Estimation Checklist

### Already Estimated Services:
- [x] NAT Gateway - **COMPLETED** (See [Section A](#a-vpc--nat-gateway))
- [x] EKS Cluster - **COMPLETED** (See [Section B](#b-eks-cluster-control-plane))
- [x] EKS Node Groups - **COMPLETED** (See [Section C](#c-eks-node-groups-ec2-instances))
- [x] EBS Volumes EKS - **COMPLETED** (See [Section D](#d-ebs-volumes-for-eks-nodes))
- [x] RDS MySQL - **COMPLETED** (See [Section E](#e-rds-mysql))
- [x] RDS PostgreSQL - **COMPLETED** (See [Section F](#f-rds-postgresql))
- [x] ElastiCache Redis - **COMPLETED** (See [Section G](#g-elasticache-redis))

### Services Pending:
- [x] Application Load Balancers (4x) - **COMPLETED** (See [Section 1](#1-application-load-balancers-4x))
- [ ] Route 53 Hosted Zones (2x) - See [Section 2](#2-route-53-hosted-zones)
- [ ] EBS Volumes for PVCs (18GB) - See [Section 3](#3-ebs-volumes-for-pvcs)
- [ ] Data Transfer OUT - See [Section 4](#4-data-transfer-out)
- [ ] Data Transfer BETWEEN AZs - See [Section 5](#5-data-transfer-between-availability-zones)
- [ ] Route 53 DNS Queries - See [Section 6](#6-route-53-dns-queries)

---

## 📝 Important Notes

1. **Region:** All services should be configured in `US East (N. Virginia)` or `us-east-1`

2. **Conservative values:** The values here are conservative estimates. You can adjust them based on your actual traffic.

3. **Variable costs:** Some services (Data Transfer, DNS Queries) depend heavily on actual traffic. Monitor and adjust.

4. **Free services:** Route 53 queries (first 1M) and many basic services are free up to a certain limit.

5. **Export estimate:** Once completed, you can export the estimate from the calculator to document it.

---

## 🔗 Useful Links

- [AWS Pricing Calculator](https://calculator.aws/)
- [AWS Pricing by service](https://aws.amazon.com/pricing/)
- [EKS Pricing](https://aws.amazon.com/eks/pricing/)
- [RDS Pricing](https://aws.amazon.com/rds/pricing/)
- [ALB Pricing](https://aws.amazon.com/elasticloadbalancing/pricing/)

---

**Last updated:** December 2024  
**Region:** us-east-1 (US East N. Virginia)  
**Project:** JobApp - Marketplace Platform

