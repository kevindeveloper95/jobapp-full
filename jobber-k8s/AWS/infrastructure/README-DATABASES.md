# Bases de Datos - Jobber

Esta guía documenta la estrategia de bases de datos para el proyecto Jobber, incluyendo decisiones arquitectónicas sobre servicios administrados vs bases de datos en Kubernetes.

---

## 📋 Tabla de Contenidos

1. [Estrategia de Bases de Datos](#1-estrategia-de-bases-de-datos)
2. [Bases de Datos en Kubernetes](#2-bases-de-datos-en-kubernetes)
3. [Bases de Datos Administradas (RDS/ElastiCache)](#3-bases-de-datos-administradas-rdselasticache)
4. [Configuración por Servicio](#4-configuración-por-servicio)
5. [Backups y Persistencia](#5-backups-y-persistencia)
6. [Migración y Escalado](#6-migración-y-escalado)

---

## 1. Estrategia de Bases de Datos

### 1.1. Decisión Arquitectónica

**Para este proyecto de portfolio:**
- ✅ **Bases de datos en Kubernetes** (StatefulSets)
- ❌ **RDS/ElastiCache** (no usado para ahorrar costos)

**Razones:**
- Ahorro de costos (~$15-50/mes por instancia RDS)
- Suficiente para demo/portfolio
- Control total sobre configuración
- Fácil de replicar en Minikube

### 1.2. Cuándo Usar RDS/ElastiCache

**Usar servicios administrados si:**
- Producción real con alta disponibilidad requerida
- Necesitas backups automáticos
- Requieres multi-AZ para alta disponibilidad
- Necesitas escalado automático
- Presupuesto permite (~$15-100+/mes por instancia)

---

## 2. Bases de Datos en Kubernetes

### 2.1. Bases de Datos Implementadas

| Base de Datos | Servicio | Namespace | Estado |
|---------------|----------|-----------|--------|
| MySQL | `jobber-mysql` | production | ✅ Implementado |
| PostgreSQL | `jobber-postgres` | production | ✅ Implementado |
| MongoDB | `jobber-mongo` | production | ✅ Implementado |
| Redis | `jobber-redis` | production | ✅ Implementado |

### 2.2. Configuración de StatefulSets

**Ubicación de manifiestos**: `../minikube/jobber-mysql/`, `../minikube/jobber-postgres/`, etc.

**Características:**
- StatefulSets para persistencia
- PersistentVolumes (EBS en AWS)
- ConfigMaps para configuración
- Secrets para credenciales

### 2.3. Verificar Bases de Datos

```bash
# Ver StatefulSets
kubectl get statefulsets -n production

# Ver PersistentVolumes
kubectl get pv

# Ver PersistentVolumeClaims
kubectl get pvc -n production

# Conectar a MySQL
kubectl exec -it -n production statefulset/jobber-mysql -- mysql -uroot -p<password>

# Conectar a PostgreSQL
kubectl exec -it -n production statefulset/jobber-postgres -- psql -U jobber

# Conectar a MongoDB
kubectl exec -it -n production statefulset/jobber-mongo -- mongosh
```

---

## 3. Bases de Datos Administradas (RDS/ElastiCache)

### 3.1. RDS (Relational Database Service)

**Estado**: No implementado actualmente (bases de datos corren en pods), pero DB Subnet Group está configurado para uso futuro.

#### 3.1.1. DB Subnet Group Configurado

**DB Subnet Group Name**: `jobber-rds-subnet-group`  
**ARN**: `arn:aws:rds:us-east-1:<account-id>:subgrp:jobber-rds-subnet-group`  
**VPC**: `<vpc-id>` (jobber-cluster-vpc)  
**Description**: RDS subnet for MYSQL and POSTGRES  
**Supported Network Types**: IPv4

**Subnets Configuradas** (2 subnets en diferentes AZs):

| Availability Zone | Subnet Name | Subnet ID | CIDR Block |
|-------------------|-------------|-----------|------------|
| us-east-1a | `jobber-private-subnet-3` | `<subnet-private-3-id>` | `10.0.2.0/24` |
| us-east-1b | `jobber-private-subnet-4` | `<subnet-private-4-id>` | `10.0.3.0/24` |

**Nota**: Este DB Subnet Group está configurado pero no se está usando actualmente ya que las bases de datos corren dentro del clúster Kubernetes. Está listo para usar si decides migrar a RDS en el futuro.

**Verificar DB Subnet Group**:
```bash
# Ver detalles del DB Subnet Group
aws rds describe-db-subnet-groups --db-subnet-group-name jobber-rds-subnet-group --region us-east-1

# Ver todas las DB Subnet Groups
aws rds describe-db-subnet-groups --region us-east-1
```

#### 3.1.2. Crear Instancia RDS MySQL (si se implementara)

```bash
aws rds create-db-instance \
  --db-instance-identifier jobber-mysql \
  --db-instance-class db.t3.micro \
  --engine mysql \
  --master-username admin \
  --master-user-password <password> \
  --allocated-storage 20 \
  --vpc-security-group-ids <sg-mysql-id> \
  --db-subnet-group-name jobber-rds-subnet-group \
  --region us-east-1
```

#### 3.1.3. Crear Instancia RDS PostgreSQL (si se implementara)

```bash
aws rds create-db-instance \
  --db-instance-identifier jobber-postgres \
  --db-instance-class db.t3.micro \
  --engine postgres \
  --master-username admin \
  --master-user-password <password> \
  --allocated-storage 20 \
  --vpc-security-group-ids <sg-postgres-id> \
  --db-subnet-group-name jobber-rds-subnet-group \
  --region us-east-1
```

#### 3.1.4. Obtener Endpoint

```bash
# Obtener endpoint de MySQL
aws rds describe-db-instances \
  --db-instance-identifier jobber-mysql \
  --query 'DBInstances[0].Endpoint.Address' \
  --region us-east-1

# Obtener endpoint de PostgreSQL
aws rds describe-db-instances \
  --db-instance-identifier jobber-postgres \
  --query 'DBInstances[0].Endpoint.Address' \
  --region us-east-1
```

### 3.2. ElastiCache (Redis)

**No implementado en este proyecto**, pero aquí está cómo se haría:

```bash
aws elasticache create-cache-cluster \
  --cache-cluster-id jobber-redis \
  --cache-node-type cache.t3.micro \
  --engine redis \
  --num-cache-nodes 1 \
  --vpc-security-group-ids sg-xxxxxxxxx \
  --region us-east-1
```

---

## 4. Configuración por Servicio

### 4.1. Auth Service → MySQL

**Base de datos**: `jobber_auth`
**Configuración**: Ver `../3-auth/auth.yaml`

```yaml
env:
  - name: DATABASE_HOST
    value: jobber-mysql.production.svc.cluster.local
  - name: DATABASE_NAME
    value: jobber_auth
```

### 4.2. Gig/Chat/Order Services → PostgreSQL

**Base de datos**: `jobber`
**Configuración**: Ver `../5-gig/gig.yaml`

```yaml
env:
  - name: DATABASE_HOST
    value: jobber-postgres.production.svc.cluster.local
  - name: DATABASE_NAME
    value: jobber
```

### 4.3. Review Service → MongoDB + PostgreSQL

**MongoDB**: Documentos de reviews
**PostgreSQL**: Analytics y relaciones
**Configuración**: Ver `../8-reviews/reviews.yaml`

### 4.4. Cache → Redis

**Uso**: Cache de sesiones, datos frecuentes
**Configuración**: Ver `../jobber-redis/`

---

## 5. Backups y Persistencia

### 5.1. PersistentVolumes en EKS

**Tipo**: EBS (Elastic Block Store)
**Storage Class**: `gp3` (recomendado) o `gp2`

**Ejemplo**:
```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: mysql-pvc
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: gp3
  resources:
    requests:
      storage: 20Gi
```

### 5.2. Backups Manuales

```bash
# Backup MySQL
kubectl exec -n production statefulset/jobber-mysql -- mysqldump -uroot -p<password> jobber_auth > backup.sql

# Backup PostgreSQL
kubectl exec -n production statefulset/jobber-postgres -- pg_dump -U jobber jobber > backup.sql

# Backup MongoDB
kubectl exec -n production statefulset/jobber-mongo -- mongodump --out /backup
```

### 5.3. Snapshots de EBS (AWS)

```bash
# Crear snapshot de un volumen
aws ec2 create-snapshot \
  --volume-id vol-xxxxxxxxx \
  --description "MySQL backup $(date +%Y-%m-%d)" \
  --region us-east-1

# Listar snapshots
aws ec2 describe-snapshots --owner-ids self --region us-east-1
```

---

## 6. Migración y Escalado

### 6.1. Migrar de K8s a RDS

**Pasos:**
1. Crear instancia RDS
2. Exportar datos de StatefulSet
3. Importar datos a RDS
4. Actualizar connection strings en servicios
5. Eliminar StatefulSet

### 6.2. Escalar Bases de Datos

**En Kubernetes:**
```bash
# Escalar StatefulSet (solo réplicas, no recursos)
kubectl scale statefulset jobber-mysql --replicas=2 -n production
```

**En RDS:**
```bash
# Modificar instancia (cambiar tipo)
aws rds modify-db-instance \
  --db-instance-identifier jobber-mysql \
  --db-instance-class db.t3.small \
  --apply-immediately \
  --region us-east-1
```

---

## 7. Costos Estimados

### 7.1. Bases de Datos en Kubernetes

| Componente | Costo |
|------------|-------|
| EBS 20 GB (gp3) | ~$1.6/mes |
| CPU/RAM (parte del nodo) | Incluido en costo del nodo |
| **Total** | **~$1.6/mes** |

### 7.2. RDS (si se usara)

| Tipo | Costo Mensual |
|------|---------------|
| db.t3.micro (Free Tier) | $0 (primer año) |
| db.t3.small | ~$15/mes |
| db.t3.medium | ~$30/mes |
| Storage 20 GB | ~$2.3/mes |
| **Total (t3.small)** | **~$17/mes** |

---

## 8. Troubleshooting

For common database issues, see the [Database Troubleshooting Guide](../../../docs/troubleshooting/Databases.md).

---

## 9. Mejores Prácticas

1. ✅ Usar StatefulSets para bases de datos con estado
2. ✅ Configurar PersistentVolumes con clase de almacenamiento apropiada
3. ✅ Usar Secrets para credenciales (nunca hardcodear)
4. ✅ Implementar backups regulares
5. ✅ Monitorear uso de recursos (CPU, memoria, disco)
6. ✅ Documentar decisiones arquitectónicas

---

## 📚 Referencias

- [Kubernetes StatefulSets](https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/)
- [AWS RDS Documentation](https://docs.aws.amazon.com/rds/)
- [AWS ElastiCache Documentation](https://docs.aws.amazon.com/elasticache/)
- [EKS Storage Best Practices](https://aws.github.io/aws-eks-best-practices/storage/)

