# 💰 Costos y Recursos - Jobber Platform

**Nota**: Este documento contiene ejemplos de planificación de capacidad y costos. Los valores mostrados son ejemplos y deben ajustarse según tu entorno específico.

---

## 📋 Resumen

Planificación de capacidad y costos para entorno de demostración. Todos los servicios y bases de datos corren en Pods de Kubernetes dentro del cluster EKS.

**Carga esperada (ejemplo)**: 10-20 usuarios simultáneos, 20 solicitudes/segundo en pico

---

## 📊 Desglose de Recursos por Componente

### Microservicios y Frontend

| Componente | CPU (mCPU) | RAM (MiB) | RAM (GiB) |
|------------|------------|-----------|-----------|
| Frontend | <ejemplo> | <ejemplo> | <ejemplo> |
| Gateway | <ejemplo> | <ejemplo> | <ejemplo> |
| Auth Service | <ejemplo> | <ejemplo> | <ejemplo> |
| Users Service | <ejemplo> | <ejemplo> | <ejemplo> |
| Gig Service | <ejemplo> | <ejemplo> | <ejemplo> |
| Chat Service | <ejemplo> | <ejemplo> | <ejemplo> |
| Order Service | <ejemplo> | <ejemplo> | <ejemplo> |
| Review Service | <ejemplo> | <ejemplo> | <ejemplo> |
| Notification Service | <ejemplo> | <ejemplo> | <ejemplo> |
| Message Queue (RabbitMQ) | <ejemplo> | <ejemplo> | <ejemplo> |
| **Subtotal Microservicios** | **<total> mCPU** | **<total> MiB** | **~<total> GiB** |

**Ejemplo de cálculo:**
- Sumar CPU de todos los microservicios
- Sumar RAM de todos los microservicios
- Agregar overhead para cola de mensajes

### Bases de Datos (en Pods)

| Componente | CPU (mCPU) | RAM (MiB) | RAM (GiB) |
|------------|------------|-----------|-----------|
| MySQL | <ejemplo> | <ejemplo> | <ejemplo> |
| PostgreSQL | <ejemplo> | <ejemplo> | <ejemplo> |
| MongoDB | <ejemplo> | <ejemplo> | <ejemplo> |
| Redis | <ejemplo> | <ejemplo> | <ejemplo> |
| **Subtotal Bases de Datos** | **<total> mCPU** | **<total> MiB** | **~<total> GiB** |

### Observabilidad (Opcional)

| Componente | CPU (mCPU) | RAM (MiB) | RAM (GiB) |
|------------|------------|-----------|-----------|
| Elasticsearch | <ejemplo> | <ejemplo> | <ejemplo> |
| Kibana | <ejemplo> | <ejemplo> | <ejemplo> |
| Metricbeat (por nodo) | <ejemplo> | <ejemplo> | <ejemplo> |
| Heartbeat | <ejemplo> | <ejemplo> | <ejemplo> |
| **Subtotal Observabilidad** | **<total> mCPU** | **<total> MiB** | **~<total> GiB** |

### Total de Recursos

| Categoría | CPU (mCPU) | CPU (vCPU) | RAM (GiB) |
|-----------|------------|------------|-----------|
| Microservicios + Frontend | <total> | <total> | <total> |
| Bases de Datos | <total> | <total> | <total> |
| **Total Base (sin observabilidad)** | **<total>** | **<total>** | **<total>** |
| Observabilidad | <total> | <total> | <total> |
| **Total Completo** | **<total>** | **<total>** | **<total>** |

---

## 🧮 Cálculo de Instancia Requerida

### Paso 1: Consumo Base (sin observabilidad)
- CPU: **<total> vCPU**
- RAM: **<total> GiB**

### Paso 2: Overhead de Kubernetes (25%)
Kubernetes y componentes del sistema requieren recursos adicionales:

**Fórmula:**
- CPU: `<consumo-base> vCPU × 1.25 = <total> vCPU`
- RAM: `<consumo-base> GiB × 1.25 = <total> GiB`

**Concepto**: El overhead de Kubernetes incluye componentes del sistema como kubelet, kube-proxy, CNI, etc.

### Paso 3: Margen para Picos (30%)
Reserva para manejar picos de carga y variaciones:

**Fórmula:**
- CPU: `<consumo-con-overhead> vCPU × 1.30 = <total> vCPU`
- RAM: `<consumo-con-overhead> GiB × 1.30 = <total> GiB`

