# Guía: Escalar Nodos a 0 para Ahorrar Dinero (Proyecto de Portafolio)

> **Contexto**: Esta guía está diseñada específicamente para proyectos de portafolio donde el ahorro de costos es importante y un delay de 2-3 minutos al reactivar es aceptable.

**Problema**: Aunque los pods estén en 0 réplicas, los nodos EC2 siguen activos y AWS te cobra por ellos.

**Solución**: Configurar Cluster Autoscaler para que elimine los nodos cuando todos los pods estén en 0, optimizando costos para un proyecto de portafolio.

---

## 📋 Checklist Rápido

- [ ] Cluster Autoscaler instalado y funcionando
- [ ] Nodegroup configurado con `nodes-min: 0`
- [ ] Cluster Autoscaler configurado para permitir escalado a 0
- [ ] KEDA Cron configurado para escalar pods a 0 (L-V 19:00-09:00 + fines de semana)
- [ ] Verificado que el escalado funciona correctamente

---

## 🎯 Objetivo de esta Configuración

**Horario Laboral (Lunes-Viernes 09:00-19:00)**:
- ✅ Pods activos (1 réplica mínima)
- ✅ Nodos activos (1 nodo mínimo)

**Horario No Laboral (Lunes-Viernes 19:00-09:00 + Fines de Semana)**:
- ❌ Pods a 0 réplicas (KEDA Cron)
- ❌ Nodos a 0 (Cluster Autoscaler)
- 💰 **Ahorro**: $0 en EC2 durante horarios inactivos

---

## 📝 Guía Paso a Paso

### Paso 1: Verificar que KEDA Cron está Configurado

**Antes de configurar Cluster Autoscaler, asegúrate de que KEDA Cron ya está configurado para escalar pods a 0.**

```powershell
# Verificar que todos los ScaledObjects están aplicados
kubectl get scaledobjects -n production

# Verificar horario configurado en un ScaledObject
kubectl describe scaledobject jobber-gateway-keda-scaledobject -n production
```

**Debes ver:**
- `start: "0 9 * * 1-5"` (09:00 Lunes-Viernes)
- `end: "0 19 * * 1-5"` (19:00 Lunes-Viernes)
- `minReplicaCount: 0`

**Si KEDA Cron no está configurado**, sigue primero la guía: `../README-CRON.md`

---

### Paso 2: Verificar o Instalar Cluster Autoscaler

#### 2.1. Verificar si Cluster Autoscaler está instalado

```powershell
# Verificar que Cluster Autoscaler está corriendo
kubectl -n kube-system get pods -l app=cluster-autoscaler

# Ver logs para confirmar que está funcionando
kubectl -n kube-system logs -f deployment/cluster-autoscaler --tail=50
```

**Resultado esperado:**
```
NAME                                  READY   STATUS    RESTARTS   AGE
cluster-autoscaler-xxxxxxxxxx-xxxxx   1/1     Running   0          5d
```

#### 2.2. Si no está instalado, instalarlo

**Si Cluster Autoscaler no está instalado**, sigue la guía completa: `../../README-CLUSTER-AUTOSCALER.md`

**Resumen rápido:**
1. Crear política IAM para Cluster Autoscaler
2. Asociar OIDC provider
3. Crear Service Account con permisos
4. Instalar Cluster Autoscaler
5. Configurar tags en Auto Scaling Groups

---

### Paso 3: Configurar Nodegroup para Permitir 0 Nodos

#### 3.1. Ver nodegroup actual

```powershell
# Ver información del nodegroup
eksctl get nodegroup --cluster jobberapp-demo --region us-east-1
```

**Anota el nombre de tu nodegroup** (ej: `demo-small`, `default`, etc.)

#### 3.2. Actualizar nodegroup (permitir 0 nodos)

