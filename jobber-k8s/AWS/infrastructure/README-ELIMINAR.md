# 🗑️ Script de Eliminación Completa - Recursos AWS

## 📋 Descripción

Este script elimina **TODOS los recursos de AWS** que creaste para el proyecto Jobber.

**✅ IMPORTANTE**: El script **NO borra nada de tu proyecto local**:
- Tu código fuente permanece intacto
- Tus archivos de configuración permanecen intactos
- Solo se eliminan recursos en AWS (nube)

## 🚀 Uso Rápido

### Opción 1: Ejecutar el Script Completo

```bash
# Desde el directorio del proyecto
cd jobber-k8s/AWS/infrastructure

# Dar permisos de ejecución (solo la primera vez)
chmod +x eliminar-todo-aws.sh

# Ejecutar el script
./eliminar-todo-aws.sh
```

### Opción 2: Ejecutar con Bash

```bash
bash eliminar-todo-aws.sh
```

## ⚙️ Configuración

El script usa estos valores por defecto (basados en tu proyecto):

- **Cluster Name**: `jobberapp-demo`
- **Región**: `us-east-1`
- **Hosted Zone ID**: `Z0220383WELM11X3469T`
- **Domain**: `api.jobberapp.kevmendeveloper.com`

Puedes cambiar estos valores antes de ejecutar:

```bash
export CLUSTER_NAME="tu-cluster"
export AWS_REGION="us-west-2"
export HOSTED_ZONE_ID="tu-hosted-zone-id"
./eliminar-todo-aws.sh
```

## 📦 Requisitos

### Obligatorios:
- ✅ AWS CLI instalado y configurado
- ✅ Credenciales de AWS configuradas (`aws configure`)

### Opcionales (recomendados):
- ✅ `kubectl` - Para eliminar recursos de Kubernetes
- ✅ `eksctl` - Para eliminar el cluster EKS
- ✅ `jq` - Para procesar JSON (útil para CloudFront)

## 🔄 Qué Hace el Script

El script elimina recursos en este orden:

1. **Recursos de Kubernetes** (Pods, Services, Ingress, etc.)
2. **Application Load Balancers (ALB)**
3. **CloudFront Distributions**
4. **EKS Cluster y Nodegroups**
5. **Route 53 Records y Hosted Zones**
6. **ACM Certificates**
7. **EBS Volumes**
8. **NAT Gateway**
9. **Elastic IPs**
10. **VPC y recursos de networking**

## ⚠️ Advertencias

1. **Confirmación Requerida**: El script te pedirá confirmación escribiendo `SI`
2. **Tiempo**: El proceso completo puede tardar 30-60 minutos
3. **Costos Residuales**: Algunos recursos pueden seguir generando costos por unas horas después de eliminarlos
4. **CloudFront**: La eliminación de CloudFront puede tardar 15-30 minutos

## 🆘 Troubleshooting

### Error: "AWS CLI no está instalado"
```bash
# Instalar AWS CLI
# Windows (PowerShell):
Invoke-WebRequest -Uri "https://awscli.amazonaws.com/AWSCLIV2.msi" -OutFile "$env:TEMP\AWSCLIV2.msi"
Start-Process msiexec.exe -ArgumentList "/i $env:TEMP\AWSCLIV2.msi /quiet" -Wait

# Linux/Mac:
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
```

### Error: "No hay credenciales de AWS"
```bash
aws configure
# Ingresa tu Access Key ID, Secret Access Key, región, etc.
```

### Error: "kubectl no encontrado"
- El script continuará, pero omitirá la eliminación de recursos de Kubernetes
- Puedes eliminar el cluster EKS directamente con `eksctl delete cluster`

### Error: "eksctl no encontrado"
- Instala eksctl: https://eksctl.io/
- O elimina el cluster manualmente desde la consola AWS

## 📝 Notas

- El script es **idempotente**: puedes ejecutarlo múltiples veces sin problemas
- Si un recurso ya está eliminado, el script lo omite y continúa
- Algunos recursos pueden tardar en eliminarse (especialmente EKS y CloudFront)
- Verifica en la consola de AWS que todo se haya eliminado correctamente

## 🔗 Referencias

- [Guía Detallada](ELIMINAR-PROYECTO-AWS.md) - Pasos manuales detallados
- [Documentación AWS](https://docs.aws.amazon.com/)
- [eksctl Documentation](https://eksctl.io/)


