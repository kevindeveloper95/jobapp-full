# 🔧 Herramientas de Diagnóstico - Jobber Microservices

Este directorio contiene scripts y guías para diagnosticar y verificar el correcto funcionamiento de todos los componentes del sistema Jobber.

## 📁 Archivos Disponibles

### 🚀 Scripts de PowerShell (Windows)

| Script | Descripción | Cuándo Usar |
|--------|-------------|-------------|
| **`diagnostics.ps1`** | Diagnóstico completo del sistema | Siempre primero - te muestra todo el estado |
| **`setup-databases.ps1`** | Crea bases de datos faltantes | Si ves errores de "database does not exist" |
| **`test-connectivity.ps1`** | Verifica conectividad de red | Si ves errores de conexión o sockets |

### 📚 Documentación

| Documento | Descripción |
|-----------|-------------|
| **`QUICK-START.md`** | Guía rápida - comandos esenciales |
| **`TESTING-GUIDE.md`** | Guía completa - todos los tests detallados |
| **`README-DIAGNOSTICS.md`** | Este archivo |

### 🐧 Scripts de Bash (Linux/Mac)

| Script | Descripción |
|--------|-------------|
| **`diagnostics.sh`** | Versión Bash del diagnóstico completo |

---

## 🎯 Flujo de Trabajo Recomendado

### 1️⃣ Primera Vez / Problemas Generales

```powershell
# Paso 1: Ejecutar diagnóstico completo
cd "c:\Jobapp final\jobapp-full\jobber-k8s\minikube"
.\diagnostics.ps1
```

Este script te mostrará:
- ✅ Estado de todos los pods
- 💾 Estado de todas las bases de datos
- 🔑 Verificación de secrets
- 📋 Logs de pods con errores
- 🔍 Eventos recientes

**Lee el output cuidadosamente** - te dirá exactamente qué está mal.

---

### 2️⃣ Si Faltan Bases de Datos

Si ves errores como:
- ❌ "Database 'jobber_auth' does not exist"
- ❌ "Database 'jobber' not found"
- ❌ MongoDB collections missing

```powershell
.\setup-databases.ps1
```

Este script:
- Crea `jobber_auth`, `jobber_reviews`, `jobber_orders` en MySQL
- Crea base de datos `jobber` en PostgreSQL
- Inicializa MongoDB con la base `jobber`
- Verifica que todo se creó correctamente

**Después, reinicia los servicios afectados:**
```powershell
kubectl rollout restart deployment/jobber-auth -n production
kubectl rollout restart deployment/jobber-gig -n production
kubectl rollout restart deployment/jobber-users -n production
```

---

### 3️⃣ Si Hay Problemas de Conexión/Sockets

Si ves errores como:
- ❌ "Cannot connect to Redis"
- ❌ "ECONNREFUSED"
- ❌ "Connection timeout"
- ❌ "Socket hang up"
- ❌ "RabbitMQ connection failed"

```powershell
.\test-connectivity.ps1
```

Este script verifica:
- 🌐 DNS interno de Kubernetes
- 🔌 Conectividad de cada servicio a sus dependencias
- 📊 Endpoints y servicios de Kubernetes

**Qué hacer según el resultado:**

#### ✅ Todo en verde pero aún hay errores
- El problema es en la configuración de la app, no en la red
- Revisa las variables de entorno y secrets
- Verifica los logs del servicio específico

#### ❌ Fallan varios tests
- Los pods pueden no estar corriendo
- Ejecuta: `kubectl get pods -n production`
- Reinicia los pods con problemas

#### ⚠️ "Pod no encontrado"
- El servicio no está desplegado
- Verifica: `kubectl get deployments -n production`
- Aplica los manifiestos faltantes

---

## 📖 Guías de Referencia

### Para Comenzar Rápido
👉 **`QUICK-START.md`**
- Comandos más importantes
- Troubleshooting rápido
- Checklist de verificación

### Para Diagnóstico Detallado
👉 **`TESTING-GUIDE.md`**
- Tests manuales por componente
- Troubleshooting exhaustivo
- Comandos de referencia completos

---

## 🔍 Comandos Esenciales

### Ver Estado General
```powershell
kubectl get pods -n production
kubectl get svc -n production
kubectl get events -n production --sort-by='.lastTimestamp' | Select-Object -Last 10
```

### Ver Logs de un Servicio
```powershell
# Logs en tiempo real
kubectl logs -f -n production deployment/jobber-gateway

# Últimas 50 líneas
kubectl logs -n production deployment/jobber-gateway --tail=50

# Si el pod crasheó (ver log anterior)
kubectl logs -n production <pod-name> --previous
```