```powershell
# ⚠️ IMPORTANTE: Reemplaza "demo-small" con el nombre de TU nodegroup
# Reemplaza "jobberapp-demo" con el nombre de TU clúster
# Reemplaza "us-east-1" con tu región

eksctl scale nodegroup \
  --cluster jobberapp-demo \
  --name demo-small \
  --nodes-min 0 \
  --nodes-max 3 \
  --region us-east-1
```

**Resultado esperado:**
```
[ℹ]  scaling nodegroup "demo-small" in cluster "jobberapp-demo"
[✓]  scaling nodegroup "demo-small" in cluster "jobberapp-demo" succeeded
```

#### 3.3. Verificar que se actualizó correctamente

```powershell
eksctl get nodegroup --cluster jobberapp-demo --region us-east-1
```

**Debes ver `MIN: 0` en la salida:**
```
CLUSTER          NODEGROUP    STATUS  MIN  MAX  DESIRED  INSTANCE TYPE
jobberapp-demo   demo-small   ACTIVE  0    3    1        t3.medium
```

---

### Paso 4: Configurar Cluster Autoscaler para Escalar a 0

#### 4.1. Editar el Deployment del Cluster Autoscaler

```powershell
kubectl -n kube-system edit deployment cluster-autoscaler
```

Esto abrirá el editor (vim por defecto).

#### 4.2. Buscar la sección `args:`

Usa `/args` para buscar la sección de argumentos.

#### 4.3. Agregar/Modificar estos argumentos

**Busca la sección:**
```yaml
spec:
  template:
    spec:
      containers:
      - name: cluster-autoscaler
        args:
```

**Agrega o modifica los argumentos para que queden así:**
```yaml
spec:
  template:
    spec:
      containers:
      - name: cluster-autoscaler
        args:
        - --balance-similar-node-groups
        - --skip-nodes-with-system-pods=false      # ⚠️ CRÍTICO: Permite eliminar nodos con pods del sistema
        - --skip-nodes-with-local-storage=false    # Permite eliminar nodos con storage local
        - --scale-down-delay-after-add=10m         # Esperar 10 min después de agregar nodo
        - --scale-down-unneeded-time=10m           # Esperar 10 min antes de eliminar nodo no usado
        - --scale-down-utilization-threshold=0.5    # Eliminar nodo si uso < 50%
        - --max-node-provision-time=15m            # Tiempo máximo para crear nodo
```

**⚠️ IMPORTANTE**: 
- `--skip-nodes-with-system-pods=false` es **CRÍTICO** - permite eliminar nodos incluso si tienen pods del sistema (como `kube-proxy`, `aws-node`)
- Esta configuración es adecuada para proyectos de portafolio donde el ahorro de costos es prioritario
- En producción crítica, considera mantener 1 nodo mínimo

#### 4.4. Guardar y salir

**En vim:**
1. Presiona `Esc` para salir del modo inserción
2. Escribe `:wq` y presiona `Enter` para guardar y salir

**En nano:**
1. Presiona `Ctrl + O` para guardar
2. Presiona `Ctrl + X` para salir

#### 4.5. Verificar que el Deployment se actualizó

```powershell
# Ver el Deployment actualizado
kubectl -n kube-system get deployment cluster-autoscaler -o yaml | Select-String -Pattern "skip-nodes-with-system-pods"

# Verificar que el pod se reinició con la nueva configuración
kubectl -n kube-system get pods -l app=cluster-autoscaler
```

**Debes ver el pod reiniciándose o ya reiniciado con la nueva configuración.**

---

### Paso 5: Verificar que Todo Está Configurado Correctamente

#### 5.1. Verificar configuración completa

```powershell
# 1. Verificar nodegroup (debe tener MIN: 0)
eksctl get nodegroup --cluster jobberapp-demo --region us-east-1

# 2. Verificar Cluster Autoscaler está corriendo
kubectl -n kube-system get pods -l app=cluster-autoscaler

# 3. Verificar argumentos del Cluster Autoscaler
kubectl -n kube-system get deployment cluster-autoscaler -o jsonpath='{.spec.template.spec.containers[0].args}' | ConvertFrom-Json

# 4. Verificar KEDA Cron está configurado
kubectl get scaledobjects -n production
```

