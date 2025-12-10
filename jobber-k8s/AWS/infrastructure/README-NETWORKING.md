# Networking Architecture - Jobber

Esta guía documenta la arquitectura de red (VPC, Subnets, Security Groups) para el proyecto Jobber en AWS.

---

## 📋 Tabla de Contenidos

1. [VPC Configuration](#1-vpc-configuration)
2. [Subnets](#2-subnets)
3. [Security Groups](#3-security-groups)
4. [NAT Gateway](#4-nat-gateway)
5. [Internet Gateway](#5-internet-gateway)
6. [Route Tables](#6-route-tables)
7. [Diagrama de Arquitectura](#7-diagrama-de-arquitectura)
8. [Comandos Útiles](#8-comandos-útiles)
9. [Troubleshooting](#9-troubleshooting)
10. [Costos Estimados](#10-costos-estimados)
11. [Información de Referencia Rápida](#11-información-de-referencia-rápida)

---

## 1. VPC Configuration

### 1.1. Información General

- **VPC ID**: `<vpc-id>`
- **VPC Name**: `jobber-cluster-vpc`
- **CIDR Block**: `10.0.0.0/16`
- **Region**: `us-east-1`
- **Availability Zones**: `us-east-1a`, `us-east-1b`
- **Owner ID**: `<account-id>`
- **State**: Available
- **Tenancy**: default
- **Default VPC**: No

### 1.2. Configuración de DNS

- **DNS Resolution**: Enabled
- **DNS Hostnames**: Enabled
- **DHCP Option Set**: `dopt-0f240d7a8a490dece`

**Importante**: DNS resolution y hostnames están habilitados, lo cual es necesario para que los pods puedan resolver nombres de servicios internos de Kubernetes.

### 1.3. Componentes de Red

- **Main Route Table**: `rtb-030d192d899734d71`
- **Main Network ACL**: `acl-0fc86b9f08985e51d`
- **Block Public Access**: Off (permite acceso público cuando se requiere)

### 1.4. Crear VPC

```bash
# Si usas eksctl, el VPC se crea automáticamente
eksctl create cluster --name jobberapp-demo --region us-east-1

# O manualmente con AWS CLI
aws ec2 create-vpc --cidr-block 10.0.0.0/16 --region us-east-1
```

### 1.5. Verificar VPC Actual

```bash
# Ver detalles de la VPC
aws ec2 describe-vpcs --vpc-ids <vpc-id> --region us-east-1

# Ver información de DNS
aws ec2 describe-vpc-attribute --vpc-id <vpc-id> --attribute enableDnsSupport --region us-east-1
aws ec2 describe-vpc-attribute --vpc-id <vpc-id> --attribute enableDnsHostnames --region us-east-1
```

---

## 2. Subnets

### 2.1. Subnets Públicas

| Subnet | Subnet ID | CIDR | AZ | Route Table | Estado |
|--------|-----------|------|----|-------------|--------|
| `jobber-public-subnet-1` | `<subnet-public-1-id>` | `10.0.0.0/24` | us-east-1a (use1-az6) | `<rtb-public-id>` | Available |
| `jobber-public-subnet-2` | `<subnet-public-2-id>` | `10.0.1.0/24` | us-east-1b (use1-az1) | `<rtb-public-id>` | Available |

**Características:**
- ✅ **Auto-assign public IPv4 address**: Yes (asignación automática de IP pública)
- ✅ **Route Table**: `jobber-public-RT` (`<rtb-public-id>`) - ambas subnets usan la misma route table
- ✅ **Network ACL**: `acl-0fc86b9f08985e51d` (misma ACL para ambas)
- ✅ **Available IPv4 addresses**: 251 por subnet (256 total - 5 reservados)
- ✅ **Acceso directo a Internet Gateway**: Configurado en la route table
- ✅ **Usadas para nodos EKS**: Sin NAT Gateway para ahorrar costos

**Tags**:

| Subnet | Tags |
|--------|------|
| `jobber-public-subnet-1` | `Name`: `jobber-public-subnet-1`<br>`kurbenetes.io/cluster/jobberapp`: `owned`<br>`kurbenetes.io/role/internal-elb`: `1` |
| `jobber-public-subnet-2` | `Name`: `jobber-public-subnet-2`<br>`kurbenetes.io/cluster/jobberapp`: `owned`<br>`kurbenetes.io/role/internal-elb`: `1` |

**Nota sobre tags**: Los tags `kurbenetes.io/cluster/jobberapp` y `kurbenetes.io/role/internal-elb` son agregados automáticamente por eksctl para identificar las subnets del clúster EKS y permitir la creación de Load Balancers internos.

**Detalles por Subnet:**

#### Subnet 1: jobber-public-subnet-1
- **Subnet ID**: `<subnet-public-1-id>`
- **CIDR**: `10.0.0.0/24` (256 direcciones IP)
- **Availability Zone**: `us-east-1a` (use1-az6)
- **Subnet ARN**: `arn:aws:ec2:us-east-1:<account-id>:subnet/<subnet-public-1-id>`

#### Subnet 2: jobber-public-subnet-2
- **Subnet ID**: `<subnet-public-2-id>`
- **CIDR**: `10.0.1.0/24` (256 direcciones IP)
- **Availability Zone**: `us-east-1b` (use1-az1)
- **Subnet ARN**: `arn:aws:ec2:us-east-1:<account-id>:subnet/<subnet-public-2-id>`

### 2.2. Route Table de Subnets Públicas

**Route Table ID**: `<rtb-public-id>`  
**Name**: `jobber-public-RT`  
**VPC**: `<vpc-id>` (jobber-cluster-vpc)  
**Main**: No (route table explícita, no la principal de la VPC)  
**Owner ID**: `<account-id>`

**Subnets Asociadas (Explicit subnet associations)**: 2 subnets
- `<subnet-public-1-id>` (jobber-public-subnet-1) - `10.0.0.0/24`
- `<subnet-public-2-id>` (jobber-public-subnet-2) - `10.0.1.0/24`

**Edge associations**: Ninguna

**Rutas Configuradas**:

| Destino | Target | Estado | Propagated | Route Origin |
|---------|--------|--------|------------|--------------|
| `10.0.0.0/16` | local | Active | No | Create Route Table |
| `0.0.0.0/0` | `<igw-id>` | Active | No | Create Route |

**Descripción de Rutas**:
- **`10.0.0.0/16` → local**: Tráfico local dentro de la VPC (todas las subnets pueden comunicarse entre sí)
- **`0.0.0.0/0` → Internet Gateway**: Acceso a Internet para todas las subnets asociadas

**Tags**:
- `Name`: `jobber-public-RT`

**Verificar Route Table**:
```bash
# Ver detalles completos de la route table
aws ec2 describe-route-tables --route-table-ids <rtb-public-id> --region us-east-1

# Ver subnets asociadas explícitamente
aws ec2 describe-route-tables --route-table-ids <rtb-public-id> --query 'RouteTables[0].Associations[?SubnetId!=`null`]' --region us-east-1

# Ver solo las rutas
aws ec2 describe-route-tables --route-table-ids <rtb-public-id> --query 'RouteTables[0].Routes' --region us-east-1

# Verificar que no es la route table principal
aws ec2 describe-route-tables --route-table-ids <rtb-public-id> --query 'RouteTables[0].Associations[?Main==`true`]' --region us-east-1
# Debe devolver: [] (vacío, no es la principal)
```

### 2.3. Subnets Privadas

| Subnet | Subnet ID | CIDR | AZ | Route Table | Estado |
|--------|-----------|------|----|-------------|--------|
| `jobber-private-subnet-3` | `<subnet-private-3-id>` | `10.0.2.0/24` | us-east-1a (use1-az6) | `<rtb-private-id>` | Available |
| `jobber-private-subnet-4` | `<subnet-private-4-id>` | `10.0.3.0/24` | us-east-1b (use1-az1) | `<rtb-private-id>` | Available |

**Características:**
- ❌ **Auto-assign public IPv4 address**: No (subnets privadas no tienen IPs públicas)
- ✅ **Route Table**: `jobber-private-RT` (<rtb-private-id>) - ambas subnets usan la misma route table
- ✅ **Network ACL**: `acl-0fc86b9f08985e51d` (misma ACL que las públicas)
- ✅ **Available IPv4 addresses**: 250 por subnet (256 total - 6 reservados)
- ✅ **Acceso a Internet**: A través de NAT Gateway (`<nat-gateway-id>`)
- ✅ **Uso**: RDS, ElastiCache, o recursos que requieren aislamiento de Internet pública
- ✅ **DB Subnet Group**: Ambas subnets están configuradas en `jobber-rds-subnet-group` para uso futuro con RDS (ver `../README-DATABASES.md`)

**Tags**:

| Subnet | Tags |
|--------|------|
| `jobber-private-subnet-3` | `Name`: `jobber-private-subnet-3` |
| `jobber-private-subnet-4` | `Name`: `jobber-private-subnet-4` |

**Nota**: Las subnets privadas solo tienen el tag `Name` ya que no son usadas directamente por EKS (no tienen tags de Kubernetes).

**Detalles por Subnet:**

#### Subnet 3: jobber-private-subnet-3
- **Subnet ID**: `<subnet-private-3-id>`
- **CIDR**: `10.0.2.0/24` (256 direcciones IP)
- **Availability Zone**: `us-east-1a` (use1-az6)
- **Subnet ARN**: `arn:aws:ec2:us-east-1:<account-id>:subnet/<subnet-private-3-id>`

#### Subnet 4: jobber-private-subnet-4
- **Subnet ID**: `<subnet-private-4-id>`
- **CIDR**: `10.0.3.0/24` (256 direcciones IP)
- **Availability Zone**: `us-east-1b` (use1-az1)
- **Subnet ARN**: `arn:aws:ec2:us-east-1:<account-id>:subnet/<subnet-private-4-id>`

### 2.4. Route Table de Subnets Privadas

**Route Table ID**: `<rtb-private-id>`  
**Name**: `jobber-private-RT`  
**VPC**: `<vpc-id>` (jobber-cluster-vpc)  
**Main**: No (route table explícita, no la principal de la VPC)  
**Owner ID**: `<account-id>`

**Subnets Asociadas (Explicit subnet associations)**: 2 subnets
- `<subnet-private-4-id>` (jobber-private-subnet-4) - `10.0.3.0/24`
- `<subnet-private-3-id>` (jobber-private-subnet-3) - `10.0.2.0/24`

**Edge associations**: Ninguna

**Rutas Configuradas**:

| Destino | Target | Estado | Propagated | Route Origin |
|---------|--------|--------|------------|--------------|
| `10.0.0.0/16` | local | Active | No | Create Route Table |
| `0.0.0.0/0` | `<nat-gateway-id>` | Active | No | Create Route |

**Descripción de Rutas**:
- **`10.0.0.0/16` → local**: Tráfico local dentro de la VPC (todas las subnets pueden comunicarse entre sí) - **Estado: Active**
- **`0.0.0.0/0` → NAT Gateway**: Acceso a Internet saliente para todas las subnets asociadas - **Estado: Active** ✅

**Nota**: La ruta al NAT Gateway está en estado "Active", lo que significa que el NAT Gateway está funcionando correctamente y las subnets privadas pueden acceder a Internet a través de él.

**Tags**:
- `Name`: `jobber-private-RT`

**Verificar Route Table**:
```bash
# Ver detalles completos de la route table
aws ec2 describe-route-tables --route-table-ids <rtb-private-id> --region us-east-1

# Ver subnets asociadas explícitamente
aws ec2 describe-route-tables --route-table-ids <rtb-private-id> --query 'RouteTables[0].Associations[?SubnetId!=`null`]' --region us-east-1

# Ver solo las rutas
aws ec2 describe-route-tables --route-table-ids <rtb-private-id> --query 'RouteTables[0].Routes' --region us-east-1

# Verificar que no es la route table principal
aws ec2 describe-route-tables --route-table-ids <rtb-private-id> --query 'RouteTables[0].Associations[?Main==`true`]' --region us-east-1
# Debe devolver: [] (vacío, no es la principal)
```

### 2.5. Verificar Subnets

```bash
# Ver todas las subnets de la VPC
aws ec2 describe-subnets --filters "Name=vpc-id,Values=<vpc-id>" --region us-east-1

# Ver subnet específica 1
aws ec2 describe-subnets --subnet-ids <subnet-public-1-id> --region us-east-1

# Ver subnet específica 2
aws ec2 describe-subnets --subnet-ids <subnet-public-2-id> --region us-east-1

# Ver subnets públicas por nombre
aws ec2 describe-subnets --filters "Name=tag:Name,Values=jobber-public-subnet-*" --region us-east-1

# Ver subnets privadas por nombre
aws ec2 describe-subnets --filters "Name=tag:Name,Values=jobber-private-subnet-*" --region us-east-1

# Ver subnet privada específica 3
aws ec2 describe-subnets --subnet-ids <subnet-private-3-id> --region us-east-1

# Ver subnet privada específica 4
aws ec2 describe-subnets --subnet-ids <subnet-private-4-id> --region us-east-1

# Verificar IPs disponibles (pública)
aws ec2 describe-subnets --subnet-ids <subnet-public-1-id> --query 'Subnets[0].AvailableIpAddressCount' --region us-east-1

# Verificar IPs disponibles (privada)
aws ec2 describe-subnets --subnet-ids <subnet-private-3-id> --query 'Subnets[0].AvailableIpAddressCount' --region us-east-1

# Ver tags de una subnet
aws ec2 describe-subnets --subnet-ids <subnet-public-1-id> --query 'Subnets[0].Tags' --region us-east-1

# Ver todas las subnets con sus tags
aws ec2 describe-subnets --filters "Name=vpc-id,Values=<vpc-id>" --query 'Subnets[*].[SubnetId,Tags[?Key==`Name`].Value|[0]]' --output table --region us-east-1
```

---

## 3. Security Groups

### 3.1. EKS Cluster Security Group

**Nombre**: `eks-cluster-sg` (creado automáticamente por eksctl)

**Reglas de Entrada (Inbound)**:
- Puerto 443 (HTTPS) desde Security Group de los nodos
- Puerto 1025-65535 desde Security Group de los nodos (para kubectl)

**Reglas de Salida (Outbound)**:
- Todo el tráfico permitido

### 3.2. Node Group Security Group

**Nombre**: `eks-nodegroup-sg` (creado automáticamente por eksctl)

**Reglas de Entrada (Inbound)**:
- Puerto 1025-65535 desde el mismo Security Group (comunicación entre nodos)
- Puerto 443 desde el Security Group del clúster (comunicación con control plane)

**Reglas de Salida (Outbound)**:
- Todo el tráfico permitido

### 3.3. Verificar Security Groups

```bash
# Listar Security Groups del clúster
aws ec2 describe-security-groups --filters "Name=tag:eks:cluster-name,Values=jobberapp-demo" --region us-east-1

# Ver reglas de un Security Group específico
aws ec2 describe-security-groups --group-ids sg-xxxxxxxxx --region us-east-1
```

---

## 4. NAT Gateway

### 4.1. Información General

- **NAT Gateway ID**: `<nat-gateway-id>`
- **NAT Gateway ARN**: `arn:aws:ec2:us-east-1:<account-id>:natgateway/<nat-gateway-id>`
- **Estado**: Available (activo y funcionando)
- **VPC**: `<vpc-id>` (jobber-cluster-vpc)
- **Connectivity Type**: Public
- **Created**: Monday, November 17, 2025 at 13:37:07 CST

### 4.2. Configuración de Red

**Subnet**: `<subnet-public-1-id>` (jobber-public-subnet-1) - us-east-1a

**Elastic IP Asociado**:
- **Primary Public IPv4**: `52.91.131.114`
- **Allocation ID**: `eipalloc-048817d7acd91e9e2`

**Direcciones IP**:
- **Primary Public IPv4**: `52.91.131.114` (IP pública)
- **Primary Private IPv4**: `10.0.0.66` (IP privada en la subnet)

**Primary Network Interface ID**: `eni-05ed8475ef6da94d1`

### 4.3. Uso y Configuración

**Función**: Permite que las subnets privadas accedan a Internet (solo salida)

**Route Table Asociada**: `<rtb-private-id>` (jobber-private-RT)

**Ruta Configurada en Route Table**:
- `0.0.0.0/0` → `<nat-gateway-id>`

**Subnets Privadas que Usan este NAT Gateway**:
- `<subnet-private-3-id>` (jobber-private-subnet-3) - us-east-1a
- `<subnet-private-4-id>` (jobber-private-subnet-4) - us-east-1b

### 4.4. Verificar NAT Gateway

```bash
# Ver NAT Gateway específico
aws ec2 describe-nat-gateways --nat-gateway-ids <nat-gateway-id> --region us-east-1

# Ver estado del NAT Gateway
aws ec2 describe-nat-gateways --nat-gateway-ids <nat-gateway-id> --query 'NatGateways[0].State' --region us-east-1
# Debe devolver: "available"

# Ver todas las NAT Gateways de la VPC
aws ec2 describe-nat-gateways --filter "Name=vpc-id,Values=<vpc-id>" --region us-east-1

# Ver Elastic IP asociado
aws ec2 describe-nat-gateways --nat-gateway-ids <nat-gateway-id> --query 'NatGateways[0].NatGatewayAddresses[0].PublicIp' --region us-east-1
# Debe devolver: "52.91.131.114"

# Ver subnet del NAT Gateway
aws ec2 describe-nat-gateways --nat-gateway-ids <nat-gateway-id> --query 'NatGateways[0].SubnetId' --region us-east-1
# Debe devolver: "<subnet-public-1-id>"
```

### 4.5. Costos

**Costo estimado**: ~$32/mes por NAT Gateway
- Costo por hora: ~$0.045/hora
- Costo por GB de datos procesados: ~$0.045/GB
- Elastic IP asociado: Gratis (solo se cobra si no está asociado)

**Nota**: Aunque los nodos EKS están en subnets públicas (no usan NAT Gateway), el NAT Gateway está disponible para recursos en subnets privadas (RDS, ElastiCache, etc.) si se implementan en el futuro.

---

## 4.6. Elastic IP (EIP)

### 4.6.1. Información General

- **Allocated IPv4 Address**: `52.91.131.114`
- **Allocation ID**: `eipalloc-048817d7acd91e9e2`
- **Type**: Public IP
- **Scope**: VPC
- **Network Border Group**: `us-east-1`
- **Address Pool**: Amazon

### 4.6.2. Estado Actual

**Estado**: Asociado al NAT Gateway

**Recursos Asociados**:
- ✅ **NAT Gateway ID**: `<nat-gateway-id>`
- ✅ **NAT Gateway ARN**: `arn:aws:ec2:us-east-1:<account-id>:natgateway/<nat-gateway-id>`
- ✅ **Network Interface ID**: `eni-05ed8475ef6da94d1` (Primary network interface del NAT Gateway)
- ✅ **Private IP Address**: `10.0.0.66` (IP privada del NAT Gateway en la subnet)

**Nota**: Este Elastic IP está correctamente asociado al NAT Gateway `<nat-gateway-id>`, proporcionando la IP pública `52.91.131.114` para el NAT Gateway.

### 4.6.3. Verificar Elastic IP

```bash
# Ver detalles del Elastic IP
aws ec2 describe-addresses --allocation-ids eipalloc-048817d7acd91e9e2 --region us-east-1

# Ver todos los Elastic IPs de la cuenta
aws ec2 describe-addresses --region us-east-1

# Verificar NAT Gateway asociado
aws ec2 describe-addresses --allocation-ids eipalloc-048817d7acd91e9e2 --query 'Addresses[0].NetworkInterfaceId' --region us-east-1
# Debe devolver: "eni-05ed8475ef6da94d1"

# Ver NAT Gateway que usa este EIP
aws ec2 describe-nat-gateways --filter "Name=nat-gateway-address.public-ip,Values=52.91.131.114" --region us-east-1
```

### 4.6.4. Costos

**Costo**: Gratis (elastic IP asociado a NAT Gateway no genera costo adicional)

**Nota**: Los Elastic IPs asociados a recursos activos (NAT Gateway, EC2, etc.) no generan costo. Solo se cobra si están asignados pero no asociados (~$3.65/mes).

---

## 5. Internet Gateway

### 5.1. Información General

- **Internet Gateway ID**: `<igw-id>`
- **Name**: `jobber-igw`
- **State**: Attached
- **VPC ID**: `<vpc-id>` (jobber-cluster-vpc)
- **Owner ID**: `<account-id>`

### 5.2. Estado y Función

**Estado**: Attached (conectado a la VPC)

**Función**: Permite que las subnets públicas accedan a Internet. Es necesario para que los nodos EKS puedan:
- Descargar imágenes de contenedores
- Acceder a repositorios externos
- Comunicarse con servicios de AWS (ECR, CloudWatch, etc.)

### 5.3. Verificar Internet Gateway

```bash
# Ver Internet Gateway específico
aws ec2 describe-internet-gateways --internet-gateway-ids <igw-id> --region us-east-1

# Ver Internet Gateway de la VPC
aws ec2 describe-internet-gateways --filters "Name=attachment.vpc-id,Values=<vpc-id>" --region us-east-1

# Verificar que está attached
aws ec2 describe-internet-gateways --internet-gateway-ids <igw-id> --query 'InternetGateways[0].Attachments[0].State' --region us-east-1
# Debe devolver: "available"
```

---

## 6. Route Tables

### 6.1. Route Table Principal (Main)

**Route Table ID**: `rtb-030d192d899734d71`

**Nota**: Esta es la route table principal de la VPC, pero las subnets públicas usan una route table diferente.

### 6.2. Route Table de Subnets Públicas

**Route Table ID**: `<rtb-public-id>`  
**Name**: `jobber-public-RT`  
**VPC**: `<vpc-id>` (jobber-cluster-vpc)  
**Main**: No (route table explícita)  
**Owner ID**: `<account-id>`

**Subnets Asociadas (Explicit subnet associations)**: 2 subnets
- `<subnet-public-1-id>` (jobber-public-subnet-1) - `10.0.0.0/24`
- `<subnet-public-2-id>` (jobber-public-subnet-2) - `10.0.1.0/24`

**Edge associations**: Ninguna

**Rutas Configuradas**:

| Destino | Target | Estado | Propagated | Route Origin |
|---------|--------|--------|------------|--------------|
| `10.0.0.0/16` | local | Active | No | Create Route Table |
| `0.0.0.0/0` | `<igw-id>` | Active | No | Create Route |

**Tags**:
- `Name`: `jobber-public-RT`

**Verificar rutas**:
```bash
# Ver todas las rutas de la route table pública
aws ec2 describe-route-tables --route-table-ids <rtb-public-id> --region us-east-1

# Ver solo la ruta al Internet Gateway
aws ec2 describe-route-tables --route-table-ids <rtb-public-id> --query 'RouteTables[0].Routes[?GatewayId==`<igw-id>`]' --region us-east-1

# Ver subnets asociadas explícitamente
aws ec2 describe-route-tables --route-table-ids <rtb-public-id> --query 'RouteTables[0].Associations[?SubnetId!=`null`]' --region us-east-1

# Verificar que no es la route table principal
aws ec2 describe-route-tables --route-table-ids <rtb-public-id> --query 'RouteTables[0].Associations[?Main==`true`]' --region us-east-1
```

### 6.3. Route Table de Subnets Privadas

**Route Table ID**: `<rtb-private-id>`  
**Name**: `jobber-private-RT`  
**VPC**: `<vpc-id>` (jobber-cluster-vpc)  
**Main**: No (route table explícita)  
**Owner ID**: `<account-id>`

**Subnets Asociadas (Explicit subnet associations)**: 2 subnets
- `<subnet-private-4-id>` (jobber-private-subnet-4) - `10.0.3.0/24`
- `<subnet-private-3-id>` (jobber-private-subnet-3) - `10.0.2.0/24`

**Edge associations**: Ninguna

**Rutas Configuradas**:

| Destino | Target | Estado | Propagated | Route Origin |
|---------|--------|--------|------------|--------------|
| `10.0.0.0/16` | local | Active | No | Create Route Table |
| `0.0.0.0/0` | `<nat-gateway-id>` | Active | No | Create Route |

**Nota**: La ruta al NAT Gateway está en estado "Active", lo que significa que el NAT Gateway está funcionando correctamente y las subnets privadas pueden acceder a Internet a través de él.

**Tags**:
- `Name`: `jobber-private-RT`

**Verificar rutas**:
```bash
# Ver todas las rutas de la route table privada
aws ec2 describe-route-tables --route-table-ids <rtb-private-id> --region us-east-1

# Ver solo la ruta al NAT Gateway
aws ec2 describe-route-tables --route-table-ids <rtb-private-id> --query 'RouteTables[0].Routes[?NatGatewayId==`<nat-gateway-id>`]' --region us-east-1

# Verificar estado del NAT Gateway
aws ec2 describe-nat-gateways --nat-gateway-ids <nat-gateway-id> --query 'NatGateways[0].State' --region us-east-1
# Debe devolver: "available"

# Ver subnets asociadas explícitamente
aws ec2 describe-route-tables --route-table-ids <rtb-private-id> --query 'RouteTables[0].Associations[?SubnetId!=`null`]' --region us-east-1

# Verificar que no es la route table principal
aws ec2 describe-route-tables --route-table-ids <rtb-private-id> --query 'RouteTables[0].Associations[?Main==`true`]' --region us-east-1
```

---

## 7. Diagrama de Arquitectura

```
Internet
   │
   ▼
Internet Gateway (<igw-id>)
   │
   ├─── Public Subnet 1 (10.0.0.0/24) ──► EKS Node 1
   │    <subnet-public-1-id>
   │    us-east-1a
   │
   └─── Public Subnet 2 (10.0.1.0/24) ──► EKS Node 2
        <subnet-public-2-id>
        us-east-1b
   
   NAT Gateway (<nat-gateway-id>)
   │    IP Pública: 52.91.131.114
   │    IP Privada: 10.0.0.66
   │    Subnet: jobber-public-subnet-1
   │
   ├─── Private Subnet 3 (10.0.2.0/24) ──► RDS/ElastiCache (futuro)
   │    <subnet-private-3-id>
   │    us-east-1a
   │
   └─── Private Subnet 4 (10.0.3.0/24) ──► RDS/ElastiCache (futuro)
        <subnet-private-4-id>
        us-east-1b
```

**Nota**: 
- Las subnets públicas están conectadas directamente al Internet Gateway
- Las subnets privadas acceden a Internet a través del NAT Gateway (solo salida)
- Guarda un diagrama visual en `../diagrams/` y referencia aquí.

---

## 8. Comandos Útiles

### Verificar VPC
```bash
# Ver VPC específica
aws ec2 describe-vpcs --vpc-ids <vpc-id> --region us-east-1

# Buscar VPC por nombre
aws ec2 describe-vpcs --filters "Name=tag:Name,Values=jobber-cluster-vpc" --region us-east-1
```

### Verificar Subnets
```bash
# Ver todas las subnets de la VPC
aws ec2 describe-subnets --filters "Name=vpc-id,Values=<vpc-id>" --region us-east-1

# Ver subnet específica 1
aws ec2 describe-subnets --subnet-ids <subnet-public-1-id> --region us-east-1

# Ver subnet específica 2
aws ec2 describe-subnets --subnet-ids <subnet-public-2-id> --region us-east-1

# Verificar IPs disponibles
aws ec2 describe-subnets --subnet-ids <subnet-public-1-id> --query 'Subnets[0].AvailableIpAddressCount' --region us-east-1
```

### Verificar Route Tables
```bash
# Ver route table principal (main)
aws ec2 describe-route-tables --route-table-ids rtb-030d192d899734d71 --region us-east-1

# Ver route table de subnets públicas
aws ec2 describe-route-tables --route-table-ids <rtb-public-id> --region us-east-1

# Ver todas las route tables de la VPC
aws ec2 describe-route-tables --filters "Name=vpc-id,Values=<vpc-id>" --region us-east-1

# Ver subnets asociadas a route table pública
aws ec2 describe-route-tables --route-table-ids <rtb-public-id> --query 'RouteTables[0].Associations' --region us-east-1
```

### Verificar Network ACLs
```bash
# Ver Network ACL principal
aws ec2 describe-network-acls --network-acl-ids acl-0fc86b9f08985e51d --region us-east-1
```

### Verificar DNS Configuration
```bash
# Verificar DNS resolution
aws ec2 describe-vpc-attribute --vpc-id <vpc-id> --attribute enableDnsSupport --region us-east-1

# Verificar DNS hostnames
aws ec2 describe-vpc-attribute --vpc-id <vpc-id> --attribute enableDnsHostnames --region us-east-1
```

### Verificar DHCP Options
```bash
# Ver configuración DHCP
aws ec2 describe-dhcp-options --dhcp-options-ids dopt-0f240d7a8a490dece --region us-east-1
```

---

## 9. Troubleshooting

For common networking issues, see the [Networking Troubleshooting Guide](../../../docs/troubleshooting/Networking.md).

---

## 10. Costos Estimados

| Componente | Costo Mensual |
|------------|---------------|
| VPC | Gratis |
| Subnets | Gratis |
| Internet Gateway | Gratis |
| NAT Gateway | ~$32/mes (implementado para subnets privadas) |
| Elastic IP (asociado a NAT Gateway) | Gratis (eipalloc-048817d7acd91e9e2) |
| Network ACLs | Gratis |
| Route Tables | Gratis |
| DHCP Options Set | Gratis |
| Data Transfer | Variable (depende del uso) |

**Total Networking**: Solo pagas por data transfer fuera de la VPC (si aplica).

---

## 11. Información de Referencia Rápida

### IDs Importantes

| Componente | ID | Nombre |
|-----------|-----|--------|
| VPC ID | `<vpc-id>` | `jobber-cluster-vpc` |
| Internet Gateway | `<igw-id>` | `jobber-igw` |
| Public Subnet 1 | `<subnet-public-1-id>` | `jobber-public-subnet-1` |
| Public Subnet 2 | `<subnet-public-2-id>` | `jobber-public-subnet-2` |
| Private Subnet 3 | `<subnet-private-3-id>` | `jobber-private-subnet-3` |
| Private Subnet 4 | `<subnet-private-4-id>` | `jobber-private-subnet-4` |
| Public Route Table | `<rtb-public-id>` | `jobber-public-RT` |
| Private Route Table | `<rtb-private-id>` | `jobber-private-RT` |
| NAT Gateway | `<nat-gateway-id>` | - |
| Elastic IP | `eipalloc-048817d7acd91e9e2` | `52.91.131.114` (asociado a NAT Gateway) |
| Main Route Table | `rtb-030d192d899734d71` | - |
| Main Network ACL | `acl-0fc86b9f08985e51d` | - |
| DHCP Option Set | `dopt-0f240d7a8a490dece` | - |
| Owner ID | `<account-id>` | - |

### Comandos Rápidos

```bash
# Ver VPC
aws ec2 describe-vpcs --vpc-ids <vpc-id> --region us-east-1

# Ver Internet Gateway
aws ec2 describe-internet-gateways --internet-gateway-ids <igw-id> --region us-east-1

# Ver subnets públicas
aws ec2 describe-subnets --subnet-ids <subnet-public-1-id> <subnet-public-2-id> --region us-east-1

# Ver subnets privadas
aws ec2 describe-subnets --subnet-ids <subnet-private-3-id> <subnet-private-4-id> --region us-east-1

# Ver route table pública
aws ec2 describe-route-tables --route-table-ids <rtb-public-id> --region us-east-1

# Ver route table privada
aws ec2 describe-route-tables --route-table-ids <rtb-private-id> --region us-east-1

# Ver NAT Gateway
aws ec2 describe-nat-gateways --nat-gateway-ids <nat-gateway-id> --region us-east-1

# Ver Elastic IP
aws ec2 describe-addresses --allocation-ids eipalloc-048817d7acd91e9e2 --region us-east-1
```

---

## 📚 Referencias

- [AWS VPC Documentation](https://docs.aws.amazon.com/vpc/)
- [EKS Networking Best Practices](https://aws.github.io/aws-eks-best-practices/networking/)
- [eksctl Networking](https://eksctl.io/usage/vpc-networking/)
- [VPC DNS Configuration](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-dns.html)

