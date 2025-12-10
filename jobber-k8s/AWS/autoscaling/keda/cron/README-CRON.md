# Guía de KEDA Cron - Escalar a 0 en Horarios Específicos

Esta guía documenta cómo usar KEDA Cron para escalar tu aplicación a 0 réplicas en horarios específicos y ahorrar dinero en EKS.

---

## 1. ¿Qué es KEDA Cron?

**KEDA Cron** es un scaler que permite escalar deployments basándose en horarios específicos (expresiones cron).

**Caso de uso principal**: Apagar tu aplicación completa en horarios específicos para ahorrar dinero en EKS.

**Ejemplo**: Escalar a 0 réplicas de 22:00 a 08:00 (horario de descanso).

---

## 2. Prerrequisitos

- KEDA instalado en el clúster (ver `../README-KEDA.md`)
- Deployment funcionando (ej: `jobber-gateway`)
- **⚠️ IMPORTANTE**: NO tener HPA en el mismo deployment (chocan)

---

## 3. ⚠️ IMPORTANTE: Eliminar HPA antes de usar KEDA Cron

**Si tu deployment ya tiene un HPA, debes eliminarlo primero:**

```powershell
# Ver si tienes HPA en el gateway
kubectl get hpa -n production

# Eliminar HPA del gateway (si existe)
kubectl delete hpa jobber-gateway -n production

# Verificar que se eliminó
kubectl get hpa -n production
```

**Razón**: HPA y KEDA Cron no pueden controlar el mismo deployment al mismo tiempo (chocan).

**Alternativa**: Si quieres mantener escalado por CPU, usa KEDA con múltiples triggers (Cron + CPU) en lugar de HPA manual.

---

## 4. Formato Cron

**Formato**: `minuto hora día mes día-semana`

**Días de la semana**: 
- `0` = Domingo
- `1` = Lunes
- `2` = Martes
- `3` = Miércoles
- `4` = Jueves
- `5` = Viernes
- `6` = Sábado

### Ejemplos de expresiones cron:

- `0 8 * * *` = 08:00 todos los días
- `0 22 * * *` = 22:00 todos los días
- `0 9 * * 1-5` = 09:00 de lunes a viernes (días laborables)
- `0 18 * * 0,6` = 18:00 sábados y domingos (fines de semana)
- `0 0 * * 0` = 00:00 todos los domingos

**Rangos y listas**:
- `1-5` = Lunes a Viernes
- `0,6` = Sábado y Domingo
- `*` = Todos los días

---

## 5. Ejemplos de Configuración

### 5.1. Ejemplo básico: Apagar de noche (22:00-08:00)

```yaml
apiVersion: keda.sh/v1alpha1
kind: ScaledObject
metadata:
  name: jobber-gateway-cron-scaledobject
  namespace: production
spec:
  scaleTargetRef:
    name: jobber-gateway
    kind: Deployment
  minReplicaCount: 0      # Puede escalar a 0
  maxReplicaCount: 2      # Máximo 2 réplicas
  triggers:
  # Horario activo: 08:00 - 22:00 (1 réplica)
  - type: cron
    metadata:
      timezone: America/Mexico_City
      start: "0 8 * * *"      # 08:00 AM todos los días
      end: "0 22 * * *"       # 10:00 PM todos los días
      desiredReplicas: "1"
  # Horario inactivo: 22:00 - 08:00 (0 réplicas)
  - type: cron
    metadata:
      timezone: America/Mexico_City
      start: "0 22 * * *"     # 10:00 PM todos los días
      end: "0 8 * * *"        # 08:00 AM (día siguiente)
      desiredReplicas: "0"
```

**Archivo**: `gateway-cron-scaledobject.yaml`

**Resultado:**
- **08:00-22:00**: ✅ Encendido (1 réplica)
- **22:00-08:00**: ❌ Apagado (0 réplicas)

---

### 5.2. Ejemplo: Apagar fines de semana

**Caso de uso**: Apagar aplicación los fines de semana (sábado y domingo) y mantenerla encendida en horario laboral.