#### 5.2. Verificar logs del Cluster Autoscaler

```powershell
kubectl -n kube-system logs -f deployment/cluster-autoscaler --tail=100
```

**Busca mensajes como:**
- `Successfully registered cluster-autoscaler with cloud provider`
- `Node group demo-small: minSize=0, maxSize=3, currentSize=1`
- `skip-nodes-with-system-pods=false` (debe aparecer en los logs)

---

### Paso 6: Probar el Escalado Automático

#### 6.1. Monitorear en tiempo real (recomendado)

**Abre 3 terminales diferentes:**

**Terminal 1: Monitorear pods**
```powershell
kubectl get pods -n production -w
```

**Terminal 2: Monitorear nodos**
```powershell
kubectl get nodes -w
```

**Terminal 3: Logs del Cluster Autoscaler**
```powershell
kubectl -n kube-system logs -f deployment/cluster-autoscaler
```

#### 6.2. Esperar al horario de apagado (19:00) o probar manualmente

**Opción A: Esperar al horario real (19:00)**
- A las 19:00, KEDA Cron escalará los pods a 0
- Después de 10 minutos (19:10), Cluster Autoscaler escalará los nodos a 0

**Opción B: Probar manualmente (para verificar que funciona)**

```powershell
# 1. Escalar manualmente un deployment a 0 para simular
kubectl scale deployment jobber-gateway -n production --replicas=0

# 2. Esperar 10 minutos y verificar que el nodo se escala a 0
kubectl get nodes
eksctl get nodegroup --cluster jobberapp-demo --region us-east-1

# 3. Escalar de vuelta a 1 para reactivar
kubectl scale deployment jobber-gateway -n production --replicas=1

# 4. Esperar 2-3 minutos y verificar que el nodo se crea
kubectl get nodes
```

---

## 🔄 Cómo Funciona el Escalado Automático Completo

### Flujo Completo: Horario No Laboral (L-V 19:00-09:00 + Fines de Semana)

**Lunes-Viernes a las 19:00:**
1. ⏰ **19:00** → KEDA Cron detecta que es hora de apagar
2. 📉 **19:00** → KEDA Cron escala **todos los pods a 0 réplicas**
3. 🖥️ **19:00-19:10** → Nodos quedan vacíos (solo pods del sistema como `kube-system`)
4. 👀 **19:10** → Cluster Autoscaler detecta nodos subutilizados
5. ⏳ **19:10** → CA espera 10 minutos (configurado en `--scale-down-unneeded-time`)
6. 🗑️ **19:20** → CA escala el **nodegroup a 0** → Nodos EC2 se eliminan
7. 💰 **Ahorro**: No pagas por instancias EC2 durante la noche

**Fines de Semana (Sábado y Domingo):**
- Los pods ya están en 0 (KEDA Cron los mantiene en 0)
- Los nodos también están en 0 (Cluster Autoscaler los mantiene en 0)
- 💰 **Ahorro total**: $0 en EC2 durante todo el fin de semana

### Flujo Completo: Horario Laboral (L-V 09:00-19:00)

**Lunes-Viernes a las 09:00:**
1. ⏰ **09:00** → KEDA Cron detecta que es hora de activar
2. 📈 **09:00** → KEDA Cron escala **pods a 1 réplica** (mínimo)
3. ⏳ **09:00** → Pods quedan en estado `Pending` (no hay nodos todavía)
4. 👀 **09:00** → Cluster Autoscaler detecta pods pendientes
5. 🆕 **09:00-09:03** → CA escala el **nodegroup a 1** → AWS crea nuevo nodo EC2 (2-3 minutos)
6. ✅ **09:03** → Pods se programan en el nuevo nodo
7. 🚀 **09:03** → Aplicación está disponible y funcionando

