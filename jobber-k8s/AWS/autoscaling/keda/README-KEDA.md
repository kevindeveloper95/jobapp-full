## Guía de KEDA (Kubernetes Event-Driven Autoscaling)

Esta guía documenta la instalación y configuración de KEDA para escalar pods basándose en métricas externas (RabbitMQ, Kafka, etc.) en lugar de solo CPU/memoria.

---

### 1. ¿Qué es KEDA?

**KEDA** (Kubernetes Event-Driven Autoscaling) escala pods basándose en eventos externos:
- **RabbitMQ**: número de mensajes en cola
- **Kafka**: lag de consumidores
- **Redis**: longitud de listas
- **Prometheus**: métricas custom
- **HTTP**: requests por segundo

**Ventaja sobre HPA**: Puedes escalar a 0 cuando no hay trabajo (ahorra recursos).

---

### 2. Prerrequisitos

- Clúster Kubernetes funcionando (Minikube o EKS)
- RabbitMQ desplegado y funcionando
- `kubectl` configurado
- Helm instalado (para instalar KEDA)

---

### 3. Instalar KEDA

#### 3.1. Verificar que Helm está instalado

```powershell
# Verificar Helm
helm version

# Si no está instalado, ver: INSTALL-HELM.md
```

#### 3.2. Agregar repositorio de Helm

```powershell
helm repo add kedacore https://kedacore.github.io/charts
helm repo update
```

#### 3.3. Instalar KEDA

```powershell
helm install keda kedacore/keda `
  --namespace keda-system `
  --create-namespace
```

> **Nota**: Si Helm no está instalado, ver `INSTALL-HELM.md` para instrucciones de instalación en Windows.

#### 3.4. Verificar instalación

```powershell
# Ver pods de KEDA
kubectl get pods -n keda-system

# Verificar que está funcionando
kubectl get deployment keda-operator -n keda-system
kubectl get deployment keda-metrics-apiserver -n keda-system
```

**Resultado esperado**: Ambos deployments en estado `Running`.

---

### 4. Configurar KEDA para RabbitMQ (Notification Service)

#### 4.1. Obtener información de RabbitMQ

Necesitas:
- **Host**: `jobber-queue.production.svc.cluster.local` (service de RabbitMQ)
- **Puerto**: `5672` (puerto AMQP)
- **Usuario y contraseña**: Del secret `jobber-backend-secret`
- **Cola**: `auth-email-queue` o `order-email-queue`

#### 4.2. Crear Secret para credenciales de RabbitMQ

```powershell
# Obtener credenciales del secret existente
kubectl get secret jobber-backend-secret -n production -o jsonpath='{.data.jobber-rabbitmq-user}' | ForEach-Object { [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($_)) }
kubectl get secret jobber-backend-secret -n production -o jsonpath='{.data.jobber-rabbitmq-password}' | ForEach-Object { [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($_)) }
```

#### 4.3. Crear ScaledObject para Notification Service

Crea el archivo `jobber-k8s/AWS/autoscaling/keda/notification-scaledobject.yaml`:

```yaml
apiVersion: keda.sh/v1alpha1
kind: ScaledObject
metadata:
  name: jobber-notification-scaledobject
  namespace: production
spec:
  scaleTargetRef:
    name: jobber-notification
    kind: Deployment
  minReplicaCount: 0      # Puede escalar a 0 cuando no hay mensajes
  maxReplicaCount: 5     # Máximo 5 réplicas
  triggers:
  - type: rabbitmq
    metadata:
      queueName: auth-email-queue
      host: amqp://jobber-queue.production.svc.cluster.local:5672
      queueLength: '5'   # Si hay 5+ mensajes, escala
    authenticationRef:
      name: rabbitmq-trigger-auth
---
apiVersion: keda.sh/v1alpha1
kind: TriggerAuthentication
metadata:
  name: rabbitmq-trigger-auth
  namespace: production
spec:
  secretTargetRef:
  - parameter: username
    name: jobber-backend-secret
    key: jobber-rabbitmq-user
  - parameter: password
    name: jobber-backend-secret
    key: jobber-rabbitmq-password
```

#### 4.4. Aplicar ScaledObject

```powershell
kubectl apply -f jobber-k8s/AWS/autoscaling/keda/notification-scaledobject.yaml
```

#### 4.5. Verificar que funciona

```powershell
# Ver ScaledObject
kubectl get scaledobject -n production

# Ver detalles
kubectl describe scaledobject jobber-notification-scaledobject -n production

# Ver réplicas del deployment
kubectl get deployment jobber-notification -n production -w
```

