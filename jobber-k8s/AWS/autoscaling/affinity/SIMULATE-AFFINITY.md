# Guía para Simular Pod Affinity/Anti-Affinity en Minikube

Esta guía te ayudará a simular y documentar el comportamiento de Pod Affinity y Anti-Affinity en Minikube para entender cómo funcionaría en producción (EKS).

## ⚠️ Requisito: Múltiples Nodos

**Para ver el efecto real de affinity, necesitas al menos 2 nodos en Minikube.**

Con 1 nodo, todas las réplicas se programarán en el mismo nodo, sin importar las reglas de affinity.

---

## Paso 1: Iniciar Minikube con múltiples nodos

Si ya tienes Minikube corriendo con 1 nodo, necesitas reiniciarlo con 2 nodos:

```bash
# Detener Minikube actual
minikube stop

# Iniciar Minikube con 2 nodos
minikube start --nodes=2

# Verificar que tienes 2 nodos
kubectl get nodes
```

**Resultado esperado:**
```
NAME           STATUS   ROLES           AGE   VERSION
minikube       Ready    control-plane   1m    v1.34.0
minikube-m02   Ready    <none>          1m    v1.34.0
```

---

## Paso 2: Verificar estado inicial (CAPTURA 1)

Antes de aplicar affinity, captura el estado inicial:

```bash
# Ver nodos
kubectl get nodes -o wide

# Ver pods actuales (si tienes deployments corriendo)
kubectl get pods -n production -o wide
```

**Captura**: `images/affinity-before.png`
- Muestra: 2 nodos, distribución actual de pods
- **Nota**: Si tienes 1 réplica de un servicio, estará en un solo nodo

---

## Paso 3: Crear deployment de prueba SIN affinity

Primero, crea un deployment sin reglas de affinity para ver el comportamiento por defecto:

```bash
# Crear deployment de prueba sin affinity
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: test-affinity-default
  namespace: production
spec:
  replicas: 2
  selector:
    matchLabels:
      app: test-affinity-default
  template:
    metadata:
      labels:
        app: test-affinity-default
    spec:
      containers:
      - name: test
        image: nginx:alpine
        resources:
          requests:
            cpu: 100m
            memory: 128Mi
EOF
```

Espera 30 segundos y verifica dónde se programaron los pods:

```bash
kubectl get pods -n production -l app=test-affinity-default -o wide
```

**Observación**: Los pods pueden estar en el mismo nodo o en nodos diferentes (aleatorio).

---

## Paso 4: Crear deployment CON anti-affinity (CAPTURA 2)

Ahora crea un deployment con reglas de anti-affinity para forzar distribución:

```bash
# Crear deployment con anti-affinity
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: test-affinity-distributed
  namespace: production
spec:
  replicas: 2
  selector:
    matchLabels:
      app: test-affinity-distributed
  template:
    metadata:
      labels:
        app: test-affinity-distributed
    spec:
      affinity:
        podAntiAffinity:
          preferredDuringSchedulingIgnoredDuringExecution:
          - weight: 100
            podAffinityTerm:
              labelSelector:
                matchExpressions:
                - key: app
                  operator: In
                  values:
                  - test-affinity-distributed
              topologyKey: kubernetes.io/hostname
      containers:
      - name: test
        image: nginx:alpine
        resources:
          requests:
            cpu: 100m
            memory: 128Mi
EOF
```

Espera 30 segundos y verifica la distribución:

```bash
kubectl get pods -n production -l app=test-affinity-distributed -o wide
```

**Captura**: `images/affinity-distributed.png`
- Muestra: 2 pods del mismo deployment en nodos diferentes
- **Resultado esperado**: Cada pod en un nodo diferente

---

## Paso 5: Verificar reglas de affinity en los pods (CAPTURA 3)

Inspecciona un pod para ver las reglas de affinity aplicadas:

```bash
# Obtener nombre de un pod
POD_NAME=$(kubectl get pods -n production -l app=test-affinity-distributed -o jsonpath='{.items[0].metadata.name}')

# Describir el pod
kubectl describe pod $POD_NAME -n production
```

**Busca en la salida:**
```
Affinity:
  Pod Anti Affinity:
    Preferred:
      Weight:           100
      Pod Affinity Term:
        Label Selector:
          Match Expressions:
            Key:      app
            Operator: In
            Values:
              test-affinity-distributed
        Topology Key:  kubernetes.io/hostname
```

**Captura**: `images/affinity-describe.png`
- Muestra: Las reglas de affinity en el pod

---

## Paso 6: Ver distribución con JSONPath (CAPTURA 4)

Ver la distribución de forma más clara:

```bash
# Ver distribución de pods por nodo
kubectl get pods -n production -l app=test-affinity-distributed -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.spec.nodeName}{"\n"}{end}' | sort
```

**Captura**: `images/affinity-jsonpath.png`
- Muestra: Lista de pods y en qué nodo están

---

## Paso 7: Probar con más réplicas (OPCIONAL)

Para ver mejor el efecto, escala a más réplicas:

```bash
# Escalar a 4 réplicas
kubectl scale deployment test-affinity-distributed --replicas=4 -n production

# Esperar 30 segundos
sleep 30

# Ver distribución
kubectl get pods -n production -l app=test-affinity-distributed -o wide
```

