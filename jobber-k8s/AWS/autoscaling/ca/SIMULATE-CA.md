# Guía para Simular Cluster Autoscaler en Minikube

Esta guía te ayudará a simular el comportamiento del Cluster Autoscaler (CA) en Minikube para documentar el proceso con capturas de pantalla y entender cómo funcionaría en producción (EKS).

## ⚠️ Limitación de Minikube

**El CA real NO funciona en Minikube** porque Minikube no puede crear nodos automáticamente. Sin embargo, puedes:
- ✅ Simular pods pendientes cuando el nodo se satura
- ✅ Mostrar la necesidad de más nodos
- ✅ Explicar cómo funcionaría el CA en EKS
- ✅ Documentar el proceso para tu portafolio

**En producción (EKS/GKE/AKS)**, el CA detectaría estos pods pendientes y crearía un nuevo nodo automáticamente.

---

## Paso 1: Verificar estado inicial

Antes de comenzar, captura el estado inicial del clúster:

```bash
# Ver nodos actuales (debería ser 1)
kubectl get nodes -o wide

# Ver pods actuales
kubectl get pods -n production -o wide

# Ver capacidad del nodo
kubectl top nodes
```

**Captura**: `images/ca-initial-state.png`
- Muestra: 1 nodo, pods actuales, recursos disponibles
- **Nota**: En Minikube verás 1 nodo. En EKS, el CA podría crear más.

---

## Paso 2: Verificar capacidad disponible en el nodo

Necesitas saber cuántos recursos tiene tu nodo para saturarlo:

```bash
# Ver recursos del nodo
kubectl describe node minikube

# Ver pods y sus requests actuales
kubectl get pods -n production -o custom-columns=NAME:.metadata.name,CPU-REQUEST:.spec.containers[*].resources.requests.cpu,MEMORY-REQUEST:.spec.containers[*].resources.requests.memory
```

**Anota**: 
- CPU total disponible (ej: 2000m = 2 CPU)
- Memory total disponible (ej: 2Gi)
- CPU/Memory ya usada por pods existentes

**Ejemplo típico de Minikube:**
- CPU: ~2000m (2 vCPU)
- Memory: ~2-4Gi

---

## Paso 3: Ajustar el deployment de prueba

Edita `test-autoscaling.yaml` para que sature tu nodo. Ajusta según la capacidad disponible:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: test-autoscaling
  namespace: production
spec:
  replicas: 5  # Ajusta según tu nodo
  selector:
    matchLabels:
      app: test-autoscaling
  template:
    metadata:
      labels:
        app: test-autoscaling
    spec:
      containers:
      - name: test
        image: nginx:alpine
        resources:
          requests:
            cpu: 500m      # Ajusta: si tu nodo tiene 2 CPU, 5 pods x 500m = 2.5 CPU (saturará)
            memory: 512Mi
          limits:
            cpu: 1000m
            memory: 1Gi
```

**Recomendaciones:**
- Si tu nodo tiene **2 CPU**: usa `cpu: 500m` y `replicas: 5` (5 x 0.5 = 2.5 CPU, saturará)
- Si tu nodo tiene **4 CPU**: usa `cpu: 1000m` y `replicas: 5` (5 x 1 = 5 CPU, saturará)
- O aumenta `replicas` a 10-15 con `cpu: 500m`

---

## Paso 4: Aplicar deployment y observar pods pendientes (CAPTURA CLAVE)

Aplica el deployment que saturará el nodo:

```bash
# Aplicar el deployment de prueba
kubectl apply -f jobber-k8s/minikube/autoscaling/ca/test-autoscaling.yaml

# Observar pods en tiempo real (abre en una terminal)
kubectl get pods -n production -w
```

**Espera 30-60 segundos** y observa:

1. **Algunos pods se programan** (estado `Running`)
2. **Otros quedan en estado `Pending`** (no hay recursos)

```bash
# Ver pods pendientes
kubectl get pods -n production | grep Pending