```yaml
apiVersion: keda.sh/v1alpha1
kind: ScaledObject
metadata:
  name: jobber-gateway-cron-weekend-scaledobject
  namespace: production
spec:
  scaleTargetRef:
    name: jobber-gateway
    kind: Deployment
  minReplicaCount: 0
  maxReplicaCount: 2
  triggers:
  # Horario laboral: Lunes-Viernes 08:00-20:00 (1 réplica)
  - type: cron
    metadata:
      timezone: America/Mexico_City
      start: "0 8 * * 1-5"      # 08:00 Lunes-Viernes
      end: "0 20 * * 1-5"        # 20:00 Lunes-Viernes
      desiredReplicas: "1"
  # Fines de semana: Sábado-Domingo (0 réplicas - apagado)
  - type: cron
    metadata:
      timezone: America/Mexico_City
      start: "0 0 * * 0"         # 00:00 Domingo
      end: "0 23 * * 6"          # 23:59 Sábado
      desiredReplicas: "0"
  # Noche laboral: Lunes-Viernes 20:00-08:00 (0 réplicas)
  - type: cron
    metadata:
      timezone: America/Mexico_City
      start: "0 20 * * 1-5"      # 20:00 Lunes-Viernes
      end: "0 8 * * 2-6"         # 08:00 Martes-Sábado (día siguiente)
      desiredReplicas: "0"
```

**Archivo**: `gateway-cron-weekend.yaml`

**Resultado:**
- **Lunes-Viernes 08:00-20:00**: ✅ Encendido (1 réplica)
- **Lunes-Viernes 20:00-08:00**: ❌ Apagado (0 réplicas)
- **Sábado-Domingo todo el día**: ❌ Apagado (0 réplicas)

---

### 5.3. Ejemplo: Horarios personalizados por día

**Caso de uso**: Diferentes horarios según el día de la semana.

```yaml
apiVersion: keda.sh/v1alpha1
kind: ScaledObject
metadata:
  name: jobber-gateway-cron-scaledobject
  namespace: production
spec:
  scaleTargetRef:
    name: jobber-gateway
    kind: Deployment
  minReplicaCount: 0
  maxReplicaCount: 2
  triggers:
  # Lunes-Viernes: 08:00-18:00 (horario laboral)
  - type: cron
    metadata:
      timezone: America/Mexico_City
      start: "0 8 * * 1-5"
      end: "0 18 * * 1-5"
      desiredReplicas: "1"
  # Sábado: 10:00-14:00 (medio día)
  - type: cron
    metadata:
      timezone: America/Mexico_City
      start: "0 10 * * 6"
      end: "0 14 * * 6"
      desiredReplicas: "1"
  # Domingo: Apagado todo el día
  - type: cron
    metadata:
      timezone: America/Mexico_City
      start: "0 0 * * 0"
      end: "0 23 * * 0"
      desiredReplicas: "0"
```

**Resultado:**
- **Lunes-Viernes 08:00-18:00**: ✅ Encendido
- **Sábado 10:00-14:00**: ✅ Encendido
- **Domingo todo el día**: ❌ Apagado
- **Resto del tiempo**: ❌ Apagado

---

## 6. Aplicar ScaledObject con Cron

### Para probar en Minikube primero:

```powershell
# Ver guía completa de pruebas en Minikube
# jobber-k8s/minikube/autoscaling/keda/cron/README-CRON.md

# Aplicar ScaledObject de prueba
kubectl apply -f jobber-k8s/minikube/autoscaling/keda/cron/gateway-cron-test.yaml
```

### Para producción (EKS):

```powershell
# Aplicar ScaledObject básico (22:00-08:00)
kubectl apply -f jobber-k8s/AWS/autoscaling/keda/cron/gateway-cron-scaledobject.yaml

# O para fines de semana:
kubectl apply -f jobber-k8s/AWS/autoscaling/keda/cron/gateway-cron-weekend.yaml

#
kubectl get scaledobject -n production
kubectl describe scaledobject jobber-gateway-cron-scaledobject -n production
```

---

## 7. Verificar escalado automático por horario

```powershell
# Monitorear réplicas en tiempo real
kubectl get deployment jobber-gateway -n production -w

# Ver estado del ScaledObject
kubectl get scaledobject jobber-gateway-cron-scaledobject -n production

# Ver detalles (muestra próximos horarios de escalado)
kubectl describe scaledobject jobber-gateway-cron-scaledobject -n production
```

