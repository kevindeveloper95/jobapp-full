## Guía de VPA (Vertical Pod Autoscaler)

Esta guía documenta la instalación y configuración del Vertical Pod Autoscaler (VPA) para ajustar automáticamente los `requests` y `limits` de CPU/memoria según el uso real de los pods.

---

### 1. ¿Qué es VPA?

**VPA (Vertical Pod Autoscaler)** ajusta automáticamente los recursos (`requests` y `limits`) de tus pods según su uso real.

**Diferencia con HPA:**
- **HPA**: Escala número de réplicas (horizontal)
- **VPA**: Ajusta recursos por pod (vertical)

**Beneficio**: Optimiza automáticamente recursos, evitando desperdicio o falta de recursos.

---

### 2. Modos de operación

#### 2.1. Off (solo recomendaciones)
- No cambia nada
- Solo sugiere valores óptimos
- Útil para empezar

#### 2.2. Initial (ajusta al crear)
- Ajusta recursos solo cuando se crea el pod
- No modifica pods existentes
- Útil para nuevos deployments

#### 2.3. Auto (ajusta automáticamente)
- Ajusta recursos en tiempo real
- Puede reiniciar pods para aplicar cambios
- Más agresivo, requiere cuidado

**Recomendación**: Empezar con modo "Off" para ver recomendaciones.

---

### 3. Prerrequisitos

- Clúster Kubernetes funcionando
- Metrics Server instalado (ya lo tienes para HPA)
- `kubectl` configurado
- Permisos de administrador

---

### 4. Instalar VPA

#### 4.1. Clonar repositorio de VPA

```powershell
# Clonar repositorio (o descargar manifiestos)
git clone https://github.com/kubernetes/autoscaler.git
cd autoscaler/vertical-pod-autoscaler/

# O descargar directamente los manifiestos
```

#### 4.2. Instalar componentes de VPA

```powershell
# Instalar VPA (versión para Kubernetes 1.30)
kubectl apply -f https://github.com/kubernetes/autoscaler/releases/download/vpa-release-0.14.0/vpa-release.yaml
```

O si prefieres instalar manualmente:

```powershell
# Crear namespace
kubectl create namespace vpa-system

# Aplicar componentes
kubectl apply -f https://raw.githubusercontent.com/kubernetes/autoscaler/master/vertical-pod-autoscaler/deploy/vpa-admission-controller.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes/autoscaler/master/vertical-pod-autoscaler/deploy/vpa-recommender.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes/autoscaler/master/vertical-pod-autoscaler/deploy/vpa-updater.yaml
```

#### 4.3. Verificar instalación

```powershell
# Ver pods de VPA
kubectl get pods -n vpa-system

# Verificar deployments
kubectl get deployment -n vpa-system
```

**Resultado esperado**: 
- `vpa-recommender` (Running)
- `vpa-updater` (Running)
- `vpa-admission-controller` (Running)

---

### 5. Configurar VPA para un servicio

#### 5.1. Crear VPA en modo "Off" (recomendaciones)

Crea el archivo `jobber-k8s/AWS/autoscaling/vpa/gateway-vpa.yaml`:

```yaml
apiVersion: autoscaling.k8s.io/v1
kind: VerticalPodAutoscaler
metadata:
  name: jobber-gateway-vpa
  namespace: production
spec:
  targetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: jobber-gateway
  updatePolicy:
    updateMode: "Off"  # Solo recomendaciones, no cambia nada
  resourcePolicy:
    containerPolicies:
    - containerName: jobber-gateway
      minAllowed:
        cpu: 50m
        memory: 100Mi
      maxAllowed:
        cpu: 1000m
        memory: 2Gi
```

#### 5.2. Aplicar VPA

```powershell
kubectl apply -f jobber-k8s/AWS/autoscaling/vpa/gateway-vpa.yaml
```

#### 5.3. Ver recomendaciones

```powershell
# Ver VPA
kubectl get vpa -n production

# Ver recomendaciones detalladas
kubectl describe vpa jobber-gateway-vpa -n production
```

**Busca en la salida:**
```
Recommendation:
  Container Recommendations:
    Container Name: jobber-gateway
    Target:
      Cpu: 80m
      Memory: 200Mi
    Lower Bound:
      Cpu: 50m
      Memory: 100Mi
    Upper Bound:
      Cpu: 150m
      Memory: 300Mi
```

---

### 6. Probar VPA en modo "Initial"

#### 6.1. Cambiar a modo Initial