**Resultado esperado**: Con 2 nodos y 4 réplicas, deberías ver 2 pods por nodo (distribución uniforme).

---

## Paso 8: Comparar con deployment SIN affinity

Compara la distribución:

```bash
# Deployment SIN affinity (aleatorio)
kubectl get pods -n production -l app=test-affinity-default -o wide

# Deployment CON affinity (distribuido)
kubectl get pods -n production -l app=test-affinity-distributed -o wide
```

**Diferencia**: 
- **Sin affinity**: Pods pueden estar todos en el mismo nodo
- **Con affinity**: Pods se distribuyen entre nodos

---

## Paso 9: Aplicar a un servicio real (Gateway)

Para probar con un servicio real, edita el deployment del gateway:

```bash
# Editar el deployment del gateway
kubectl edit deployment jobber-gateway -n production
```

Agrega la sección de affinity en `spec.template.spec`:

```yaml
spec:
  template:
    spec:
      affinity:
        podAntiAffinity:
          preferredDuringSchedulingIgnoredDuringExecution:
          - weight: 100
            podAffinityTerm:
              labelSelector:
                matchExpressions:
                - key: app
                  operator: In
                  values:
                  - jobber-gateway
              topologyKey: kubernetes.io/hostname
      containers:
      # ... resto de la configuración
```

O aplica desde un archivo YAML:

```bash
# Ver el deployment actual
kubectl get deployment jobber-gateway -n production -o yaml > gateway-with-affinity.yaml

# Editar el archivo para agregar affinity (ver ejemplo abajo)
# Aplicar
kubectl apply -f gateway-with-affinity.yaml
```

**Ejemplo de sección affinity para gateway:**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: jobber-gateway
  namespace: production
spec:
  replicas: 2  # Asegúrate de tener al menos 2 réplicas
  template:
    spec:
      affinity:
        podAntiAffinity:
          preferredDuringSchedulingIgnoredDuringExecution:
          - weight: 100
            podAffinityTerm:
              labelSelector:
                matchExpressions:
                - key: app
                  operator: In
                  values:
                  - jobber-gateway
              topologyKey: kubernetes.io/hostname
```

Luego verifica la distribución:

```bash
kubectl get pods -n production -l app=jobber-gateway -o wide
```

---

## Limpiar después de las pruebas

```bash
# Eliminar deployments de prueba
kubectl delete deployment test-affinity-default -n production
kubectl delete deployment test-affinity-distributed -n production

# Si aplicaste affinity al gateway y quieres revertirlo
kubectl rollout undo deployment/jobber-gateway -n production
```

---

## Checklist de capturas

- [ ] `affinity-before.png` - Estado inicial (2 nodos, pods sin affinity)
- [ ] `affinity-distributed.png` - Pods distribuidos con anti-affinity (cada pod en nodo diferente)
- [ ] `affinity-describe.png` - `kubectl describe pod` mostrando reglas de affinity
- [ ] `affinity-jsonpath.png` - Distribución con JSONPath
- [ ] `affinity-comparison.png` - (Opcional) Comparación entre con y sin affinity

---

## Troubleshooting

### Los pods están en el mismo nodo a pesar de affinity

**Causa**: Solo tienes 1 nodo o la regla es "preferred" (soft).

**Solución**:
1. Verifica que tienes 2 nodos: `kubectl get nodes`
2. Si solo tienes 1 nodo: `minikube start --nodes=2`
3. Usa "required" en lugar de "preferred" (pero esto puede dejar pods en Pending si no hay nodos disponibles)

### Pods quedan en Pending con anti-affinity "required"

**Causa**: No hay suficientes nodos para distribuir los pods.

**Solución**: 
- Usa "preferred" en lugar de "required"
- O aumenta el número de nodos: `minikube start --nodes=3`

### No veo diferencia entre con y sin affinity

**Causa**: Kubernetes puede distribuir pods aleatoriamente sin affinity.

**Solución**: 
- Aumenta el número de réplicas (ej: 4 réplicas con 2 nodos)
- Usa anti-affinity "required" para forzar distribución

---

## Resumen: Minikube vs EKS

| Aspecto | Minikube | EKS |
|---------|----------|-----|
| Affinity funciona | ✅ Sí | ✅ Sí |
| Necesita múltiples nodos | ✅ Sí (2+) | ✅ Sí (2+) |
| Anti-affinity distribuye pods | ✅ Sí | ✅ Sí |
| Topology spread constraints | ✅ Sí | ✅ Sí |
| Diferencia principal | Nodos locales | Nodos en diferentes zonas (AZ) |

**Conclusión**: Affinity funciona igual en Minikube y EKS. La diferencia es que en EKS puedes distribuir pods entre zonas de disponibilidad (AZ), no solo entre nodos.

---

## Próximos pasos

1. ✅ Captura las imágenes según el checklist
2. ✅ Documenta el proceso en tu README
3. ✅ Explica cómo funciona en producción (EKS)
4. 💡 (Opcional) Aplica affinity a servicios críticos (gateway, auth)

