## Guía de Pod Disruption Budget (PDB)

Esta guía documenta la configuración de Pod Disruption Budget para proteger servicios críticos durante mantenimiento, actualizaciones y escalado del clúster.

---

### 1. ¿Qué es Pod Disruption Budget?

**Pod Disruption Budget (PDB)** define cuántas réplicas de un servicio pueden estar indisponibles durante:
- Actualizaciones de nodos
- Rolling updates de deployments
- Mantenimiento del clúster
- Escalado hacia abajo

**Beneficio**: Asegura que siempre haya un mínimo de réplicas disponibles, manteniendo el servicio funcionando.

---

### 2. Conceptos clave

#### 2.1. minAvailable
Mínimo número de pods que deben estar disponibles.

```yaml
minAvailable: 1  # Al menos 1 pod debe estar disponible
```

#### 2.2. maxUnavailable
Máximo número de pods que pueden estar indisponibles.

```yaml
maxUnavailable: 1  # Máximo 1 pod puede estar indisponible
```

**Nota**: Usa `minAvailable` O `maxUnavailable`, no ambos.

---

### 3. Cuándo usar PDB

**Servicios críticos que necesitan PDB:**
- Gateway (punto de entrada)
- Auth service (autenticación)
- Bases de datos (si tienen múltiples réplicas)

**Servicios que NO necesitan PDB:**
- Workers (notification, si usa KEDA)
- Servicios con 1 réplica (no hay redundancia que proteger)

---

### 4. Configurar PDB para Gateway

#### 4.1. Crear PDB para Gateway

Crea el archivo `jobber-k8s/AWS/autoscaling/pdb/gateway-pdb.yaml`:

```yaml
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: jobber-gateway-pdb
  namespace: production
spec:
  minAvailable: 1        # Al menos 1 pod debe estar disponible
  selector:
    matchLabels:
      app: jobber-gateway
```

#### 4.2. Aplicar PDB

```powershell
kubectl apply -f jobber-k8s/AWS/autoscaling/pdb/gateway-pdb.yaml
```

#### 4.3. Verificar

```powershell
# Ver PDB creado
kubectl get pdb -n production

# Ver detalles
kubectl describe pdb jobber-gateway-pdb -n production
```

---

### 5. Configurar PDB para Auth Service

```yaml
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: jobber-auth-pdb
  namespace: production
spec:
  minAvailable: 1
  selector:
    matchLabels:
      app: jobber-auth
```

Aplicar:
```powershell
kubectl apply -f jobber-k8s/AWS/autoscaling/pdb/auth-pdb.yaml
```

---

### 6. Ejemplos de configuración

#### 6.1. Con minAvailable (recomendado)

```yaml
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: jobber-gateway-pdb
  namespace: production
spec:
  minAvailable: 1        # Al menos 1 pod disponible
  selector:
    matchLabels:
      app: jobber-gateway
```

**Con 2 réplicas**: Puede detener 1, mantiene 1 funcionando.

#### 6.2. Con maxUnavailable

```yaml
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: jobber-gateway-pdb
  namespace: production
spec:
  maxUnavailable: 1      # Máximo 1 pod indisponible
  selector:
    matchLabels:
      app: jobber-gateway
```

**Con 3 réplicas**: Puede detener 1, mantiene 2 funcionando.

#### 6.3. Con porcentaje

```yaml
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: jobber-gateway-pdb
  namespace: production
spec:
  minAvailable: 50%      # Al menos 50% de pods disponibles
  selector:
    matchLabels:
      app: jobber-gateway
```

---

### 7. Probar PDB

#### 7.1. Intentar drenar un nodo (simular mantenimiento)

```powershell
# Ver pods del gateway
kubectl get pods -n production -l app=jobber-gateway -o wide

# Intentar evictar un pod manualmente
kubectl drain <node-name> --ignore-daemonsets --delete-emptydir-data
```

**Con PDB**: Kubernetes respetará el PDB y no evictará pods si violaría la regla.

#### 7.2. Hacer rolling update

```powershell
# Actualizar imagen del deployment
kubectl set image deployment/jobber-gateway jobber-gateway=kevin1208/jobber-gateway:new-version -n production

# Observar el proceso
kubectl get pods -n production -l app=jobber-gateway -w
```

**Con PDB**: Kubernetes mantendrá al menos 1 pod disponible durante la actualización.

---

### 8. Capturas de pantalla para documentación

Guarda las capturas en `jobber-k8s/AWS/autoscaling/pdb/images/`:

1. **PDB configurado** → `pdb-configured.png`
   ```powershell
   kubectl get pdb -n production
   kubectl describe pdb jobber-gateway-pdb -n production
   ```

2. **Estado de pods antes de actualización** → `pdb-before-update.png`
   ```powershell
   kubectl get pods -n production -l app=jobber-gateway -o wide
   ```

3. **Durante rolling update** → `pdb-during-update.png`
   ```powershell
   kubectl get pods -n production -l app=jobber-gateway -w
   ```
   Muestra que siempre hay al menos 1 pod disponible.

4. **Estado después de actualización** → `pdb-after-update.png`
   ```powershell
   kubectl get pods -n production -l app=jobber-gateway -o wide
   ```

---

### 9. Nota importante: PDB con 1 nodo

**Limitación con 1 nodo:**
- Con 1 nodo, si haces mantenimiento del nodo, todos los pods se detienen
- El PDB no puede proteger contra esto porque no hay otro nodo donde mover los pods
- **Solución**: Documentar teóricamente cómo funcionaría con múltiples nodos

**Documentación para portafolio:**
> "Configuré Pod Disruption Budget para servicios críticos (gateway, auth). Aunque en el entorno de desarrollo con 1 nodo no se puede demostrar visualmente el efecto completo, la configuración está lista y funcionará automáticamente en producción (EKS) con múltiples nodos. Durante actualizaciones o mantenimiento, Kubernetes respetará el PDB y mantendrá al menos 1 réplica disponible en otros nodos, asegurando alta disponibilidad."

---

### 10. Troubleshooting

| Síntoma | Diagnóstico | Acción |
| --- | --- | --- |
| PDB no se aplica | Selector no coincide con labels del deployment | Verificar labels: `kubectl get deployment -o yaml | Select-String labels` |
| Pods se detienen igual | Solo hay 1 réplica y minAvailable: 1 | Normal, necesita 2+ réplicas para ver efecto |
| PDB en estado "DisruptionsAllowed: 0" | No hay suficientes réplicas | Aumentar réplicas del deployment |

---

### 11. Checklist para producción/demo

- [ ] PDB creado para servicios críticos (gateway, auth)
- [ ] Verificado con `kubectl get pdb`
- [ ] Documentado comportamiento teórico (para 1 nodo)
- [ ] Explicado cómo funcionaría con múltiples nodos
- [ ] Capturas de pantalla guardadas

---

### 12. Referencias

- [Kubernetes Pod Disruption Budget](https://kubernetes.io/docs/tasks/run-application/configure-pdb/)
- [PDD Best Practices](https://kubernetes.io/docs/concepts/workloads/pods/disruptions/)

---

**Nota**: PDB funciona técnicamente con 1 nodo, pero el efecto real se ve con múltiples nodos. Puedes documentarlo teóricamente para tu portafolio.