**Concepto**: El margen permite manejar picos de tráfico sin degradación del servicio.

### Paso 4: Selección de Instancia

| Instancia | vCPU | RAM | CPU Suficiente | RAM Suficiente | Costo/mes (ejemplo) |
|-----------|------|-----|---------------|----------------|---------------------|
| `t3.small` | 2 (burstable) | 2 GiB | Evaluar según requerimientos | Evaluar según requerimientos | ~$15-20 |
| `t3a.medium` | 2 (burstable) | 4 GiB | Evaluar según requerimientos | Evaluar según requerimientos | ~$30-35 |
| `t3.large` | 2 (burstable) | 8 GiB | Evaluar según requerimientos | Evaluar según requerimientos | ~$60-65 |

**Criterios de selección:**
- ✅ CPU suficiente: `vCPU_instancia > vCPU_requeridos`
- ✅ RAM suficiente: `RAM_instancia > RAM_requeridos` (con margen razonable)
- ✅ Costo optimizado: Balance entre recursos y costo
- ⚠️ Nota: Instancias t3 son burstable, pueden tener throttling si exceden baseline

**Ejemplo de decisión:**
- Si requieres `<X> vCPU` y `<Y> GiB RAM`, selecciona la instancia más pequeña que cumpla ambos requisitos.

---

## 💰 Costos Mensuales

### Componentes Principales

| Recurso | Costo/mes (ejemplo) | Notas |
|---------|---------------------|-------|
| **EKS Control Plane** | ~$70-75 | Fijo, no se puede eliminar |
| **Nodo EC2** | Variable | Depende del tipo de instancia seleccionado |
| **EBS Storage** | Variable | Depende del tamaño y tipo de volumen |
| **ALB (Opcional)** | ~$15-20 | Solo si necesitas dominio público |
| **Route 53 (Opcional)** | ~$0.50 | Hosted zone |
| **CloudWatch** | ~$5-10 | Logs y métricas básicas |

### Fórmulas de Cálculo

**EBS Storage:**
```
Costo EBS = (Tamaño en GiB × Precio por GiB/mes) × Número de volúmenes
Ejemplo: 20 GiB gp3 × $0.12/GiB/mes = ~$2.40/mes
```

**Total Estimado:**
```
Total = EKS Control Plane + Nodo EC2 + EBS Storage + Servicios Opcionales
```

**Ejemplos de totales:**
- **Mínimo (sin ALB)**: ~$100-120/mes (depende de instancia)
- **Con ALB y dominio**: ~$120-140/mes
- **Con escalado a 0 nodos**: ~$70-75/mes (solo control plane)

---

## 🗄️ Ahorro: Bases de Datos en Pods vs Externas

### Recursos Consumidos por Bases de Datos en Pods

| Base de Datos | CPU (mCPU) | RAM (GiB) | EBS Storage | Costo EBS/mes (ejemplo) |
|---------------|------------|-----------|-------------|------------------------|
| MySQL | <ejemplo> | <ejemplo> | <ejemplo> GiB | ~$1-2 |
| PostgreSQL | <ejemplo> | <ejemplo> | <ejemplo> GiB | ~$1-2 |
| MongoDB | <ejemplo> | <ejemplo> | <ejemplo> GiB | ~$1-2 |
| Redis | <ejemplo> | <ejemplo> | <ejemplo> GiB | ~$0.5-1 |
| **TOTAL** | **<total> mCPU** | **<total> GiB** | **<total> GiB** | **~$4-8/mes** |

### Comparación de Costos

| Opción | Costo/mes (ejemplo) | Notas |
|--------|---------------------|-------|
| **Bases de Datos en Pods** | ~$4-8 | Solo EBS storage, recursos incluidos en nodo |
| **RDS Free Tier** | $0 | MySQL/Postgres (750h/mes, limitado) |
| **RDS db.t3.micro** | ~$15 c/u | MySQL y Postgres = ~$30/mes |
| **DocumentDB db.t3.medium** | ~$100-120 | MongoDB administrado |
| **ElastiCache cache.t3.micro** | ~$10-15 | Redis administrado |
| **Total con servicios externos** | ~$150-170/mes | RDS + DocumentDB + ElastiCache |

### Ahorro Estimado

**Usando bases de datos en Pods:**
- Costo directo: ~$4-8/mes (solo EBS)
- Recursos consumidos: Incluidos en nodo (CPU/RAM compartidos)
- **Ahorro vs servicios externos: ~$140-160/mes**