# Ver todos los pods del deployment de prueba
kubectl get pods -n production -l app=test-autoscaling
```

**Captura**: `images/ca-pending-pods.png`
- Muestra: Pods en estado `Pending`
- Ejemplo: `test-autoscaling-xxxxx   0/1   Pending   0   30s`

---

## Paso 5: Ver por qué están pendientes (CAPTURA CLAVE)

Inspecciona un pod pendiente para ver el motivo:

```bash
# Obtener nombre de un pod pendiente
POD_NAME=$(kubectl get pods -n production -l app=test-autoscaling -o jsonpath='{.items[?(@.status.phase=="Pending")].metadata.name}' | head -1)

# Describir el pod pendiente
kubectl describe pod $POD_NAME -n production
```

**Busca en la salida:**
```
Events:
  Type     Reason            Message
  ----     ------            -------
  Warning  FailedScheduling  0/1 nodes are available: 1 Insufficient cpu.
```

O:
```
Conditions:
  Type           Status
  PodScheduled   False
  ...
  Message:       0/1 nodes are available: 1 Insufficient cpu.
```

**Captura**: `images/ca-pending-reason.png`
- Muestra: El mensaje "Insufficient cpu" o "Insufficient memory"
- **Explicación**: Esto es lo que el CA detectaría en EKS para crear un nuevo nodo

---

## Paso 6: Ver distribución actual (OPCIONAL - si tienes múltiples nodos)

Si iniciaste Minikube con múltiples nodos pre-configurados:

```bash
# Iniciar Minikube con 2 nodos (si aún no lo hiciste)
minikube start --nodes=2

# Ver nodos
kubectl get nodes

# Ver pods distribuidos
kubectl get pods -n production -o wide

# Ver distribución específica
kubectl get pods -n production -o custom-columns=NAME:.metadata.name,NODE:.spec.nodeName,STATUS:.status.phase
```

**Captura**: `images/ca-pods-distributed.png`
- Muestra: Pods distribuidos entre nodos
- **Nota**: En Minikube los nodos ya existen. En EKS, el CA los crearía automáticamente.

---

## Paso 7: Explicar cómo funcionaría el CA en EKS

Para documentar en tu portafolio, explica:

### Lo que viste en Minikube:
1. ✅ Pods quedan en estado `Pending` cuando el nodo se satura
2. ✅ Mensaje "Insufficient cpu/memory" indica necesidad de más recursos
3. ✅ Kubernetes no puede programar más pods en el nodo actual

### Lo que haría el CA en EKS:
1. 🔍 **Detectaría** los pods pendientes automáticamente
2. 📊 **Analizaría** que no hay recursos suficientes en los nodos existentes
3. 🚀 **Crearía** un nuevo nodo EC2 en AWS (2-5 minutos)
4. ✅ **Programaría** los pods pendientes en el nuevo nodo
5. 📉 **Escalaría hacia abajo** cuando la carga disminuya (después de 10-15 minutos)

---

## Script rápido para monitoreo

Crea un script `monitor-ca-minikube.sh`:

```bash
#!/bin/bash

echo "=== Estado inicial ==="
kubectl get nodes
echo ""
kubectl get pods -n production -o wide | head -10

echo -e "\n=== Aplicando deployment de prueba ==="
kubectl apply -f jobber-k8s/minikube/autoscaling/ca/test-autoscaling.yaml

echo -e "\n=== Esperando 30 segundos... ==="
sleep 30

echo -e "\n=== Pods del deployment de prueba ==="
kubectl get pods -n production -l app=test-autoscaling

echo -e "\n=== Pods pendientes ==="
kubectl get pods -n production | grep Pending

