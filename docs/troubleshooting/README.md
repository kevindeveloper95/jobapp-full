# Troubleshooting Guide

This directory contains consolidated troubleshooting guides for common issues across the JobApp infrastructure.

## 📋 Contents

- [EKS Cluster Issues](./EKS.md) - Cluster, nodegroups, and kubectl connectivity
- [Networking Issues](./Networking.md) - VPC, subnets, NAT Gateway, DNS
- [Security & IAM Issues](./Security.md) - IAM roles, Security Groups, Secrets
- [Database Issues](./Databases.md) - Database connectivity and persistence
- [DNS & Route53 Issues](./DNS.md) - DNS resolution, certificates, CloudFront

## Quick Reference

| Category | Common Issues |
|----------|---------------|
| **EKS** | kubectl connection, nodes not appearing, pods pending |
| **Networking** | Internet access, NAT Gateway, DNS resolution |
| **Security** | IAM roles, Security Groups, Secrets |
| **Databases** | Connection failures, data persistence |
| **DNS** | Certificate validation, DNS propagation, CloudFront |

---

**Note**: For detailed setup and configuration guides, see the main infrastructure documentation in `jobber-k8s/AWS/infrastructure/`.