**Ventajas de usar Pods:**
- ✅ Costo mínimo (~$4-8/mes vs ~$150-170/mes)
- ✅ Control total sobre configuración
- ✅ Sin latencia de red externa
- ✅ Unificación del stack en Kubernetes

**Desventajas:**
- ⚠️ Backups manuales (snapshots EBS)
- ⚠️ Sin alta disponibilidad nativa Multi-AZ
- ⚠️ Mantenimiento manual (updates, patches)

**Decisión**: Para entorno de demostración, bases de datos en Pods son la opción más económica y adecuada.

---

## 📊 Configuración de Recursos

### Requests & Limits Recomendados

| Tipo | Request CPU | Request RAM | Limit CPU | Limit RAM |
|------|-------------|-------------|-----------|-----------|
| Microservicios | <ejemplo> mCPU | <ejemplo> MiB | <ejemplo> mCPU | <ejemplo> GiB |
| Bases de Datos | <ejemplo> mCPU | <ejemplo> MiB | <ejemplo> mCPU | <ejemplo> GiB |
| Elasticsearch | <ejemplo> mCPU | <ejemplo> GiB | <ejemplo> mCPU | <ejemplo> GiB |
| Kibana | <ejemplo> mCPU | <ejemplo> GiB | <ejemplo> mCPU | <ejemplo> GiB |

**Concepto:**
- **Requests**: Recursos garantizados para el pod
- **Limits**: Máximo de recursos que el pod puede usar

### Réplicas

| Servicio | Réplicas | Razón |
|----------|----------|-------|
| Gateway | 1-2 | HPA escala según carga |
| Otros servicios | 1 | Demo tolera downtime breve |

### Escalado Automático

**HPA (Horizontal Pod Autoscaler):**
- Métrica: CPU 70%
- Mínimo: 1 réplica
- Máximo: 2 réplicas (configurable)

**Cluster Autoscaler:**
- Mínimo: 1 nodo
- Máximo: 2 nodos (configurable)

**KEDA (Opcional):**
- Escalar a 0 durante horas bajas
- Útil para ahorrar costos en demos

---

## 🔧 Optimización de Costos

### Estrategias de Ahorro

1. **Escalar a 0 nodos fuera de horario**
   - Ahorro: ~$30-40/mes (depende de instancia)
   - Comando: `eksctl scale nodegroup --nodes 0 --cluster <cluster-name>`
   - **Concepto**: Eliminar nodos cuando no se usan reduce costos de EC2

2. **Eliminar ALB cuando no se use**
   - Ahorro: ~$15-20/mes
   - Alternativa: Usar `kubectl port-forward` para demos privadas
   - **Concepto**: ALB tiene costo fijo mensual, eliminarlo cuando no se necesita

3. **Eliminar observabilidad pesada si no se necesita**
   - Ahorro: Libera CPU/RAM significativos
   - Permite usar instancia más pequeña = ahorro adicional
   - **Concepto**: Observabilidad consume recursos, evaluar si es necesaria para demo

4. **Usar instancias Graviton (t4g)**
   - Ahorro: ~15% adicional vs instancias x86
   - Requisito: Imágenes ARM64 compatibles
   - **Concepto**: Instancias ARM ofrecen mejor precio/rendimiento

5. **Optimizar tamaño de EBS**
   - Revisar volúmenes no utilizados
   - Usar gp3 en lugar de gp2 (mejor precio/rendimiento)
   - **Concepto**: EBS se cobra por GiB, optimizar según necesidad real

---

## ⚠️ Consideraciones

### Tolerancia y Requisitos

- ✅ Tolerancia a downtime fuera de horario (configurable)
- ✅ No requiere multi-AZ para demo
- ✅ Costo optimizado es prioridad

### Limitaciones

- ⚠️ Instancias burstable (t3) pueden tener throttling si exceden baseline
- ⚠️ Escalar a 0 puede causar cold starts
- ⚠️ Sin backups automáticos (requiere snapshots manuales)
- ⚠️ Sin alta disponibilidad nativa

### Recomendaciones

- Monitorear uso de CPU credits en instancias burstable
- Configurar alertas para recursos críticos
- Documentar procedimientos de backup
- Revisar costos mensualmente

---

## 📚 Referencias