**Durante el día (09:00-19:00):**
- Pods activos (1 réplica mínima, puede escalar más si hay carga)
- Nodos activos (1 nodo mínimo, puede escalar más si hay carga)
- Aplicación disponible para uso

---

## ✅ Verificación del Funcionamiento

---

### 7.1. Verificar estado del nodegroup

### 5.1. Monitorear en tiempo real

**Terminal 1: Monitorear pods**
```powershell
kubectl get pods -n production -w
```

**Terminal 2: Monitorear nodos**
```powershell
kubectl get nodes -w
```

**Terminal 3: Logs del Cluster Autoscaler**
```powershell
kubectl -n kube-system logs -f deployment/cluster-autoscaler
```

### 5.2. Verificar estado del nodegroup

```powershell
eksctl get nodegroup --cluster jobberapp-demo --region us-east-1
```

**Salida esperada cuando está en 0:**
```
CLUSTER          NODEGROUP    STATUS  MIN  MAX  DESIRED  INSTANCE TYPE  IMAGE ID
jobberapp-demo   demo-small   ACTIVE  0    3    0        t3.medium      AL2_x86_64
```

### 5.3. Logs esperados


**Cuando escala de 0 a 1 (09:00):**
```
I0920 09:00:00.123456       1 cluster_autoscaler.go:1234] Scale up: 1 node(s) needed
I0920 09:00:05.654321       1 cluster_autoscaler.go:1235] Node i-0987654321fedcba0 created
```

---

## 8. ⚠️ Consideraciones Importantes

### 6.1. Limitaciones

1. **Pods del sistema**: Si tienes pods críticos en `kube-system` (como `cluster-autoscaler` mismo), el CA puede no escalar a 0 completamente
2. **DaemonSets**: Los DaemonSets (como `kube-proxy`, `aws-node`) siempre corren en cada nodo
3. **Tiempo de arranque**: Cuando se reactiva, toma **2-3 minutos** crear el nodo y programar los pods

### 6.2. Soluciones

1. **Usar `--skip-nodes-with-system-pods=false`** (ya configurado arriba)
2. **Mover pods críticos a nodos dedicados** (no escalables)
3. **Aceptar que siempre habrá 1 nodo mínimo** si tienes DaemonSets críticos

---

## 9. 💰 Ahorro Estimado

### Cálculo detallado

**Costo t3.medium**: ~$0.0416/hora = **~$30/mes** (720 horas)

**Horario activo (L-V 09:00-19:00)**:
- Días laborables: ~22 días/mes
- Horas activas: 10 horas/día × 22 días = **220 horas/mes**
- Costo activo: 220 horas × $0.0416 = **$9.15/mes**

**Horario inactivo (19:00-09:00 + fines de semana)**:
- Horas inactivas: 720 - 220 = **500 horas/mes**
- Costo si se apaga: **$0/mes**
- **Ahorro potencial**: 500 horas × $0.0416 = **$20.80/mes**

### Escenario 1: Nodos a 0 (recomendado para proyecto de portafolio) ⭐

- **Horario activo**: $9.15/mes
- **Horario inactivo**: $0/mes
- **Total**: **~$9.15/mes**
- **Ahorro vs siempre encendido**: **$20.85/mes (69% de ahorro)**
- **Ahorro anual**: **~$250/año**

**Ventajas para proyecto de portafolio**:
- ✅ Ahorro significativo ($20.85/mes = $250/año) - importante para proyectos personales
- ✅ Demuestra conocimiento avanzado de autoscaling en entrevistas técnicas
- ✅ Muestra habilidades de cost optimization en AWS
- ✅ El delay de 2-3 minutos no es crítico para un proyecto de portafolio
- ✅ Demuestra integración de múltiples tecnologías (KEDA + Cluster Autoscaler)