**Nota**: El escalado por Cron no es instantáneo. Funciona según el horario configurado:
- Si configuraste 22:00-08:00, espera a las 22:00 para ver el escalado a 0
- Si configuraste 08:00-22:00, espera a las 08:00 para ver el escalado a 1

---

## 8. Escalar múltiples servicios con Cron

Si quieres apagar **todos tus servicios** en horarios específicos, crea un ScaledObject para cada uno:

**Ejemplo: Apagar todos los servicios de 22:00 a 08:00**

```powershell
# Crear ScaledObjects para cada servicio
# gateway-cron-scaledobject.yaml
# auth-cron-scaledobject.yaml
# users-cron-scaledobject.yaml
# gig-cron-scaledobject.yaml
# chat-cron-scaledobject.yaml
# order-cron-scaledobject.yaml
# review-cron-scaledobject.yaml
```

**Template para cada servicio:**

```yaml
apiVersion: keda.sh/v1alpha1
kind: ScaledObject
metadata:
  name: jobber-<SERVICE>-cron-scaledobject
  namespace: production
spec:
  scaleTargetRef:
    name: jobber-<SERVICE>
    kind: Deployment
  minReplicaCount: 0
  maxReplicaCount: 2
  triggers:
  - type: cron
    metadata:
      timezone: America/Mexico_City
      start: "0 8 * * *"
      end: "0 22 * * *"
      desiredReplicas: "1"
  - type: cron
    metadata:
      timezone: America/Mexico_City
      start: "0 22 * * *"
      end: "0 8 * * *"
      desiredReplicas: "0"
```

**Reemplaza `<SERVICE>` con**: `gateway`, `auth`, `users`, `gig`, `chat`, `order`, `review`, etc.

---

## 9. Zonas horarias comunes

```yaml
# México
timezone: America/Mexico_City

# USA (Este)
timezone: America/New_York

# USA (Oeste)
timezone: America/Los_Angeles

# UTC
timezone: UTC

# España
timezone: Europe/Madrid
```

**Ver todas las zonas horarias**: https://en.wikipedia.org/wiki/List_of_tz_database_time_zones

---

## 10. Capturas de pantalla para documentación

Guarda las capturas en: `jobber-k8s/AWS/autoscaling/keda/cron/images/`

1. **Estado inicial (antes de aplicar KEDA Cron)** → `cron-before.png`
   ```powershell
   kubectl get deployment jobber-gateway -n production
   kubectl get pods -n production -l app=jobber-gateway
   ```

2. **ScaledObject configurado** → `cron-scaledobject.png`
   ```powershell
   kubectl get scaledobject -n production
   kubectl describe scaledobject jobber-gateway-cron-scaledobject -n production
   ```

3. **Deployment escalado a 0 (horario inactivo)** → `cron-scaled-to-zero.png`
   ```powershell
   kubectl get deployment jobber-gateway -n production
   kubectl get pods -n production -l app=jobber-gateway
   ```

4. **Deployment escalado a 1 (horario activo)** → `cron-scaled-to-one.png`
   ```powershell
   kubectl get deployment jobber-gateway -n production
   kubectl get pods -n production -l app=jobber-gateway
   ```

5. **Describe detallado del ScaledObject** → `cron-describe.png`
   ```powershell
   kubectl describe scaledobject jobber-gateway-cron-scaledobject -n production
   ```

---

## 11. Troubleshooting

| Síntoma | Diagnóstico | Acción |
| --- | --- | --- |
| ScaledObject no escala | Horario no ha llegado o configuración incorrecta | Verificar horario actual y expresión cron |
| Deployment no escala a 0 | `minReplicaCount` no está en 0 o hay conflicto con HPA | Verificar `minReplicaCount: 0` y eliminar HPA |
| Conflicto con HPA | HPA y KEDA Cron en el mismo deployment | Eliminar HPA antes de usar KEDA Cron |
| Escalado no funciona | KEDA no está funcionando | Verificar pods de KEDA: `kubectl get pods -n keda-system` |

### Comandos de diagnóstico:

```powershell
# Verificar que KEDA está funcionando
kubectl get pods -n keda-system

# Ver logs de KEDA
kubectl logs -n keda-system -l app=keda-operator --tail=100

# Ver detalles del ScaledObject
kubectl describe scaledobject jobber-gateway-cron-scaledobject -n production

# Ver eventos
kubectl get events -n production --sort-by='.lastTimestamp' | Select-String -Pattern "scaledobject" -Context 0,2
```

---

## 12. KEDA Cron vs HPA

**⚠️ NO uses HPA manual y KEDA Cron en el mismo deployment**

**Problema**: Si tienes un HPA manual y un ScaledObject de KEDA Cron apuntando al mismo deployment, **chocarán** porque ambos intentan controlar las réplicas.

**Opciones:**
1. **Eliminar HPA y usar solo KEDA Cron** (si quieres apagar en horarios específicos)
2. **Usar KEDA con múltiples triggers** (Cron + CPU) en lugar de HPA manual ⭐ **Recomendado**
3. **Mantener HPA y NO usar KEDA Cron** (si no necesitas apagar en horarios específicos)

**Estrategia recomendada:**
- **Durante horario activo (08:00-22:00)**: KEDA Cron mantiene 1 réplica, pero puedes usar KEDA con trigger de CPU para escalar más si es necesario
- **Durante horario inactivo (22:00-08:00)**: KEDA Cron escala a 0 réplicas (ahorra dinero)

---

## 12.1. Usar KEDA con múltiples triggers (Cron + CPU)

**Ventaja**: Reemplaza HPA manual y te da control por horario + escalado por CPU en un solo ScaledObject.

### 12.1.1. Configuración completa: Cron + CPU

**Ejemplo completo para `jobber-gateway`:**

```yaml
apiVersion: keda.sh/v1alpha1
kind: ScaledObject
metadata:
  name: jobber-gateway-keda-scaledobject
  namespace: production
spec:
  scaleTargetRef:
    name: jobber-gateway
    kind: Deployment
  minReplicaCount: 0      # Puede escalar a 0 en horario inactivo
  maxReplicaCount: 5      # Máximo 5 réplicas durante picos de carga
  triggers:
  # Trigger 1: Cron - Horario activo (08:00-22:00)
  - type: cron
    metadata:
      timezone: America/Mexico_City
      start: "0 8 * * *"      # 08:00 AM todos los días
      end: "0 22 * * *"       # 10:00 PM todos los días
      desiredReplicas: "1"    # Mínimo 1 réplica durante horario activo
  # Trigger 2: Cron - Horario inactivo (22:00-08:00)
  - type: cron
    metadata:
      timezone: America/Mexico_City
      start: "0 22 * * *"     # 10:00 PM todos los días
      end: "0 8 * * *"        # 08:00 AM (día siguiente)
      desiredReplicas: "0"    # Apagar completamente en horario inactivo
  # Trigger 3: CPU - Escalar por CPU durante horario activo
  - type: cpu
    metadata:
      type: Utilization
      value: "70"             # Escalar cuando CPU > 70%
```

**Archivo**: `gateway-keda-combined-scaledobject.yaml`

> **📁 Archivo completo disponible**: `jobber-k8s/AWS/autoscaling/keda/cron/gateway-keda-combined-scaledobject.yaml`

### 12.1.2. Cómo funciona

**Durante horario activo (08:00-22:00):**
1. **Cron trigger** mantiene mínimo 1 réplica
2. **CPU trigger** escala automáticamente si CPU > 70%
3. **Máximo**: 5 réplicas (configurado en `maxReplicaCount`)

**Durante horario inactivo (22:00-08:00):**
1. **Cron trigger** escala a 0 réplicas (ignora CPU trigger)
2. **Ahorro**: No se consumen recursos durante la noche

### 12.1.3. Aplicar configuración

```powershell
# 1. Eliminar HPA si existe
kubectl delete hpa jobber-gateway -n production

# 2. Aplicar ScaledObject con múltiples triggers
kubectl apply -f jobber-k8s/AWS/autoscaling/keda/cron/gateway-keda-combined-scaledobject.yaml

# 3. Verificar
kubectl get scaledobject jobber-gateway-keda-scaledobject -n production
kubectl describe scaledobject jobber-gateway-keda-scaledobject -n production
```