- [AWS Pricing Calculator](https://calculator.aws/)
- [EKS Pricing](https://aws.amazon.com/eks/pricing/)
- [EC2 Instance Types](https://aws.amazon.com/ec2/instance-types/)
- [EBS Pricing](https://aws.amazon.com/ebs/pricing/)

---

## 📊 Comparación de Escenarios

### Escenario 1: Producción (Bases de Datos Externas)

**Características:**
- Bases de datos administradas (RDS Aurora, DocumentDB, ElastiCache)
- Alta disponibilidad Multi-AZ
- Backups automáticos
- Mantenimiento automático
- Múltiples nodos para alta disponibilidad

**Componentes típicos:**
- EKS Control Plane
- Múltiples nodos EC2 (3+ nodos)
- Bases de datos externas (Aurora MySQL, Aurora PostgreSQL, DocumentDB, ElastiCache)
- ALB para tráfico público
- NAT Gateway para subnets privadas
- Route 53 para DNS

**Ventajas:**
- ✅ Alta disponibilidad nativa
- ✅ Backups automáticos
- ✅ Mantenimiento automático
- ✅ Mejor rendimiento y escalado automático

**Desventajas:**
- ⚠️ Costo significativamente mayor (bases de datos externas)
- ⚠️ Latencia de red adicional

### Escenario 2: Demo/Portafolio (Bases de Datos en Pods)

**Características:**
- Bases de datos en Pods de Kubernetes
- Configuración mínima para demo
- Control total sobre configuración
- Backups manuales (snapshots EBS)

**Componentes típicos:**
- EKS Control Plane
- 1 nodo EC2 (escalable según necesidad)
- Bases de datos en Pods (StatefulSets)
- EBS Storage para persistencia
- ALB opcional (puede usar port-forward para demos privadas)

**Ventajas:**
- ✅ Costo mínimo (solo EBS storage)
- ✅ Control total sobre configuración
- ✅ Sin latencia de red externa
- ✅ Unificación del stack en Kubernetes

**Desventajas:**
- ⚠️ Backups manuales (snapshots EBS)
- ⚠️ Sin alta disponibilidad nativa Multi-AZ
- ⚠️ Mantenimiento manual (updates, patches)

### Comparación Conceptual

| Aspecto | Producción (Externas) | Demo/Portafolio (Pods) |
|---------|----------------------|------------------------|
| **Bases de Datos** | Servicios administrados (RDS, DocumentDB, ElastiCache) | StatefulSets en Kubernetes |
| **Costo Bases de Datos** | Alto (servicios administrados) | Bajo (solo EBS storage) |
| **Alta Disponibilidad** | Multi-AZ nativo | Manual (múltiples réplicas) |
| **Backups** | Automáticos | Manuales (snapshots) |
| **Mantenimiento** | Automático | Manual |
| **Nodos EC2** | Múltiples (3+) | Mínimo (1-2) |
| **Uso Ideal** | Producción real | Demo, desarrollo, portafolio |

### Estrategias de Ahorro con Cron

**Concepto**: Usar KEDA Cron para escalar pods y nodos a 0 durante horas no laborales.

**Ejemplo de horario:**
- **Lunes-Viernes**: 08:00 - 22:00 (activo)
- **Fin de semana**: Apagado (0 réplicas)

**Ahorro potencial:**
- Escalar nodos a 0: Ahorro del costo del nodo durante horas inactivas
- Escalar pods a 0: Libera recursos, permite apagar nodos
- **Nota**: Las bases de datos externas (RDS, etc.) siguen corriendo 24/7, por lo que el ahorro es limitado

**Fórmula de ahorro con cron:**
```
Ahorro mensual = (Costo nodo/mes) × (Horas apagadas / Horas totales del mes)
Ejemplo: $30/mes × (12h/día × 5 días/semana / 720h/mes) ≈ $2.5/mes
```

**Para bases de datos en Pods:**
- El ahorro es mayor porque las bases de datos también se apagan
- Permite escalar nodos a 0 completamente

### Decisión: ¿Cuándo usar cada escenario?

**Usar Producción (Bases de Datos Externas) si:**
- Requieres alta disponibilidad real
- Necesitas backups automáticos
- Tienes presupuesto para servicios administrados
- Requieres rendimiento y escalado automático

**Usar Demo/Portafolio (Bases de Datos en Pods) si:**
- Es un proyecto de demostración o portafolio
- El costo es una prioridad
- Puedes tolerar downtime breve
- Tienes control sobre mantenimiento manual

---

**Nota**: Todos los valores de costo y recursos en este documento son ejemplos y pueden variar según región, uso real y cambios en precios de AWS. Siempre verifica los precios actuales usando el AWS Pricing Calculator.
