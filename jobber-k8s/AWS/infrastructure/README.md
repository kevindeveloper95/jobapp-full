# Infraestructura AWS - Jobber

Este directorio contiene la documentación y configuración de la infraestructura AWS para el proyecto Jobber.

---

## 📋 Índice de Documentación

### 1. [Networking (VPC, Subnets, Security Groups)](README-NETWORKING.md)
- Configuración de VPC
- Subnets públicas y privadas
- Security Groups
- NAT Gateway (si aplica)

### 2. [EKS Cluster Setup](README-EKS.md)
- Creación del clúster EKS
- Configuración de nodegroups
- Comandos de instalación y verificación

### 2.1. [EKS Command Reference](EKS-COMMAND-REFERENCE.md)
- Referencia rápida de comandos eksctl
- Gestión de IAM Service Accounts
- Instalación de controladores y add-ons
- Comandos de escalado y operaciones

### 3. [Bases de Datos](README-DATABASES.md)
- RDS (si se usa)
- ElastiCache (si se usa)
- Bases de datos en Kubernetes
- Decisiones arquitectónicas

### 4. [Seguridad](README-SECURITY.md)
- IAM Roles y Policies
- IRSA (IAM Roles for Service Accounts)
- Secrets Management
- Security Groups críticos

### 5. [DNS y Route 53](README-DNS-ROUTE53.md)
- Configuración de Route 53 Hosted Zone
- Configuración del dominio original
- Certificados SSL/TLS con ACM (wildcards)
- CloudFront Distribution
- Registros DNS y verificación

### 6. [Costos y Recursos](COSTOS-Y-RECURSOS.md)
- Planificación de capacidad
- Cálculo de recursos requeridos
- Comparación de escenarios (Producción vs Demo)
- Estrategias de optimización de costos

### 7. [Troubleshooting](../../../docs/troubleshooting/README.md)
- Guías de solución de problemas comunes
- Comandos de diagnóstico
- Problemas resueltos por categoría

---

## 🏗️ Estructura de Archivos

```
infrastructure/
├── README.md                    ← Este archivo (índice)
├── README-NETWORKING.md         ← Networking y VPC
├── README-EKS.md               ← EKS Cluster (guía completa)
├── EKS-COMMAND-REFERENCE.md    ← Referencia rápida de comandos EKS
├── README-DATABASES.md         ← Bases de datos
├── README-SECURITY.md          ← Seguridad e IAM
├── README-DNS-ROUTE53.md       ← DNS, Route 53, CloudFront y Certificados
├── COSTOS-Y-RECURSOS.md        ← Planificación de costos y recursos
└── eksctl-config.yaml          ← Configuración de eksctl (opcional)
```

---

## 🚀 Quick Start

1. Revisar [README-NETWORKING.md](README-NETWORKING.md) para entender la arquitectura de red
2. Seguir [README-EKS.md](README-EKS.md) para crear el clúster
3. Configurar seguridad según [README-SECURITY.md](README-SECURITY.md)
4. Revisar [README-DATABASES.md](README-DATABASES.md) para bases de datos
5. Configurar DNS y certificados según [README-DNS-ROUTE53.md](README-DNS-ROUTE53.md)

**¿Problemas?** Consulta la [Guía de Troubleshooting](../../../docs/troubleshooting/README.md) para soluciones rápidas.

---

## 📝 Notas

- Esta documentación asume conocimiento básico de AWS y Kubernetes
- Todos los comandos están probados en `us-east-1` (ajustar región si es necesario)
- Para desarrollo local, ver `../minikube/`

---

## 🔗 Referencias

- [Documentación AWS EKS](https://docs.aws.amazon.com/eks/)
- [eksctl Documentation](https://eksctl.io/)
- [AWS VPC Documentation](https://docs.aws.amazon.com/vpc/)