---

### 5. Probar escalado automático (RabbitMQ)

#### 5.1. Estado inicial (0 réplicas)

```powershell
# Ver deployment (debería estar en 0 réplicas si no hay mensajes)
kubectl get deployment jobber-notification -n production

# Ver pods
kubectl get pods -n production -l app=jobber-notification
```

**Resultado esperado**: 0 réplicas (escalado a 0 porque no hay mensajes).

#### 5.2. Enviar mensajes a la cola

Puedes usar la UI de RabbitMQ o crear un script de prueba. Cuando lleguen mensajes:

```powershell
# Monitorear réplicas en tiempo real
kubectl get deployment jobber-notification -n production -w

# Ver pods siendo creados
kubectl get pods -n production -l app=jobber-notification -w
```

**Resultado esperado**: 
- Mensajes llegan → réplicas aumentan
- Mensajes se procesan → réplicas disminuyen
- Sin mensajes → escala a 0

---

### 6. Configuración avanzada

#### 6.1. Múltiples colas (auth-email y order-email)

```yaml
apiVersion: keda.sh/v1alpha1
kind: ScaledObject
metadata:
  name: jobber-notification-scaledobject
  namespace: production
spec:
  scaleTargetRef:
    name: jobber-notification
    kind: Deployment
  minReplicaCount: 0
  maxReplicaCount: 5
  triggers:
  - type: rabbitmq
    metadata:
      queueName: auth-email-queue
      host: amqp://jobber-queue.production.svc.cluster.local:5672
      queueLength: '5'
    authenticationRef:
      name: rabbitmq-trigger-auth
  - type: rabbitmq
    metadata:
      queueName: order-email-queue
      host: amqp://jobber-queue.production.svc.cluster.local:5672
      queueLength: '5'
    authenticationRef:
      name: rabbitmq-trigger-auth
```

#### 6.2. Ajustar sensibilidad de escalado

```yaml
triggers:
- type: rabbitmq
  metadata:
    queueName: auth-email-queue
    host: amqp://jobber-queue.production.svc.cluster.local:5672
    queueLength: '10'        # Escala cuando hay 10+ mensajes
    activationQueueLength: '5'  # Activa cuando hay 5+ mensajes
```

---

### 7. Capturas de pantalla para documentación

Guarda las capturas en `jobber-k8s/AWS/autoscaling/keda/images/`:

1. **Estado inicial (0 réplicas)** → `keda-scaled-to-zero.png`
   ```powershell
   kubectl get deployment jobber-notification -n production
   kubectl get pods -n production -l app=jobber-notification
   ```

2. **ScaledObject configurado** → `keda-scaledobject.png`
   ```powershell
   kubectl get scaledobject -n production
   kubectl describe scaledobject jobber-notification-scaledobject -n production
   ```

3. **Escalado activo (réplicas aumentando)** → `keda-scaling-up.png`
   ```powershell
   kubectl get deployment jobber-notification -n production -w
   ```

4. **Mensajes en cola (RabbitMQ UI)** → `keda-queue-messages.png`
   - Acceder a RabbitMQ Management UI
   - Ver cola `auth-email-queue` con mensajes

5. **Escalado hacia abajo (volviendo a 0)** → `keda-scaling-down.png`
   ```powershell
   kubectl get deployment jobber-notification -n production
   ```

---

### 8. Troubleshooting

| Síntoma | Diagnóstico | Acción |
| --- | --- | --- |
| ScaledObject no escala | RabbitMQ no accesible o credenciales incorrectas | Verificar conectividad: `kubectl exec -it <pod> -- ping jobber-queue.production.svc.cluster.local` |
| Pods no se crean | `minReplicaCount: 0` y no hay mensajes | Normal, escala a 0. Enviar mensajes para activar |
| Escala demasiado rápido | `queueLength` muy bajo | Aumentar `queueLength` en metadata |
| No escala hacia abajo | Mensajes se procesan muy rápido | Ajustar `cooldownPeriod` en ScaledObject |

---

### 9. KEDA vs HPA: ¿Se complementan o se excluyen?

#### 9.1. ¿Cómo funciona KEDA internamente?

**KEDA crea un HPA automáticamente** cuando creas un ScaledObject. KEDA no reemplaza HPA, sino que lo extiende con métricas externas.