### 12.1.4. Verificar funcionamiento

```powershell
# Ver estado del ScaledObject (muestra todos los triggers)
kubectl describe scaledobject jobber-gateway-keda-scaledobject -n production

# Monitorear réplicas en tiempo real
kubectl get deployment jobber-gateway -n production -w

# Ver métricas de CPU
kubectl top pods -n production -l app=jobber-gateway
```

**Salida esperada del `describe`:**
```
Triggers:
  Type     Reason           Message
  ----     ------           -------
  cron     Active           Cron trigger active: 08:00-22:00 (1 replica)
  cron     Inactive         Cron trigger inactive: 22:00-08:00 (0 replicas)
  cpu      Active           CPU utilization: 45% (below threshold 70%)
```

### 12.1.5. Ajustar umbrales de CPU

**Si quieres escalar más agresivamente:**
```yaml
- type: cpu
  metadata:
    type: Utilization
    value: "50"  # Escalar cuando CPU > 50% (más sensible)
```

**Si quieres escalar menos agresivamente:**
```yaml
- type: cpu
  metadata:
    type: Utilization
    value: "85"  # Escalar cuando CPU > 85% (menos sensible)
```

### 12.1.6. Ventajas vs HPA manual

| Característica | HPA Manual | KEDA (Cron + CPU) |
|----------------|------------|-------------------|
| Escalado por CPU | ✅ Sí | ✅ Sí |
| Escalado por horario | ❌ No | ✅ Sí |
| Escalar a 0 | ❌ No (HPA mínimo 1) | ✅ Sí |
| Un solo recurso | ❌ No (HPA + CronJob) | ✅ Sí (ScaledObject) |
| Configuración | Más compleja | Más simple |

---

## 12.2. Escalar nodos a 0 en horarios específicos

**Objetivo**: Cuando todos los pods están en 0 réplicas, también apagar los nodos EC2 para ahorrar dinero.

**⚠️ IMPORTANTE**: Cluster Autoscaler (CA) puede escalar nodos a 0, pero requiere configuración adicional.

### 12.2.1. Prerrequisitos

1. **Cluster Autoscaler instalado** (ver `../../README-CLUSTER-AUTOSCALER.md`)
2. **Nodegroup configurado con `nodes-min: 0`** (permite escalar a 0 nodos)
3. **KEDA Cron configurado** para escalar pods a 0

### 12.2.2. Configurar nodegroup para permitir 0 nodos

**Si creaste el nodegroup con `eksctl`:**

```powershell
# Ver nodegroup actual
eksctl get nodegroup --cluster jobberapp-demo --region us-east-1

# Actualizar nodegroup para permitir 0 nodos
eksctl scale nodegroup \
  --cluster jobberapp-demo \
  --name demo-small \
  --nodes-min 0 \
  --nodes-max 3 \
  --region us-east-1
```

**Si creaste el nodegroup manualmente (AWS Console o CloudFormation):**

```powershell
# Actualizar Auto Scaling Group directamente
aws autoscaling update-auto-scaling-group \
  --auto-scaling-group-name <ASG-NAME> \
  --min-size 0 \
  --max-size 3 \
  --region us-east-1
```

### 12.2.3. Cómo funciona el escalado a 0 nodos

**Flujo automático:**

1. **22:00** → KEDA Cron escala todos los pods a 0 réplicas
2. **Nodos quedan vacíos** (solo pods del sistema como `kube-system`)
3. **Cluster Autoscaler detecta** nodos subutilizados
4. **CA espera** el delay configurado (por defecto 10 minutos)
5. **CA escala el nodegroup a 0** → Nodos EC2 se eliminan
6. **Ahorro**: No pagas por instancias EC2 durante la noche

**Flujo de reactivación:**

1. **08:00** → KEDA Cron escala pods a 1 réplica
2. **Pods quedan en estado `Pending`** (no hay nodos)
3. **Cluster Autoscaler detecta** pods pendientes
4. **CA escala el nodegroup a 1** → AWS crea nuevo nodo EC2 (2-3 minutos)
5. **Pods se programan** en el nuevo nodo