```yaml
apiVersion: autoscaling.k8s.io/v1
kind: VerticalPodAutoscaler
metadata:
  name: jobber-gateway-vpa
  namespace: production
spec:
  targetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: jobber-gateway
  updatePolicy:
    updateMode: "Initial"  # Ajusta al crear pods
  resourcePolicy:
    containerPolicies:
    - containerName: jobber-gateway
      minAllowed:
        cpu: 50m
        memory: 100Mi
      maxAllowed:
        cpu: 1000m
        memory: 2Gi
```

#### 6.2. Aplicar y observar

```powershell
kubectl apply -f jobber-k8s/AWS/autoscaling/vpa/gateway-vpa.yaml

# Eliminar un pod para que se recree con nuevos recursos
kubectl delete pod <pod-name> -n production

# Ver el nuevo pod
kubectl describe pod <new-pod-name> -n production | Select-String -Pattern "Requests|Limits"
```

**Resultado esperado**: El nuevo pod tendrá los recursos ajustados según las recomendaciones del VPA.

---

### 7. Modo "Auto" (avanzado, usar con cuidado)

```yaml
updatePolicy:
  updateMode: "Auto"  # Ajusta automáticamente (puede reiniciar pods)
```

**⚠️ Advertencia**: El modo Auto puede reiniciar pods para aplicar cambios. Úsalo solo cuando:
- Tengas múltiples réplicas
- El servicio pueda tolerar reinicios
- Hayas probado en modo "Off" e "Initial" primero

---

### 8. Capturas de pantalla para documentación

Guarda las capturas en `jobber-k8s/AWS/autoscaling/vpa/images/`:

1. **VPA configurado** → `vpa-configured.png`
   ```powershell
   kubectl get vpa -n production
   kubectl describe vpa jobber-gateway-vpa -n production
   ```

2. **Recomendaciones del VPA** → `vpa-recommendations.png`
   ```powershell
   kubectl describe vpa jobber-gateway-vpa -n production | Select-String -Pattern "Recommendation" -Context 0,20
   ```

3. **Comparación antes/después** → `vpa-before-after.png`
   - Antes: requests/limits originales
   - Después: requests/limits recomendados por VPA

4. **Pod con recursos ajustados (modo Initial)** → `vpa-pod-adjusted.png`
   ```powershell
   kubectl describe pod <pod-name> -n production | Select-String -Pattern "Requests|Limits"
   ```

---

### 9. Integración con HPA

**VPA y HPA pueden trabajar juntos:**

- **VPA**: Ajusta recursos por pod (CPU/memoria)
- **HPA**: Escala número de réplicas

**⚠️ Limitación**: No uses VPA en modo "Auto" con HPA en el mismo deployment. Usa:
- VPA modo "Off" o "Initial" + HPA (recomendado)
- O solo VPA modo "Auto" (sin HPA)

---

### 10. Troubleshooting

| Síntoma | Diagnóstico | Acción |
| --- | --- | --- |
| VPA no muestra recomendaciones | No hay suficientes métricas históricas | Esperar 1-2 semanas de uso, o usar métricas sintéticas |
| Recomendaciones muy altas/bajas | Datos insuficientes o picos anormales | Revisar métricas en Prometheus, ajustar minAllowed/maxAllowed |
| Pods se reinician constantemente | Modo "Auto" muy agresivo | Cambiar a modo "Initial" o "Off" |

---

### 11. Cuándo usar VPA

**Ideal para:**
- Optimizar recursos a largo plazo
- Servicios con uso variable
- Reducir costos ajustando recursos

**No usar cuando:**
- Ya tienes requests/limits bien calibrados
- El servicio tiene uso muy estable
- Necesitas control total sobre recursos

---

### 12. Checklist para producción/demo

- [ ] VPA instalado en el clúster
- [ ] VPA creado en modo "Off" para ver recomendaciones
- [ ] Revisadas recomendaciones y comparadas con valores actuales
- [ ] (Opcional) Probado modo "Initial" en desarrollo
- [ ] Documentado proceso y recomendaciones
- [ ] Capturas de pantalla guardadas

---

### 13. Referencias

- [VPA GitHub](https://github.com/kubernetes/autoscaler/tree/master/vertical-pod-autoscaler)
- [VPA Documentation](https://github.com/kubernetes/autoscaler/blob/master/vertical-pod-autoscaler/README.md)

---

**Nota**: VPA funciona perfectamente con 1 nodo. Ajusta recursos de pods, no nodos. Empieza con modo "Off" para ver recomendaciones antes de aplicar cambios automáticos.