**Desventajas**:
- ⚠️ Delay de 2-3 minutos al reactivar (aceptable para proyecto de portafolio)
- ⚠️ Requiere configuración adicional del Cluster Autoscaler

### Escenario 2: Mantener 1 nodo mínimo (más simple)

- **Siempre**: 1 nodo t3.medium = **~$30/mes**
- **Ventaja**: No hay delay de arranque, más seguro, configuración más simple

**Cuándo usar**:
- Si necesitas disponibilidad inmediata 24/7
- Si el delay de 2-3 minutos es inaceptable
- Si prefieres simplicidad sobre ahorro

### 🎯 Recomendación para Proyecto de Portafolio

**✅ SÍ vale la pena escalar nodos a 0 en un proyecto de portafolio** por estas razones:

1. **Ahorro significativo**: $20.85/mes ($250/año) es considerable para un proyecto personal de portafolio
2. **Demuestra conocimiento técnico avanzado en entrevistas**: 
   - Integración KEDA + Cluster Autoscaler
   - Cost optimization en AWS
   - Autoscaling completo (pods + nodos)
   - Conocimiento de mejores prácticas de Kubernetes
3. **Valor para el portafolio**: Es una característica técnica impresionante que diferencia tu proyecto de otros portafolios básicos
4. **El delay es aceptable**: 2-3 minutos de espera al reactivar es perfectamente aceptable para un proyecto de portafolio (no es un servicio crítico 24/7)
5. **Alineado con uso real**: Si tu proyecto de portafolio solo se usa en horario laboral, no tiene sentido pagar por las noches y fines de semana

**Conclusión**: Para un proyecto de portafolio, **escalar nodos a 0 es la mejor opción** porque:
- Demuestra habilidades avanzadas de DevOps y cost optimization
- Ahorra dinero significativo sin sacrificar funcionalidad crítica
- Es un excelente punto de conversación en entrevistas técnicas
- Muestra que entiendes cómo optimizar costos en la nube

---

## 10. Troubleshooting

| Problema | Solución |
|----------|----------|
| Nodos no escalan a 0 | Verificar que `nodes-min: 0` está configurado |
| CA no elimina nodos | Verificar logs del CA, puede estar esperando el delay (10 min) |
| Pods quedan Pending al reactivar | Normal, esperar 2-3 minutos para que el nodo se cree |
| CA no crea nodos | Verificar permisos IAM y tags del ASG |

---

## 11. Comandos Útiles

```powershell
# Ver estado actual
kubectl get nodes
kubectl get pods -n production
eksctl get nodegroup --cluster jobberapp-demo --region us-east-1

# Forzar escalado manual (si es necesario)
eksctl scale nodegroup --cluster jobberapp-demo --name demo-small --nodes 0 --region us-east-1

# Ver logs del CA
kubectl -n kube-system logs -f deployment/cluster-autoscaler

# Ver eventos recientes
kubectl get events -n production --sort-by='.lastTimestamp' | Select-Object -Last 20
```

---

## 12. Referencias

- [Cluster Autoscaler AWS](https://github.com/kubernetes/autoscaler/tree/master/cluster-autoscaler/cloudprovider/aws)
- [EKS Best Practices - Autoscaling](https://aws.github.io/aws-eks-best-practices/cluster-autoscaling/)
- [Cluster Autoscaler - Scale Down FAQ](https://github.com/kubernetes/autoscaler/blob/master/cluster-autoscaler/FAQ.md#how-does-scale-down-work)

---

**✅ Listo**: Con esta configuración, cuando KEDA Cron escala los pods a 0, el Cluster Autoscaler automáticamente eliminará los nodos después de 10 minutos, ahorrando dinero en EC2. Esta configuración es ideal para proyectos de portafolio donde el ahorro de costos y la demostración de habilidades técnicas avanzadas son prioridades.