echo -e "\n=== Razón de pods pendientes (primer pod) ==="
POD_NAME=$(kubectl get pods -n production -l app=test-autoscaling -o jsonpath='{.items[?(@.status.phase=="Pending")].metadata.name}' | head -1)
if [ ! -z "$POD_NAME" ]; then
  kubectl describe pod $POD_NAME -n production | grep -A 5 "Events:"
fi
```

Ejecuta:
```bash
chmod +x monitor-ca-minikube.sh
./monitor-ca-minikube.sh
```

---

## Ajustar recursos según tu nodo

### Si los pods NO quedan pendientes:

**Problema**: El nodo tiene suficiente capacidad.

**Solución**: Aumenta los recursos solicitados:

```yaml
resources:
  requests:
    cpu: 1000m      # Aumenta a 1 CPU por pod
    memory: 1Gi    # Aumenta memoria
```

O aumenta el número de réplicas:

```yaml
replicas: 10  # En lugar de 5
```

### Si TODOS los pods quedan pendientes:

**Problema**: Los recursos solicitados son demasiado altos.

**Solución**: Reduce los recursos:

```yaml
resources:
  requests:
    cpu: 200m       # Reduce a 0.2 CPU por pod
    memory: 256Mi   # Reduce memoria
```

---

## Checklist de capturas para Minikube

- [ ] `ca-initial-state.png` - Estado inicial (1 nodo, pods actuales, recursos)
- [ ] `ca-pending-pods.png` - Pods en estado `Pending` después de aplicar el deployment
- [ ] `ca-pending-reason.png` - `kubectl describe pod` mostrando "Insufficient cpu/memory"
- [ ] `ca-pods-distributed.png` - (Opcional) Pods distribuidos si usas `minikube start --nodes=2`

---

## Documentación para portafolio

### Lo que puedes documentar:

1. **Problema identificado**: 
   - "Pods quedan en estado Pending cuando el nodo se satura"
   - Captura: `ca-pending-pods.png`

2. **Causa raíz**:
   - "Kubernetes no puede programar más pods por falta de recursos (CPU/Memory)"
   - Captura: `ca-pending-reason.png`

3. **Solución implementada**:
   - "Cluster Autoscaler configurado para detectar pods pendientes"
   - "En EKS, el CA crearía automáticamente un nuevo nodo EC2"
   - "El nuevo nodo permitiría programar los pods pendientes"

4. **Comportamiento esperado en producción (EKS)**:
   - El CA monitorea pods pendientes
   - Detecta necesidad de más capacidad
   - Solicita nuevo nodo a AWS (2-5 minutos)
   - Los pods se programan automáticamente en el nuevo nodo
   - El CA escala hacia abajo cuando la carga disminuye

---

## Limpiar después de las pruebas

```bash
# Eliminar el deployment de prueba
kubectl delete deployment test-autoscaling -n production

# Verificar que los pods se eliminaron
kubectl get pods -n production -l app=test-autoscaling
```

---

## Resumen: Minikube vs EKS

| Aspecto | Minikube (Simulación) | EKS (Producción) |
|---------|----------------------|------------------|
| Pods pendientes | ✅ Sí, se pueden ver | ✅ Sí |
| Mensaje "Insufficient cpu" | ✅ Sí, visible | ✅ Sí |
| CA detecta necesidad | ❌ No funciona | ✅ Sí, automático |
| CA crea nuevo nodo | ❌ No puede | ✅ Sí, en 2-5 min |
| Escalado automático | ❌ No | ✅ Sí |
| Ideal para demo | ⚠️ Limitado (solo problema) | ✅ Completo |

**Conclusión**: En Minikube puedes simular y documentar el **problema** (pods pendientes). En EKS, el CA **resuelve** el problema automáticamente creando nodos.

---

## Próximos pasos

1. ✅ Captura las imágenes según el checklist
2. ✅ Documenta el proceso en tu README
3. ✅ Explica cómo funcionaría en EKS
4. 💡 (Opcional) Si tienes acceso a EKS, captura el CA funcionando realmente