### 12.2.4. Configurar Cluster Autoscaler para escalado a 0

**Editar el Deployment del Cluster Autoscaler:**

```powershell
kubectl -n kube-system edit deployment cluster-autoscaler
```

**Agregar estos argumentos:**

```yaml
spec:
  template:
    spec:
      containers:
      - name: cluster-autoscaler
        args:
        - --balance-similar-node-groups
        - --skip-nodes-with-system-pods=false      # Permite eliminar nodos con pods del sistema
        - --skip-nodes-with-local-storage=false    # Permite eliminar nodos con storage local
        - --scale-down-delay-after-add=10m         # Esperar 10 min después de agregar nodo
        - --scale-down-unneeded-time=10m           # Esperar 10 min antes de eliminar nodo no usado
        - --scale-down-utilization-threshold=0.5   # Eliminar nodo si uso < 50%
        - --max-node-provision-time=15m            # Tiempo máximo para crear nodo
```

**⚠️ NOTA**: `--skip-nodes-with-system-pods=false` permite eliminar nodos incluso si tienen pods del sistema. Úsalo con cuidado en producción.

### 12.2.5. Verificar escalado de nodos

```powershell
# Ver nodos actuales
kubectl get nodes

# Ver estado del nodegroup
eksctl get nodegroup --cluster jobberapp-demo --region us-east-1

# Ver logs del Cluster Autoscaler
kubectl -n kube-system logs -f deployment/cluster-autoscaler

# Monitorear en tiempo real
kubectl get nodes -w
```

**Logs esperados cuando escala a 0:**
```
I0920 22:10:00.123456       1 cluster_autoscaler.go:1234] Scale down: removing node i-0123456789abcdef0
I0920 22:10:05.654321       1 cluster_autoscaler.go:1235] Node i-0123456789abcdef0 removed
```

**Logs esperados cuando escala de 0 a 1:**
```
I0920 08:00:00.123456       1 cluster_autoscaler.go:1234] Scale up: 1 node(s) needed
I0920 08:00:05.654321       1 cluster_autoscaler.go:1235] Node i-0987654321fedcba0 created
```

### 12.2.6. Consideraciones importantes

**⚠️ Limitaciones:**

1. **Pods del sistema**: Si tienes pods críticos en `kube-system` (como `cluster-autoscaler` mismo), el CA puede no escalar a 0 completamente
2. **DaemonSets**: Los DaemonSets (como `kube-proxy`, `aws-node`) siempre corren en cada nodo
3. **Tiempo de arranque**: Cuando se reactiva, toma 2-3 minutos crear el nodo y programar los pods

**✅ Soluciones:**

1. **Usar `--skip-nodes-with-system-pods=false`** (con cuidado)
2. **Mover pods críticos a nodos dedicados** (no escalables)
3. **Aceptar que siempre habrá 1 nodo mínimo** si tienes DaemonSets críticos

### 12.2.7. Estrategia recomendada para portfolio

**Para un proyecto de portfolio, recomendamos:**

1. **Pods a 0**: ✅ Usar KEDA Cron para apagar todos los pods de aplicación
2. **Nodos a 1**: ⚠️ Mantener mínimo 1 nodo (más seguro y simple)
3. **Razón**: El nodo mínimo cuesta ~$30/mes, pero evita problemas de arranque y mantiene el clúster disponible

**Si quieres ahorrar más:**
- Configura `nodes-min: 0` y acepta el delay de 2-3 minutos al reactivar
- Útil si tu aplicación no necesita estar disponible 24/7

### 12.2.8. Ejemplo completo: Pods + Nodos a 0

**Configuración combinada:**

1. **KEDA Cron** escala pods a 0 a las 22:00
2. **Cluster Autoscaler** detecta nodos vacíos
3. **CA escala nodegroup a 0** después de 10 minutos
4. **Ahorro total**: $0 en EC2 durante la noche

**A las 08:00:**
1. **KEDA Cron** escala pods a 1
2. **Pods quedan `Pending`**
3. **CA detecta** y crea nodo (2-3 min)
4. **Pods se programan**

**Comando para verificar todo el flujo:**

