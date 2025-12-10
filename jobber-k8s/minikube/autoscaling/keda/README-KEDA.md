# Guía para Probar KEDA en Minikube

Esta guía te permite **probar y documentar** KEDA en Minikube antes de aplicarlo en producción (EKS). El proceso es similar a producción, pero aquí el objetivo es **entender cómo funciona** y **tomar capturas para documentación**.

---

## 1. ¿Por qué probar en Minikube primero?

- ✅ **Sin costo**: No pagas por recursos en Minikube
- ✅ **Pruebas seguras**: Puedes experimentar sin afectar producción
- ✅ **Documentación**: Tomar capturas de pantalla para tu portafolio
- ✅ **Aprendizaje**: Entender cómo funciona antes de aplicarlo en EKS
- ✅ **Validación**: Verificar que la configuración es correcta

---

## 2. Prerrequisitos

- Minikube corriendo
- KEDA instalado en Minikube
- RabbitMQ desplegado y funcionando
- `kubectl` configurado contra Minikube
- Helm instalado (para instalar KEDA si no está instalado)

### Verificar que Minikube está corriendo

```powershell
# Verificar Minikube
minikube status

# Verificar que KEDA está instalado
kubectl get pods -n keda-system

# Verificar que RabbitMQ está funcionando
kubectl get pods -n production -l app=jobber-queue

# Verificar que tienes un deployment para probar (notification service)
kubectl get deployments -n production | Select-String -Pattern "notification"
```

**Resultado esperado**: 
- Minikube en estado `Running`
- KEDA pods en estado `Running` (si ya está instalado)
- RabbitMQ pod en estado `Running`
- Notification service deployment existente

---

## 3. Instalar KEDA (si no está instalado)

### 3.1. Verificar que Helm está instalado

```powershell
# Verificar Helm
helm version

# Si no está instalado, ver: ../../../AWS/autoscaling/keda/INSTALL-HELM.md
```

### 3.2. Agregar repositorio de Helm

```powershell
helm repo add kedacore https://kedacore.github.io/charts
helm repo update
```

### 3.3. Instalar KEDA

```powershell
helm install keda kedacore/keda `
  --namespace keda-system `
  --create-namespace
```

### 3.4. Verificar instalación

```powershell
# Ver pods de KEDA
kubectl get pods -n keda-system

# Verificar que está funcionando
kubectl get deployment keda-operator -n keda-system
kubectl get deployment keda-metrics-apiserver -n keda-system
```

**Resultado esperado**: Ambos deployments en estado `Running`.

---

## 4. Configurar KEDA para RabbitMQ (Notification Service)

### 4.1. Obtener información de RabbitMQ

Necesitas:
- **Host**: `jobber-queue.production.svc.cluster.local` (service de RabbitMQ)
- **Puerto**: `5672` (puerto AMQP)
- **Usuario y contraseña**: Del secret `jobber-backend-secret`
- **Cola**: `auth-email-queue` o `order-email-queue`

### 4.2. Verificar credenciales de RabbitMQ

```powershell
# Obtener credenciales del secret existente
kubectl get secret jobber-backend-secret -n production -o jsonpath='{.data.jobber-rabbitmq-user}' | ForEach-Object { [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($_)) }
kubectl get secret jobber-backend-secret -n production -o jsonpath='{.data.jobber-rabbitmq-password}' | ForEach-Object { [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($_)) }
```

### 4.3. Aplicar ScaledObject para Notification Service

El archivo ya existe: `notification-scaledobject.yaml`

```powershell
# Aplicar ScaledObject
kubectl apply -f jobber-k8s/minikube/autoscaling/keda/notification-scaledobject.yaml

# Verificar que se creó
kubectl get scaledobject -n production

# Ver detalles
kubectl describe scaledobject jobber-notification-scaledobject -n production
```

---

## 5. Probar escalado automático

### 5.1. Estado inicial (0 réplicas)

```powershell
# Ver deployment (debería estar en 0 réplicas si no hay mensajes)
kubectl get deployment jobber-notification -n production

# Ver pods
kubectl get pods -n production -l app=jobber-notification
```

**Resultado esperado**: 0 réplicas (escalado a 0 porque no hay mensajes).

