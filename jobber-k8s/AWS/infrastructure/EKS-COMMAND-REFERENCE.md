# EKS Command Reference - Jobber

Este documento contiene una referencia rápida de comandos útiles para gestionar el clúster EKS. Para una guía completa de setup, ver [README-EKS.md](./README-EKS.md).

---

## 📋 Tabla de Contenidos

1. [Creación del Clúster](#1-creación-del-clúster)
2. [Configuración de IAM y OIDC](#2-configuración-de-iam-y-oidc)
3. [Gestión de Nodegroups](#3-gestión-de-nodegroups)
4. [IAM Service Accounts](#4-iam-service-accounts)
5. [Controladores y Add-ons](#5-controladores-y-add-ons)
6. [Monitoreo (Prometheus/Grafana)](#6-monitoreo-prometheusgrafana)
7. [Gestión de Secrets](#7-gestión-de-secrets)
8. [Escalado y Operaciones](#8-escalado-y-operaciones)
9. [Eliminación y Limpieza](#9-eliminación-y-limpieza)

---

## 1. Creación del Clúster

### 1.1. Crear Clúster sin Nodegroup

```bash
eksctl create cluster \
  --name=<cluster-name> \
  --region=<aws-region> \
  --vpc-private-subnets=<subnet-id-1>,<subnet-id-2> \
  --without-nodegroup
```

**Nota**: Reemplazar `<subnet-id-1>`, `<subnet-id-2>` con los IDs de tus subnets privadas.

### 1.2. Crear Nodegroup con Permisos Completos

```bash
eksctl create nodegroup \
  --cluster=<cluster-name> \
  --region=<aws-region> \
  --name=<nodegroup-name> \
  --subnet-ids=<subnet-id-1>,<subnet-id-2> \
  --node-type=t3a.medium \
  --nodes=1 \
  --nodes-min=0 \
  --nodes-max=1 \
  --node-volume-size=20 \
  --ssh-access \
  --ssh-public-key=<your-ssh-key-name> \
  --managed \
  --asg-access \
  --external-dns-access \
  --full-ecr-access \
  --appmesh-access \
  --alb-ingress-access \
  --node-private-networking
```

**Parámetros importantes**:
- `--asg-access`: Permite acceso a Auto Scaling Groups (necesario para Cluster Autoscaler)
- `--external-dns-access`: Permite actualizar Route 53 (necesario para External DNS)
- `--full-ecr-access`: Permite pull de imágenes de ECR
- `--alb-ingress-access`: Permite crear ALBs (necesario para ALB Ingress Controller)
- `--node-private-networking`: Nodos en subnets privadas (más seguro)

---

## 2. Configuración de IAM y OIDC

### 2.1. Asociar OIDC Provider

```bash
eksctl utils associate-iam-oidc-provider \
  --region=<aws-region> \
  --cluster=<cluster-name> \
  --approve
```

**Propósito**: Necesario para usar IAM Service Accounts (IRSA) que permiten que pods accedan a servicios de AWS sin credenciales hardcodeadas.

### 2.2. Verificar OIDC Provider

```bash
aws eks describe-cluster \
  --name <cluster-name> \
  --region <aws-region> \
  --query "cluster.identity.oidc.issuer" \
  --output text
```

---

## 3. Gestión de Nodegroups

### 3.1. Escalar Nodegroup

```bash
# Escalar a número específico de nodos
eksctl scale nodegroup \
  --cluster=<cluster-name> \
  --name=<nodegroup-name> \
  --nodes=2 \
  --region=<aws-region>

# Escalar con límites min/max
eksctl scale nodegroup \
  --cluster=<cluster-name> \
  --name=<nodegroup-name> \
  --nodes=2 \
  --nodes-min=0 \
  --nodes-max=2 \
  --region=<aws-region>
```

### 3.2. Listar Nodegroups

```bash
eksctl get nodegroup \
  --cluster=<cluster-name> \
  --region=<aws-region>
```

### 3.3. Eliminar Nodegroup

```bash
eksctl delete nodegroup \
  --cluster=<cluster-name> \
  --name=<nodegroup-name> \
  --region=<aws-region>
```

---

## 4. IAM Service Accounts

### 4.1. AWS Load Balancer Controller

```bash
eksctl create iamserviceaccount \
  --cluster=<cluster-name> \
  --namespace=kube-system \
  --name=aws-load-balancer-controller \
  --attach-policy-arn=arn:aws:iam::<account-id>:policy/AWSLoadBalancerControllerIAMPolicy \
  --override-existing-serviceaccounts \
  --region=<aws-region> \
  --approve
```

**Nota**: Reemplazar `<account-id>` con tu AWS Account ID. La política debe crearse primero (ver [README-SECURITY.md](./README-SECURITY.md)).

### 4.2. External DNS (para Gateway)

```bash
eksctl create iamserviceaccount \
  --name=gateway-external-dns \
  --namespace=default \
  --cluster=<cluster-name> \
  --attach-policy-arn=arn:aws:iam::<account-id>:policy/AllowExternalDNSUpdates \
  --approve \
  --override-existing-serviceaccounts
```

### 4.3. External DNS (para Frontend)

```bash
eksctl create iamserviceaccount \
  --name=frontend-external-dns \
  --namespace=production \
  --cluster=<cluster-name> \
  --attach-policy-arn=arn:aws:iam::<account-id>:policy/AllowExternalDNSUpdates \
  --approve \
  --override-existing-serviceaccounts
```

### 4.4. External DNS (para Prometheus)

```bash
eksctl create iamserviceaccount \
  --name=prometheus-external-dns \
  --namespace=prometheus \
  --cluster=<cluster-name> \
  --attach-policy-arn=arn:aws:iam::<account-id>:policy/AllowExternalDNSUpdates \
  --approve \
  --override-existing-serviceaccounts
```

### 4.5. External DNS (para Grafana)

```bash
eksctl create iamserviceaccount \
  --name=grafana-external-dns \
  --namespace=grafana \
  --cluster=<cluster-name> \
  --attach-policy-arn=arn:aws:iam::<account-id>:policy/AllowExternalDNSUpdates \
  --approve \
  --override-existing-serviceaccounts
```

### 4.6. EBS CSI Driver

```bash
eksctl create iamserviceaccount \
  --name=ebs-csi-controller-sa \
  --namespace=kube-system \
  --cluster=<cluster-name> \
  --region=<aws-region> \
  --attach-policy-arn=arn:aws:iam::<account-id>:policy/Amazon_EBS_CSI_Driver \
  --approve
```

---

## 5. Controladores y Add-ons

### 5.1. AWS Load Balancer Controller

```bash
helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=<cluster-name> \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller \
  --set region=<aws-region> \
  --set vpcId=<vpc-id> \
  --set image.repository=602401143452.dkr.ecr.us-east-1.amazonaws.com/amazon/aws-load-balancer-controller
```

**Nota**: Reemplazar `<vpc-id>` con el ID de tu VPC.

### 5.2. EBS CSI Driver

```bash
helm install aws-ebs-csi-driver \
  aws-ebs-csi-driver/aws-ebs-csi-driver \
  --namespace kube-system \
  --set controller.serviceAccount.create=false \
  --set controller.serviceAccount.name=ebs-csi-controller-sa
```

---

## 6. Monitoreo (Prometheus/Grafana)

### 6.1. Instalar Prometheus

```bash
# Instalación básica
helm upgrade -i prometheus prometheus-community/prometheus \
  --namespace prometheus \
  --create-namespace \
  --set alertmanager.persistence.storageClass="gp2" \
  --set server.persistentVolume.storageClass="gp2"

# Con NodePort (para acceso externo)
helm upgrade -i prometheus prometheus-community/prometheus \
  --namespace prometheus \
  --create-namespace \
  --set alertmanager.persistence.storageClass="gp2" \
  --set server.persistentVolume.storageClass="gp2" \
  --set prometheus.service.type=NodePort
```

### 6.2. Instalar Grafana

```bash
# 1. Crear StorageClass para Grafana (si no existe)
kubectl apply -f <path-to-grafana-storageclass.yaml>

# 2. Instalar Grafana
helm install grafana grafana/grafana \
  --namespace grafana \
  --create-namespace \
  --set persistence.enabled=true \
  --set persistence.storageClassName=grafana-storage \
  --set persistence.size=10Gi \
  --set adminPassword=<secure-password> \
  --set service.type=NodePort
```

**⚠️ IMPORTANTE**: Usar una contraseña segura. No hardcodear contraseñas en scripts que se suban a Git.

---

## 7. Gestión de Secrets

### 7.1. Crear Secret Genérico

```bash
kubectl create secret generic <secret-name> \
  --from-literal=key1='value1' \
  --from-literal=key2='value2' \
  --dry-run=client -o yaml | kubectl apply -f - -n <namespace>
```

**Ejemplo** (para servicio de notificaciones):
```bash
kubectl create secret generic jobber-backend-secret \
  --from-literal=sender-email='<email-address>' \
  --from-literal=sender-email-password='<email-password>' \
  --dry-run=client -o yaml | kubectl apply -f - -n production
```

**⚠️ IMPORTANTE**: 
- No incluir valores reales en scripts versionados
- Usar variables de entorno o secret managers (AWS Secrets Manager, HashiCorp Vault)
- Para producción, considerar usar External Secrets Operator

---

## 8. Escalado y Operaciones

### 8.1. Ver Estado del Clúster

```bash
# Ver información del clúster
eksctl get cluster --name=<cluster-name> --region=<aws-region>

# Ver todos los recursos
kubectl get all --all-namespaces

# Ver nodos y recursos
kubectl top nodes
```

### 8.2. Verificar Componentes

```bash
# Ver pods del sistema
kubectl get pods -n kube-system

# Ver pods de un namespace específico
kubectl get pods -n <namespace>

# Ver logs de un pod
kubectl logs -n <namespace> <pod-name>
```

---

## 9. Eliminación y Limpieza

### 9.1. Eliminar Clúster Completo

```bash
eksctl delete cluster \
  --name=<cluster-name> \
  --region=<aws-region>
```

**⚠️ ADVERTENCIA**: Esto elimina TODO el clúster y todos los recursos asociados.

### 9.2. Recursos Adicionales a Eliminar Manualmente

Después de eliminar el clúster, verificar y eliminar manualmente:

1. **NAT Gateway** (si existe)
   - AWS Console → VPC → NAT Gateways
   - Costo: ~$32/mes si está activo

2. **Elastic IP** (si no está asociada)
   - AWS Console → EC2 → Elastic IPs
   - Costo: ~$0.005/hora si no está asociada

3. **Bases de Datos**
   - RDS MySQL (si se usa)
   - RDS PostgreSQL (si se usa)
   - ElastiCache Redis (si se usa)

4. **Route 53 Hosted Zones**
   - AWS Console → Route 53 → Hosted Zones
   - Costo: ~$0.50/mes por hosted zone

5. **Load Balancers y Target Groups**
   - AWS Console → EC2 → Load Balancers
   - AWS Console → EC2 → Target Groups
   - Verificar que no haya recursos huérfanos

6. **Volúmenes EBS Huérfanos**
   - AWS Console → EC2 → Volumes
   - Buscar volúmenes con estado "available"

### 9.3. Script de Verificación Post-Eliminación

```bash
# Verificar que no queden recursos costosos
aws ec2 describe-nat-gateways --region <aws-region>
aws ec2 describe-addresses --region <aws-region>
aws rds describe-db-instances --region <aws-region>
aws elasticache describe-cache-clusters --region <aws-region>
aws route53 list-hosted-zones
aws elbv2 describe-load-balancers --region <aws-region>
```

---

## 🔒 Seguridad y Mejores Prácticas

### ✅ DO (Hacer)

1. **Usar IAM Service Accounts (IRSA)** en lugar de hardcodear credenciales
2. **Usar Secrets de Kubernetes** o External Secrets Operator
3. **Documentar todos los comandos** con placeholders
4. **Revisar permisos IAM** antes de crear service accounts
5. **Usar subnets privadas** para nodos (`--node-private-networking`)
6. **Rotar credenciales** regularmente
7. **Usar variables de entorno** para valores sensibles

### ❌ DON'T (No Hacer)

1. **NO hardcodear** contraseñas, tokens o credenciales en scripts
2. **NO subir** archivos con información sensible a Git
3. **NO usar** contraseñas débiles en producción
4. **NO compartir** ARNs de políticas con información de cuenta
5. **NO dejar** recursos huérfanos que generen costos

---

## 📚 Referencias

- [README-EKS.md](./README-EKS.md) - Guía completa de setup
- [README-SECURITY.md](./README-SECURITY.md) - Configuración de seguridad e IAM
- [eksctl Documentation](https://eksctl.io/)
- [AWS EKS Best Practices](https://aws.github.io/aws-eks-best-practices/)

---

**Última actualización**: Enero 2025