### Reiniciar un Servicio
```powershell
kubectl rollout restart deployment/jobber-gateway -n production
```

### Acceder a una Base de Datos
```powershell
# MySQL
kubectl exec -it -n production deployment/jobber-mysql -- mysql -uroot -papi

# PostgreSQL
kubectl exec -it -n production deployment/jobber-postgres -- psql -U jobber

# MongoDB
kubectl exec -it -n production deployment/jobber-mongodb -- mongosh

# Redis
kubectl exec -it -n production deployment/jobber-redis -- redis-cli -a thisisismyownpassword123@
```

---

## 🚨 Problemas Comunes

### Pod en CrashLoopBackOff

**Causa**: El servicio inicia y crashea repetidamente

**Solución**:
```powershell
# Ver por qué crashea
kubectl logs -n production <pod-name> --previous

# Ver detalles del pod
kubectl describe pod -n production <pod-name>

# Verificar variables de entorno
kubectl exec -n production <pod-name> -- env

# Si es problema de configuración, actualiza y reinicia
kubectl apply -f <archivo-modificado>.yaml
kubectl rollout restart deployment/<nombre> -n production
```

---

### Base de Datos No Existe

**Causa**: El servicio espera una base de datos que no fue creada

**Solución**:
```powershell
# Opción 1: Usar el script automático
.\setup-databases.ps1

# Opción 2: Crear manualmente (MySQL)
kubectl exec -n production deployment/jobber-mysql -- mysql -uroot -papi -e "CREATE DATABASE jobber_auth;"

# Opción 3: Crear manualmente (PostgreSQL)
kubectl exec -n production deployment/jobber-postgres -- psql -U jobber -c "CREATE DATABASE jobber;"

# Después, reiniciar el servicio
kubectl rollout restart deployment/<servicio-afectado> -n production
```

---

### Error de Conexión (ECONNREFUSED, timeout, etc.)

**Causa**: El servicio no puede conectarse a su dependencia

**Diagnóstico**:
```powershell
# 1. Verificar conectividad
.\test-connectivity.ps1

# 2. Verificar que la dependencia esté corriendo
kubectl get pods -n production -l app=jobber-redis

# 3. Verificar DNS
kubectl run test-dns --image=busybox --rm -it -n production -- nslookup jobber-redis.production.svc.cluster.local

# 4. Verificar variables de entorno del servicio
kubectl exec -n production deployment/jobber-gateway -- env | Select-String "REDIS|MYSQL|POSTGRES|MONGO|ELASTIC|RABBIT"
```

**Solución**:
```powershell
# Si la dependencia no está corriendo
kubectl rollout restart deployment/jobber-redis -n production

# Si las variables de entorno son incorrectas
kubectl apply -f jobber-secrets/backend-secrets.yaml
kubectl rollout restart deployment/<servicio> -n production

# Si el servicio no existe
kubectl apply -f jobber-redis/

# Esperar a que esté listo
kubectl wait --for=condition=ready pod -l app=jobber-redis -n production --timeout=180s
```

---

### ConfigMap No Se Actualiza

**Causa**: Kubernetes no refresca automáticamente los ConfigMaps en pods corriendo

**Solución**:
```powershell
# 1. Aplicar el ConfigMap actualizado
kubectl apply -f jobber-kibana/configMap.yaml

# 2. IMPORTANTE: Reiniciar el deployment
kubectl rollout restart deployment/jobber-kibana -n production

# 3. Esperar a que el nuevo pod esté listo
kubectl wait --for=condition=ready pod -l app=jobber-kibana -n production --timeout=180s

# 4. Verificar que se aplicó
kubectl get configmap kibana-config -n production -o yaml
```

---

### Secrets No Cargados

**Causa**: Los secrets no existen o no están montados correctamente

**Diagnóstico**:
```powershell
# Verificar que existe
kubectl get secret jobber-backend-secret -n production

# Ver qué claves tiene
kubectl get secret jobber-backend-secret -n production -o jsonpath='{.data}' | ConvertFrom-Json | Format-List

# Ver un valor específico (decodificado)
kubectl get secret jobber-backend-secret -n production -o jsonpath='{.data.jobber-mysql-password}' | ForEach-Object { [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($_)) }
```

**Solución**:
```powershell
# Re-aplicar secrets
kubectl apply -f jobber-secrets/backend-secrets.yaml

# Reiniciar todos los pods que usan el secret
kubectl rollout restart deployment -n production --all
```

---

## 💡 Tips y Mejores Prácticas