**Captura de pantalla**: `keda-scaled-to-zero.png`
- Muestra deployment con 0 réplicas
- **Descripción**: "KEDA escaló notification service a 0 réplicas cuando no hay mensajes"

---

### 5.2. Enviar mensajes a la cola

Puedes usar la UI de RabbitMQ o crear un script de prueba.

**Opción 1: Usar RabbitMQ Management UI**

```powershell
# Port forward para acceder a RabbitMQ Management UI
kubectl port-forward -n production deployment/jobber-queue 15672:15672
```

Abre: http://localhost:15672
- Usuario: `jobber` (o el que tengas configurado)
- Contraseña: `jobberpass` (o la que tengas configurada)

Ve a la cola `auth-email-queue` y envía un mensaje de prueba.

**Opción 2: Enviar mensaje desde terminal**

```powershell
# Ejecutar un comando en el pod de RabbitMQ para enviar un mensaje
# (Esto requiere tener un script o usar rabbitmqadmin)
```

**Monitorear en tiempo real:**

```powershell
# Terminal 1: Monitorear deployment
kubectl get deployment jobber-notification -n production -w

# Terminal 2: Monitorear pods
kubectl get pods -n production -l app=jobber-notification -w

# Terminal 3: Monitorear ScaledObject
kubectl get scaledobject jobber-notification-scaledobject -n production -w
```

**Resultado esperado**: 
- Mensajes llegan → réplicas aumentan
- Mensajes se procesan → réplicas disminuyen
- Sin mensajes → escala a 0

**Captura de pantalla**: `keda-scaling-up.png`
- Muestra deployment escalando de 0 a 1+ réplicas
- **Descripción**: "KEDA escaló notification service cuando llegaron mensajes a la cola"

---

### 5.3. Verificar escalado hacia abajo

Después de que se procesen los mensajes:

```powershell
# Ver deployment
kubectl get deployment jobber-notification -n production

# Ver pods
kubectl get pods -n production -l app=jobber-notification
```

**Resultado esperado**: Réplicas disminuyen o vuelven a 0 cuando no hay mensajes.

**Captura de pantalla**: `keda-scaling-down.png`
- Muestra deployment escalando hacia abajo
- **Descripción**: "KEDA escaló notification service hacia abajo cuando se procesaron los mensajes"

---

## 6. Capturas de pantalla para documentación

Guarda las capturas en: `jobber-k8s/minikube/autoscaling/keda/images/`

### 6.1. Estado inicial (0 réplicas)

```powershell
kubectl get deployment jobber-notification -n production
kubectl get pods -n production -l app=jobber-notification
```

**Captura**: `keda-scaled-to-zero.png`

---

### 6.2. ScaledObject configurado

```powershell
kubectl get scaledobject -n production
kubectl describe scaledobject jobber-notification-scaledobject -n production
```

**Captura**: `keda-scaledobject.png`
- Muestra el ScaledObject con triggers de RabbitMQ configurados

---

### 6.3. Escalado activo (réplicas aumentando)

```powershell
kubectl get deployment jobber-notification -n production -w
```

**Captura**: `keda-scaling-up.png`
- Muestra deployment escalando de 0 a 1+ réplicas

---

### 6.4. Mensajes en cola (RabbitMQ UI)

