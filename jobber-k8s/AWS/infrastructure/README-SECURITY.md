# Seguridad e IAM - Jobber

Esta guía documenta la configuración de seguridad, IAM roles, policies y gestión de secrets para el proyecto Jobber en AWS EKS.

---

## 📋 Tabla de Contenidos

1. [IAM Roles y Policies](#1-iam-roles-y-policies)
2. [IRSA (IAM Roles for Service Accounts)](#2-irsa-iam-roles-for-service-accounts)
3. [Secrets Management](#3-secrets-management)
4. [Security Groups](#4-security-groups)
5. [Network Policies](#5-network-policies)
6. [Mejores Prácticas de Seguridad](#6-mejores-prácticas-de-seguridad)

---

## 1. IAM Roles y Policies

### 1.1. Roles Requeridos

#### 1.1.1. Cluster Service Role

**Rol**: `eksClusterRole` (creado automáticamente por eksctl)

**Policies adjuntas:**
- `AmazonEKSClusterPolicy`
- `AmazonEKSServicePolicy`

**Verificar:**
```bash
aws iam list-roles --query 'Roles[?RoleName==`eksClusterRole`]'
```

#### 1.1.2. Node Group Role

**Rol**: Creado automáticamente por eksctl con formato `eksctl-<cluster-name>-nodegroup-<name>-NodeInstanceRole-xxxxx`

**Policies adjuntas:**
- `AmazonEKSWorkerNodePolicy`
- `AmazonEKS_CNI_Policy`
- `AmazonEC2ContainerRegistryReadOnly`
- `AmazonEKSClusterPolicy` (si se usa Cluster Autoscaler)

**Verificar:**
```bash
eksctl get iamidentitymapping --cluster <cluster-name> --region <region>
```

### 1.2. Policies Personalizadas

#### 1.2.1. EBS CSI Driver Policy

**Policy Name**: `Amazon_EBS_CSI_Driver`  
**Policy ARN**: `arn:aws:iam::<account-id>:policy/Amazon_EBS_CSI_Driver`  
**Type**: Customer managed

**Permisos:**
- **Service**: EC2
- **Access Level**: Limited (List, Write)
- **Resources**: All resources

**Propósito**: Esta policy permite que el EBS CSI Driver gestione volúmenes EBS (Elastic Block Store) en AWS. Es necesaria para que Kubernetes pueda crear, adjuntar, desadjuntar y eliminar volúmenes EBS cuando se crean PersistentVolumeClaims.

**Uso**: Esta policy se adjunta a un IAM Role que luego se asocia al ServiceAccount del EBS CSI Driver usando IRSA (IAM Roles for Service Accounts).

**Verificar Policy:**
```bash
# Ver detalles de la policy
aws iam get-policy --policy-arn arn:aws:iam::<account-id>:policy/Amazon_EBS_CSI_Driver --region <region>

# Ver versión de la policy
aws iam get-policy-version \
  --policy-arn arn:aws:iam::<account-id>:policy/Amazon_EBS_CSI_Driver \
  --version-id v1 \
  --region <region>

# Listar todas las policies personalizadas
aws iam list-policies --scope Local --query 'Policies[?PolicyName==`Amazon_EBS_CSI_Driver`]' --region <region>
```

**Nota**: Esta policy es necesaria antes de instalar el EBS CSI Driver en el clúster EKS. Sin esta policy, el driver no podrá crear volúmenes EBS para PersistentVolumes.

#### 1.2.2. Cluster Autoscaler Policy

**Ubicación**: Ver `../README-CLUSTER-AUTOSCALER.md`

**Permisos requeridos:**
- `autoscaling:DescribeAutoScalingGroups`
- `autoscaling:DescribeAutoScalingInstances`
- `autoscaling:DescribeLaunchConfigurations`
- `autoscaling:DescribeScalingActivities`
- `autoscaling:DescribeTags`
- `ec2:DescribeInstanceTypes`
- `ec2:DescribeLaunchTemplateVersions`

---

## 2. IRSA (IAM Roles for Service Accounts)

### 2.1. ¿Qué es IRSA?

IRSA permite que pods de Kubernetes asuman roles IAM de AWS sin necesidad de almacenar credenciales en el pod.

### 2.2. Configurar OIDC Provider

```bash
# Verificar si OIDC está configurado
aws eks describe-cluster --name <cluster-name> --region <region> --query "cluster.identity.oidc.issuer"

# Asociar OIDC provider (si no está configurado)
eksctl utils associate-iam-oidc-provider \
  --cluster <cluster-name> \
  --region <region> \
  --approve
```

### 2.3. Crear Service Account con IAM Role

**Ejemplo: Cluster Autoscaler**

```bash
eksctl create iamserviceaccount \
  --cluster <cluster-name> \
  --region <region> \
  --namespace kube-system \
  --name cluster-autoscaler \
  --attach-policy-arn arn:aws:iam::<account-id>:policy/<policy-name> \
  --approve \
  --override-existing-serviceaccounts
```

### 2.4. Verificar Service Accounts

```bash
# Ver Service Accounts con anotaciones IAM
kubectl get serviceaccounts -n <namespace> <service-account-name> -o yaml

# Debe incluir:
# annotations:
#   eks.amazonaws.com/role-arn: arn:aws:iam::<account-id>:role/<role-name>
```

---

## 3. Secrets Management

### 3.1. Kubernetes Secrets

**Uso**: Credenciales de bases de datos, API keys, etc.

**Crear Secret:**
```bash
kubectl create secret generic <secret-name> \
  --from-literal=<key>=<value> \
  --namespace <namespace>
```

**Usar en Deployment:**
```yaml
env:
  - name: <ENV_VAR>
    valueFrom:
      secretKeyRef:
        name: <secret-name>
        key: <key>
```

### 3.2. AWS Secrets Manager (Opcional)

**Ventajas:**
- Rotación automática
- Auditoría integrada
- Encriptación con KMS

**Crear Secret:**
```bash
aws secretsmanager create-secret \
  --name <secret-path> \
  --secret-string "<secret-value>" \
  --region <region>
```

**Usar desde Pod (requiere IRSA):**
```yaml
env:
  - name: <ENV_VAR>
    valueFrom:
      secretKeyRef:
        name: aws-secrets-manager
        key: <secret-path>
```

### 3.3. Encriptar Secrets en Repositorio

**⚠️ IMPORTANTE**: Nunca commitear secrets en texto plano.

**Opciones:**
- Usar `sealed-secrets` (Kubernetes)
- Usar `sops` (Mozilla)
- Usar `git-crypt`
- Usar AWS Secrets Manager + IRSA

---

## 4. Security Groups

### 4.1. Security Groups del Clúster

**Cluster Security Group:**
- Permite tráfico desde Node Security Group
- Puerto 443 (HTTPS) para control plane

**Node Security Group:**
- Permite tráfico entre nodos
- Permite tráfico desde Cluster Security Group

### 4.2. Verificar Security Groups del Clúster

```bash
# Obtener Security Group del clúster
CLUSTER_SG=$(aws eks describe-cluster --name <cluster-name> --region <region> --query "cluster.resourcesVpcConfig.clusterSecurityGroupId" --output text)

# Ver reglas
aws ec2 describe-security-groups --group-ids $CLUSTER_SG --region <region>

# Listar todos los Security Groups del clúster
aws ec2 describe-security-groups --filters "Name=tag:eks:cluster-name,Values=<cluster-name>" --region <region>
```

### 4.3. Security Groups de Bases de Datos

#### 4.3.1. MySQL Security Group

**Configuración típica:**
- **Puerto**: 3306
- **Protocolo**: TCP
- **Descripción**: Permite acceso a MySQL base de datos

**⚠️ Nota de Seguridad**: Para producción, restringir el acceso a Security Groups específicos de los servicios que necesitan acceder a MySQL, en lugar de permitir acceso amplio (`0.0.0.0/0`).

#### 4.3.2. PostgreSQL Security Group

**Configuración típica:**
- **Puerto**: 5432
- **Protocolo**: TCP
- **Descripción**: Permite acceso a PostgreSQL base de datos

**⚠️ Nota de Seguridad**: Para producción, restringir a protocolos y puertos específicos necesarios, en lugar de permitir todo el tráfico (`All traffic` a `0.0.0.0/0`).

#### 4.3.3. Redis Security Group

**Configuración típica:**
- **Puerto**: 6379
- **Protocolo**: TCP
- **Descripción**: Permite el acceso al cluster de Redis

**⚠️ Nota de Seguridad**: Para producción, restringir el acceso a Security Groups específicos de los servicios que necesitan acceder a Redis, en lugar de permitir acceso amplio (`0.0.0.0/0`).

### 4.4. Verificar Security Groups de Bases de Datos

```bash
# Ver Security Group
aws ec2 describe-security-groups --group-ids <sg-id> --region <region>

# Ver reglas de entrada
aws ec2 describe-security-groups --group-ids <sg-id> --query 'SecurityGroups[0].IpPermissions' --region <region>

# Ver reglas de salida
aws ec2 describe-security-groups --group-ids <sg-id> --query 'SecurityGroups[0].IpPermissionsEgress' --region <region>
```

### 4.5. Restringir Acceso

**Ejemplo: Restringir acceso SSH a tu IP**

```bash
# Obtener tu IP pública
MY_IP=$(curl -s https://checkip.amazonaws.com)

# Agregar regla al Security Group
aws ec2 authorize-security-group-ingress \
  --group-id <sg-id> \
  --protocol tcp \
  --port 22 \
  --cidr $MY_IP/32 \
  --region <region>
```

**Ejemplo: Restringir acceso a base de datos desde Security Group específico**

```bash
# Permitir acceso solo desde el Security Group del servicio
aws ec2 authorize-security-group-ingress \
  --group-id <sg-database-id> \
  --protocol tcp \
  --port <database-port> \
  --source-group <sg-service-id> \
  --region <region>
```

---

## 5. Network Policies

### 5.1. ¿Qué son Network Policies?

Permiten controlar el tráfico de red entre pods en Kubernetes.

### 5.2. Ejemplo: Aislar Namespace

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny-all
  namespace: <namespace>
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
```

### 5.3. Ejemplo: Permitir Tráfico entre Microservicios

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-gateway-to-services
  namespace: <namespace>
spec:
  podSelector:
    matchLabels:
      app: <gateway-app>
  policyTypes:
  - Egress
  egress:
  - to:
    - podSelector:
        matchLabels:
          app: <service-app>
    ports:
    - protocol: TCP
      port: <service-port>
```

**Nota**: Requiere un CNI que soporte Network Policies (Calico, Cilium, etc.). VPC CNI de AWS tiene soporte limitado.

---

## 6. Mejores Prácticas de Seguridad

### 6.1. IAM

- ✅ Usar IRSA en lugar de almacenar credenciales en pods
- ✅ Aplicar principio de menor privilegio
- ✅ Revisar y auditar policies regularmente
- ✅ Usar roles específicos por servicio

### 6.2. Secrets

- ✅ Nunca commitear secrets en texto plano
- ✅ Rotar secrets regularmente
- ✅ Usar AWS Secrets Manager para secrets críticos
- ✅ Encriptar secrets en repositorio si es necesario

### 6.3. Network

- ✅ Restringir Security Groups al mínimo necesario
- ✅ Usar Network Policies para aislar namespaces
- ✅ Limitar acceso SSH a IPs específicas
- ✅ Usar subnets privadas para bases de datos (si aplica)
- ⚠️ **Revisar Security Groups de bases de datos**: Para producción, restringir a Security Groups específicos de los servicios que necesitan acceso

### 6.4. Pod Security

- ✅ Ejecutar pods como usuario no-root cuando sea posible
- ✅ Usar Pod Security Standards
- ✅ Limitar capabilities de contenedores
- ✅ Escanear imágenes por vulnerabilidades

### 6.5. Auditoría

- ✅ Habilitar CloudTrail para auditoría de API
- ✅ Revisar logs de Kubernetes regularmente
- ✅ Monitorear accesos no autorizados
- ✅ Documentar cambios de seguridad

---

## 7. Comandos Útiles

### 7.1. Verificar Permisos IAM

```bash
# Ver políticas adjuntas de un rol
aws iam list-attached-role-policies --role-name <role-name>

# Ver políticas inline
aws iam list-role-policies --role-name <role-name>
```

### 7.2. Listar Secrets

```bash
# Kubernetes Secrets
kubectl get secrets -n <namespace>

# AWS Secrets Manager
aws secretsmanager list-secrets --region <region>
```

### 7.3. Verificar Security Groups

```bash
# Ver Security Group
aws ec2 describe-security-groups --group-ids <sg-id> --region <region>

# Ver reglas de entrada
aws ec2 describe-security-groups --group-ids <sg-id> --query 'SecurityGroups[0].IpPermissions' --region <region>

# Ver reglas de salida
aws ec2 describe-security-groups --group-ids <sg-id> --query 'SecurityGroups[0].IpPermissionsEgress' --region <region>

# Ver todos los Security Groups de la VPC
aws ec2 describe-security-groups --filters "Name=vpc-id,Values=<vpc-id>" --region <region>
```

### 7.4. Verificar Network Policies

```bash
kubectl get networkpolicies -n <namespace>
kubectl describe networkpolicy <policy-name> -n <namespace>
```

---

## 8. Troubleshooting

For common security and IAM issues, see the [Security Troubleshooting Guide](../../../docs/troubleshooting/Security.md).

---

## 9. Checklist de Seguridad

- [ ] OIDC provider configurado para IRSA
- [ ] Service Accounts con IAM roles (si aplica)
- [ ] Secrets almacenados de forma segura (no en texto plano)
- [ ] Security Groups restringidos al mínimo necesario
- [ ] Network Policies implementadas (si aplica)
- [ ] Pods ejecutándose como usuario no-root
- [ ] CloudTrail habilitado para auditoría
- [ ] Políticas IAM revisadas y auditadas
- [ ] Backups de secrets configurados
- [ ] Documentación de seguridad actualizada

---

## 📚 Referencias

- [AWS EKS Security Best Practices](https://aws.github.io/aws-eks-best-practices/security/)
- [IAM Roles for Service Accounts](https://docs.aws.amazon.com/eks/latest/userguide/iam-roles-for-service-accounts.html)
- [Kubernetes Secrets](https://kubernetes.io/docs/concepts/configuration/secret/)
- [AWS Secrets Manager](https://docs.aws.amazon.com/secretsmanager/)
- [Network Policies](https://kubernetes.io/docs/concepts/services-networking/network-policies/)