**Flujo:**
1. Creas un `ScaledObject` en KEDA
2. KEDA crea automáticamente un `HPA` interno
3. Ese HPA usa métricas de KEDA (RabbitMQ, Kafka, etc.)
4. El HPA escala el deployment

#### 9.2. ¿Puedo usar HPA y KEDA juntos?

**⚠️ NO uses HPA manual y KEDA en el mismo deployment**

**Problema**: Si tienes un HPA manual y un ScaledObject de KEDA apuntando al mismo deployment, entrarán en conflicto y competirán por controlar las réplicas.

**Ejemplo de conflicto:**
```yaml
# ❌ NO HACER: HPA manual
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: jobber-notification-hpa  # ← Conflicto
spec:
  scaleTargetRef:
    name: jobber-notification

# ❌ NO HACER: KEDA ScaledObject al mismo tiempo
apiVersion: keda.sh/v1alpha1
kind: ScaledObject
metadata:
  name: jobber-notification-scaledobject  # ← Conflicto
spec:
  scaleTargetRef:
    name: jobber-notification  # ← Mismo deployment
```

**Resultado**: Ambos intentarán controlar las réplicas, causando comportamiento impredecible.

#### 9.3. Estrategias correctas

**Opción 1: KEDA para eventos, HPA para HTTP (recomendado)**

Usa cada uno en servicios diferentes:

```yaml
# Notification service (procesa colas) → KEDA
ScaledObject:
  scaleTargetRef:
    name: jobber-notification  # Escala por mensajes en RabbitMQ

# Gateway service (procesa HTTP) → HPA
HorizontalPodAutoscaler:
  scaleTargetRef:
    name: jobber-gateway  # Escala por CPU/memoria
```

**Opción 2: KEDA con múltiples triggers (incluyendo CPU)**

KEDA puede escalar basado en múltiples métricas, incluyendo CPU:

```yaml
apiVersion: keda.sh/v1alpha1
kind: ScaledObject
metadata:
  name: jobber-notification-scaledobject
spec:
  scaleTargetRef:
    name: jobber-notification
  triggers:
  - type: rabbitmq          # Escala por mensajes
    metadata:
      queueName: auth-email-queue
      queueLength: '5'
  - type: cpu                # También escala por CPU (backup)
    metadata:
      type: Utilization
      value: '70'
```

**Opción 3: Solo KEDA (si quieres escalar a 0)**

Si quieres escalar a 0 cuando no hay trabajo, usa solo KEDA:

```yaml
# KEDA puede escalar a 0
minReplicaCount: 0

# HPA nativo NO puede escalar a 0 (mínimo 1)
minReplicas: 1
```

#### 9.4. Resumen: Cuándo usar cada uno

| Escenario | Usar | Razón |
|-----------|------|-------|
| Servicio procesa colas (RabbitMQ, Kafka) | **KEDA** | Escala por mensajes, puede escalar a 0 |
| Servicio procesa HTTP requests | **HPA** | Escala por CPU/memoria, más simple |
| Necesitas escalar a 0 | **KEDA** | HPA no puede escalar a 0 |
| Necesitas métricas custom | **KEDA** | Más flexible (Prometheus, HTTP, etc.) |
| Solo CPU/memoria, sin eventos | **HPA** | Más simple, nativo de Kubernetes |

#### 9.5. Para tu proyecto Jobber

**Recomendación:**

- **Gateway, Auth, Users, etc.** (HTTP services) → **HPA** (ya lo tienes)
- **Notification service** (procesa RabbitMQ) → **KEDA con RabbitMQ scaler** (nuevo)
- **Chat, Order** (también usan RabbitMQ) → Podrías usar KEDA si procesan colas

**No mezcles**: Si un servicio usa KEDA, no crees un HPA manual para el mismo deployment.

---

### 10. Referencias

- [KEDA Documentation](https://keda.sh/docs/)
- [KEDA RabbitMQ Scaler](https://keda.sh/docs/scalers/rabbitmq/)
- [KEDA Installation](https://keda.sh/docs/deploy/)

---

### 11. Checklist para producción/demo

- [ ] KEDA instalado en el clúster
- [ ] ScaledObject creado para notification-service (RabbitMQ)
- [ ] Credenciales de RabbitMQ configuradas correctamente
- [ ] Probado escalado a 0 (sin mensajes)
- [ ] Probado escalado con mensajes
- [ ] Documentado comportamiento en README
- [ ] Capturas de pantalla guardadas

---

**Nota**: KEDA funciona perfectamente con 1 nodo. Escala réplicas de pods, no nodos.