- Acceder a RabbitMQ Management UI (http://localhost:15672)
- Ver cola `auth-email-queue` con mensajes

**Captura**: `keda-queue-messages.png`
- Muestra RabbitMQ UI con mensajes en la cola

---

### 6.5. Escalado hacia abajo (volviendo a 0)

```powershell
kubectl get deployment jobber-notification -n production
```

**Captura**: `keda-scaling-down.png`
- Muestra deployment escalando hacia abajo

---

### 6.6. Describe detallado del ScaledObject

```powershell
kubectl describe scaledobject jobber-notification-scaledobject -n production
```

**Captura**: `keda-describe.png`
- Muestra todos los detalles del ScaledObject

---

## 7. Verificar que funciona correctamente

### Checklist de verificación:

- [ ] KEDA instalado y funcionando
- [ ] ScaledObject creado correctamente
- [ ] Deployment escala a 0 cuando no hay mensajes
- [ ] Deployment escala cuando llegan mensajes
- [ ] Deployment escala hacia abajo cuando se procesan mensajes
- [ ] Capturas de pantalla guardadas
- [ ] Documentación actualizada

### Comandos de verificación:

```powershell
# Verificar KEDA
kubectl get pods -n keda-system

# Verificar ScaledObject
kubectl get scaledobject jobber-notification-scaledobject -n production

# Verificar deployment
kubectl get deployment jobber-notification -n production

# Ver logs de KEDA (si hay problemas)
kubectl logs -n keda-system -l app=keda-operator --tail=50
```

---

## 8. Diferencias entre Minikube y Producción

| Aspecto | Minikube (Pruebas) | Producción (EKS) |
|---------|-------------------|-------------------|
| **Objetivo** | Probar y documentar | Escalar por mensajes en cola |
| **Costo** | Gratis | Ahorra recursos escalando a 0 |
| **Configuración** | Misma | Misma |
| **Comandos** | Mismos | Mismos |
| **RabbitMQ** | Local en Minikube | En EKS |

**Conclusión**: El proceso es **exactamente el mismo**, solo cambia el **contexto** (pruebas vs producción).

---

## 9. Limpiar después de las pruebas

Si quieres eliminar el ScaledObject de prueba:

```powershell
# Eliminar ScaledObject
kubectl delete scaledobject jobber-notification-scaledobject -n production

# Verificar que se eliminó
kubectl get scaledobject -n production

# El deployment volverá a su estado normal (sin escalado automático)
kubectl get deployment jobber-notification -n production
```

**Nota**: Si quieres mantener KEDA funcionando, no elimines los pods de KEDA.

---

## 10. Próximos pasos para producción

Una vez verificado en Minikube:

1. ✅ **Documentar comportamiento observado**
2. ✅ **Guardar capturas de pantalla**
3. ✅ **Ajustar configuración según necesidades reales**
4. ✅ **Aplicar en EKS con la misma configuración**
   - Ver: `../../../AWS/autoscaling/keda/README-KEDA.md`
5. ✅ **Monitorear en producción durante los primeros días**

---

## 11. Troubleshooting

### Problema: ScaledObject no escala

**Solución:**
```powershell
# Verificar que KEDA está funcionando
kubectl get pods -n keda-system

# Ver logs de KEDA
kubectl logs -n keda-system -l app=keda-operator --tail=100

# Ver detalles del ScaledObject
kubectl describe scaledobject jobber-notification-scaledobject -n production

# Verificar conectividad a RabbitMQ
kubectl exec -it -n production deployment/jobber-notification -- ping jobber-queue.production.svc.cluster.local
```

**Posibles causas**:
- KEDA no está funcionando
- RabbitMQ no accesible
- Credenciales incorrectas
- No hay mensajes en la cola

---

### Problema: Pods no se crean

**Solución:**
- Verificar que `minReplicaCount: 0` está configurado (es normal que esté en 0 si no hay mensajes)
- Enviar mensajes a la cola para activar el escalado
- Verificar que RabbitMQ tiene mensajes en la cola

---

### Problema: Escala demasiado rápido

**Solución:**
- Aumentar `queueLength` en el ScaledObject
- Ajustar `cooldownPeriod` para evitar escalado muy frecuente

---

### Problema: No escala hacia abajo

**Solución:**
- Verificar que los mensajes se están procesando
- Ajustar `cooldownPeriod` en el ScaledObject
- Verificar que no hay mensajes pendientes en la cola

---

## 12. Referencias

- [KEDA Documentation](https://keda.sh/docs/)
- [KEDA RabbitMQ Scaler](https://keda.sh/docs/scalers/rabbitmq/)
- [KEDA Installation](https://keda.sh/docs/deploy/)
- **Documentación de producción**: `../../../AWS/autoscaling/keda/README-KEDA.md`

---

## 13. Resumen

**Proceso en Minikube:**
1. Instalar KEDA (si no está instalado)
2. Aplicar ScaledObject con RabbitMQ
3. Probar escalado automático (enviar mensajes)
4. Monitorear comportamiento
5. Tomar capturas de pantalla
6. Verificar que funciona
7. Limpiar (opcional)

**Proceso en Producción (EKS):**
1. Instalar KEDA
2. Aplicar ScaledObject con RabbitMQ
3. Monitorear escalado automático
4. Verificar ahorro de recursos

**Conclusión**: El proceso es **exactamente el mismo**, solo cambia el **contexto** (pruebas vs producción).