### 1. Mantén una Terminal de Monitoreo
```powershell
# En una terminal separada, deja esto corriendo
kubectl get pods -n production -w
```
Te permite ver cambios en tiempo real.

### 2. Usa Aliases para Comandos Comunes
```powershell
# Agregar a tu perfil de PowerShell
Set-Alias k kubectl
function kgp { kubectl get pods -n production }
function klogs { param($service) kubectl logs -f -n production deployment/$service }
```

### 3. Port Forwarding para Debugging
```powershell
# Acceder a servicios desde tu máquina
kubectl port-forward -n production deployment/jobber-kibana 5601:5601
kubectl port-forward -n production deployment/jobber-gateway 4000:4000

# Luego abre: http://localhost:5601 o http://localhost:4000
```

### 4. Orden de Verificación
Siempre verifica en este orden:
1. **Infraestructura** (bases de datos, Redis, RabbitMQ, Elasticsearch)
2. **Secrets y ConfigMaps**
3. **Servicios backend** (Gateway, Auth, etc.)
4. **Conectividad** end-to-end

### 5. Antes de Reiniciar Todo
```powershell
# Guarda los logs actuales por si acaso
kubectl logs -n production deployment/jobber-gateway > gateway-logs-$(Get-Date -Format 'yyyyMMdd-HHmmss').txt
kubectl logs -n production deployment/jobber-auth > auth-logs-$(Get-Date -Format 'yyyyMMdd-HHmmss').txt
```

---

## 🔄 Flujo de Troubleshooting Completo

```
1. .\diagnostics.ps1
   ↓
2. ¿Hay bases de datos faltantes?
   → Sí: .\setup-databases.ps1
   → No: Continuar
   ↓
3. ¿Hay errores de conexión?
   → Sí: .\test-connectivity.ps1
   → No: Continuar
   ↓
4. ¿Pods en CrashLoopBackOff?
   → Sí: kubectl logs <pod> --previous
   → No: Continuar
   ↓
5. ¿ConfigMaps actualizados?
   → No: kubectl apply -f ... && kubectl rollout restart ...
   → Sí: Continuar
   ↓
6. ¿Secrets correctos?
   → No: kubectl apply -f jobber-secrets/ && restart pods
   → Sí: Continuar
   ↓
7. Verificación manual según TESTING-GUIDE.md
```

---

## 📞 Comandos de Emergencia

### Reiniciar TODO el Sistema
```powershell
kubectl rollout restart deployment -n production --all
```

### Eliminar y Recrear Namespace (⚠️ CUIDADO - Borra todo)
```powershell
kubectl delete namespace production
kubectl create namespace production
# Luego re-aplica todos los manifiestos
```

### Ver Logs de Todos los Servicios
```powershell
$services = @("gateway", "auth", "users", "gig", "chat", "order", "reviews", "notification")
foreach ($s in $services) {
    Write-Host "=== $s ===" -ForegroundColor Cyan
    kubectl logs -n production deployment/jobber-$s --tail=10
}
```

### Ejecutar Shell en un Pod
```powershell
kubectl exec -it -n production deployment/jobber-gateway -- sh
# O bash si está disponible
kubectl exec -it -n production deployment/jobber-gateway -- bash
```

---

## 📊 Verificación Final (Checklist)

Ejecuta estos comandos para verificar que todo está OK:

```powershell
# 1. Todos los pods corriendo
kubectl get pods -n production | Select-String -NotMatch "Running|Completed"
# Debería estar vacío (sin resultados)

# 2. Bases de datos respondiendo
kubectl exec -n production deployment/jobber-mysql -- mysql -uroot -papi -e "SELECT 1;"
kubectl exec -n production deployment/jobber-postgres -- psql -U jobber -c "SELECT 1;"
kubectl exec -n production deployment/jobber-mongodb -- mongosh --eval "db.adminCommand('ping')" --quiet
kubectl exec -n production deployment/jobber-redis -- redis-cli -a thisisismyownpassword123@ ping
kubectl exec -n production deployment/jobber-elastic -- curl -s -u elastic:admin1234 http://localhost:9200

# 3. Sin eventos de error recientes
kubectl get events -n production --field-selector type=Warning --sort-by='.lastTimestamp' | Select-Object -Last 5

# 4. Todos los servicios tienen endpoints
kubectl get endpoints -n production | Select-String -Pattern "none"
# Debería estar vacío (sin "none")
```

Si todos estos tests pasan, tu sistema está funcionando correctamente! ✅

---

**Última actualización**: Octubre 2025
**Mantenido por**: Equipo Jobber DevOps








