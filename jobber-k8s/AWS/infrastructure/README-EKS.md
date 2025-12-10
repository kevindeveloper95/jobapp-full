# EKS Cluster Setup - Jobber

Esta guía documenta la creación, configuración y gestión del clúster EKS para el proyecto Jobber.

---

## 📋 Tabla de Contenidos

1. [Prerrequisitos](#1-prerrequisitos)
2. [Crear el Clúster](#2-crear-el-clúster)
3. [Configurar Nodegroups](#3-configurar-nodegroups)
4. [Verificar Instalación](#4-verificar-instalación)
5. [Configurar kubectl](#5-configurar-kubectl)
6. [Gestión del Clúster](#6-gestión-del-clúster)
7. [Troubleshooting](#7-troubleshooting)

---

## 1. Prerrequisitos

### 1.1. Herramientas Requeridas

- ✅ `eksctl` instalado ([Ver guía](../INSTALL-EKSCTL.md))
- ✅ `kubectl` instalado
- ✅ `aws-cli` configurado con credenciales
- ✅ Permisos de AWS: `AmazonEKSClusterPolicy`, `AmazonEKSServicePolicy`

### 1.2. Verificar Instalación

```bash
# Verificar eksctl
eksctl version

# Verificar kubectl
kubectl version --client

# Verificar AWS CLI
aws --version
aws sts get-caller-identity  # Verificar credenciales
```

---

## 2. Crear el Clúster

### 2.1. Opción A: Comando Simple (Recomendado para Portfolio)

```bash
eksctl create cluster \
  --name jobberapp-demo \
  --region us-east-1 \
  --version 1.30 \
  --nodegroup-name demo-small \
  --node-type t3.small \
  --nodes 1 \
  --nodes-min 1 \
  --nodes-max 2 \
  --node-volume-size 10 \
  --ssh-access \
  --ssh-public-key jobber-kube \
  --managed
```

**Parámetros explicados:**
- `--name`: Nombre del clúster
- `--region`: Región de AWS
- `--version`: Versión de Kubernetes
- `--node-type`: Tipo de instancia EC2
- `--nodes`: Número inicial de nodos
- `--nodes-min/max`: Límites para Cluster Autoscaler
- `--managed`: Usa nodegroups administrados (recomendado)

### 2.2. Opción B: Archivo de Configuración

Crea `eksctl-config.yaml`:

```yaml
apiVersion: eksctl.io/v1alpha5
kind: ClusterConfig

metadata:
  name: jobberapp-demo
  region: us-east-1
  version: "1.30"

managedNodeGroups:
  - name: demo-small
    instanceType: t3.small
    desiredCapacity: 1
    minSize: 1
    maxSize: 2
    volumeSize: 10
    ssh:
      allow: true
      publicKeyName: jobber-kube
```

Luego ejecuta:
```bash
eksctl create cluster -f eksctl-config.yaml
```

---

## 3. Configurar Nodegroups

### 3.1. Nodegroup Actual

**Nombre**: `demo-small`
- **Tipo**: `t3.small` (2 vCPU, 2 GB RAM)
- **Nodos**: 1-2 (escalable con CA)
- **Storage**: 10 GB EBS por nodo

### 3.2. Agregar Nodegroup Adicional (Opcional)

```bash
eksctl create nodegroup \
  --cluster jobberapp-demo \
  --region us-east-1 \
  --name demo-medium \
  --node-type t3.medium \
  --nodes 0 \
  --nodes-min 0 \
  --nodes-max 1 \
  --managed
```

### 3.3. Listar Nodegroups

```bash
eksctl get nodegroup --cluster jobberapp-demo --region us-east-1
```

---

## 4. Verificar Instalación

### 4.1. Verificar Clúster

```bash
# Listar clústeres
eksctl get cluster --region us-east-1

# Ver detalles del clúster
eksctl get cluster --name jobberapp-demo --region us-east-1
```

### 4.2. Verificar Nodos

```bash
# Ver nodos del clúster
kubectl get nodes

# Ver detalles de un nodo
kubectl describe node <node-name>

# Ver recursos de nodos
kubectl top nodes
```

### 4.3. Verificar Componentes del Sistema

```bash
# Ver pods del sistema
kubectl get pods -n kube-system

# Verificar CoreDNS
kubectl get pods -n kube-system -l k8s-app=kube-dns

# Verificar VPC CNI
kubectl get pods -n kube-system -l app=vpc-cni
```

---

## 5. Configurar kubectl

### 5.1. Actualizar kubeconfig

```bash
# eksctl actualiza automáticamente ~/.kube/config
# Verificar contexto actual
kubectl config current-context

# Cambiar contexto si es necesario
kubectl config use-context <cluster-name>@<region>
```

### 5.2. Verificar Conexión

```bash
# Probar conexión
kubectl cluster-info

# Ver todos los recursos
kubectl get all --all-namespaces
```

---

## 6. Gestión del Clúster

### 6.1. Escalar Nodegroup

```bash
# Escalar manualmente
eksctl scale nodegroup \
  --cluster jobberapp-demo \
  --name demo-small \
  --nodes 2 \
  --region us-east-1
```

### 6.2. Actualizar Clúster

```bash
# Ver versiones disponibles
eksctl utils list-clusters --region us-east-1

# Actualizar versión de Kubernetes
eksctl upgrade cluster --name jobberapp-demo --region us-east-1
```

### 6.3. Agregar Add-ons

#### 6.3.1. EBS CSI Driver

**Propósito**: Permite que Kubernetes gestione volúmenes EBS para almacenamiento persistente (necesario para bases de datos, RabbitMQ, etc.).

**Prerrequisitos**:
1. Crear IAM Policy: `Amazon_EBS_CSI_Driver` (ver `../README-SECURITY.md` sección 1.2.1)
2. Configurar OIDC Provider (si no está configurado)

**Instalación**:

```bash
# 1. Crear IAM Service Account para EBS CSI Driver
eksctl create iamserviceaccount \
  --cluster jobberapp-demo \
  --region us-east-1 \
  --namespace kube-system \
  --name ebs-csi-controller-sa \
  --attach-policy-arn arn:aws:iam::<account-id>:policy/Amazon_EBS_CSI_Driver \
  --approve \
  --override-existing-serviceaccounts

# 2. Instalar EBS CSI Driver addon
eksctl create addon \
  --name aws-ebs-csi-driver \
  --cluster jobberapp-demo \
  --region us-east-1 \
  --service-account-role-arn arn:aws:iam::<account-id>:role/<service-account-role-name> \
  --wait
```

**Verificar Instalación**:
```bash
# Verificar pods del EBS CSI Driver
kubectl get pods -n kube-system -l app=ebs-csi-controller

# Verificar que el driver esté funcionando
kubectl get csidriver

# Verificar add-ons instalados
eksctl get addon --cluster jobberapp-demo --region us-east-1
```

**Nota**: Después de instalar el EBS CSI Driver, puedes cambiar los StorageClasses de tus bases de datos de `local-storage` (Minikube) a `ebs-sc` (EKS). Ver `../README-DATABASES.md` para más detalles.

#### 6.3.2. Otros Add-ons

```bash
# Instalar AWS Load Balancer Controller
eksctl create addon --name vpc-cni --cluster jobberapp-demo --region us-east-1

# Ver add-ons instalados
eksctl get addon --cluster jobberapp-demo --region us-east-1
```

---

## 7. Troubleshooting

For common EKS cluster issues and diagnostic commands, see the [EKS Troubleshooting Guide](../../../docs/troubleshooting/EKS.md).

---

## 8. Eliminar el Clúster

**⚠️ ADVERTENCIA**: Esto elimina TODO el clúster y todos los recursos asociados.

```bash
# Eliminar clúster completo
eksctl delete cluster --name jobberapp-demo --region us-east-1

# Eliminar solo un nodegroup
eksctl delete nodegroup --cluster jobberapp-demo --name demo-small --region us-east-1
```

---

## 9. Costos Estimados

| Componente | Costo Mensual |
|------------|---------------|
| EKS Control Plane | ~$73/mes |
| Nodo t3.small (1 nodo) | ~$15/mes |
| Nodo t3.small (2 nodos) | ~$30/mes |
| EBS 10 GB | ~$0.8/mes por nodo |
| **Total (1 nodo)** | **~$89/mes** |
| **Total (2 nodos)** | **~$104/mes** |

**Nota**: Apagar el clúster cuando no se use para ahorrar costos.

---

## 10. Mejores Prácticas

1. ✅ Usar nodegroups administrados (`--managed`)
2. ✅ Configurar `nodes-min` y `nodes-max` para Cluster Autoscaler
3. ✅ Usar instancias pequeñas para portfolio (t3.small o t3.medium)
4. ✅ Habilitar SSH access para troubleshooting
5. ✅ Etiquetar recursos con tags descriptivos
6. ✅ Documentar cambios en este README

---

## 📚 Referencias

- [eksctl Documentation](https://eksctl.io/)
- [AWS EKS Documentation](https://docs.aws.amazon.com/eks/)
- [EKS Best Practices](https://aws.github.io/aws-eks-best-practices/)
- [Configuración de Demo](../demo-config.md)