```powershell
# Terminal 1: Monitorear pods
kubectl get pods -n production -w

# Terminal 2: Monitorear nodos
kubectl get nodes -w

# Terminal 3: Logs del Cluster Autoscaler
kubectl -n kube-system logs -f deployment/cluster-autoscaler

# Terminal 4: Logs de KEDA
kubectl -n keda-system logs -f deployment/keda-operator
```

---

## 13. Referencias

### KEDA:
- [KEDA Cron Scaler Documentation](https://keda.sh/docs/scalers/cron/) ⭐
- [KEDA CPU Scaler Documentation](https://keda.sh/docs/scalers/cpu/)
- [KEDA Multiple Triggers](https://keda.sh/docs/concepts/scaling-deployments/#multiple-triggers)
- [KEDA Installation](https://keda.sh/docs/deploy/)

### Cluster Autoscaler:
- [Cluster Autoscaler AWS](https://github.com/kubernetes/autoscaler/tree/master/cluster-autoscaler/cloudprovider/aws)
- [EKS Best Practices - Autoscaling](https://aws.github.io/aws-eks-best-practices/cluster-autoscaling/)
- [Cluster Autoscaler - Scale Down](https://github.com/kubernetes/autoscaler/blob/master/cluster-autoscaler/FAQ.md#how-does-scale-down-work)

### Otros:
- [Cron Expression Format](https://en.wikipedia.org/wiki/Cron)
- [Lista de zonas horarias](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones)

---

## 14. Checklist para producción/demo

### Configuración básica de KEDA Cron:
- [ ] KEDA instalado en el clúster
- [ ] HPA eliminado del deployment (si existía)
- [ ] ScaledObject con Cron creado y aplicado
- [ ] Horarios configurados correctamente (verificar zona horaria)
- [ ] Probado en Minikube antes de aplicar en producción
- [ ] Verificado escalado a 0 en horario inactivo
- [ ] Verificado escalado a 1 en horario activo
- [ ] Documentado comportamiento en README
- [ ] Capturas de pantalla guardadas

### Configuración avanzada (KEDA con múltiples triggers):
- [ ] HPA eliminado y reemplazado por KEDA (Cron + CPU)
- [ ] ScaledObject con múltiples triggers configurado
- [ ] Umbral de CPU ajustado según necesidades
- [ ] Verificado escalado por CPU durante horario activo
- [ ] Verificado que Cron tiene prioridad sobre CPU en horario inactivo

### Escalado de nodos a 0 (opcional):
- [ ] Cluster Autoscaler instalado y configurado
- [ ] Nodegroup configurado con `nodes-min: 0` (si se desea escalar a 0)
- [ ] Cluster Autoscaler configurado con `--skip-nodes-with-system-pods=false` (opcional)
- [ ] Verificado escalado de nodos a 0 cuando todos los pods están en 0
- [ ] Verificado reactivación de nodos cuando pods vuelven a 1
- [ ] Documentado tiempo de arranque esperado (2-3 minutos)

---

## 15. Próximos pasos

### Fase 1: Configuración básica
1. ✅ Probar en Minikube primero (ver `../../minikube/autoscaling/keda/cron/README-CRON.md`)
2. ✅ Documentar comportamiento observado
3. ✅ Guardar capturas de pantalla
4. ✅ Ajustar horarios según necesidades reales
5. ✅ Aplicar en EKS con la misma configuración
6. ✅ Monitorear en producción durante los primeros días

### Fase 2: Optimización (opcional)
7. ✅ Reemplazar HPA manual con KEDA (Cron + CPU) - Sección 12.1
8. ✅ Ajustar umbrales de CPU según métricas reales
9. ✅ Verificar que el escalado por CPU funciona correctamente durante horario activo

### Fase 3: Ahorro máximo (opcional, solo si es necesario)
10. ✅ Configurar Cluster Autoscaler para escalar nodos a 0 - Sección 12.2
11. ✅ Actualizar nodegroup con `nodes-min: 0`
12. ✅ Verificar que los nodos se escalan a 0 cuando todos los pods están en 0
13. ✅ Documentar tiempo de reactivación (2-3 minutos)
14. ✅ Aceptar que habrá un delay al reactivar la aplicación

