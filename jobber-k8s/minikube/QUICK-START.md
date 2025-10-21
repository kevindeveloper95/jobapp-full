# 🚀 Quick Start - Diagnóstico Inmediato

## 1️⃣ Ejecuta el Diagnóstico Completo

```powershell
cd "c:\Jobapp final\jobapp-full\jobber-k8s\minikube"
.\diagnostics.ps1
```

Este script te mostrará:
- ✅ Qué está funcionando
- ❌ Qué tiene errores
- 📋 Logs de servicios con problemas

---

## 2️⃣ Si hay Bases de Datos Faltantes

```powershell
.\setup-databases.ps1
```

Esto creará todas las bases de datos necesarias.

---

## 3️⃣ Arreglar ConfigMap de Kibana (SI TODAVÍA TIENE CREDENCIALES)

```powershell
# Aplicar el ConfigMap correcto (sin credenciales)
kubectl apply -f jobber-kibana/configMap.yaml

# IMPORTANTE: Reiniciar Kibana para que tome los cambios
kubectl rollout restart deployment/jobber-kibana -n production

# Esperar a que el nuevo pod esté listo
kubectl wait --for=condition=ready pod -l app=jobber-kibana -n production --timeout=300s

# Verificar que ya no tiene credenciales en texto plano
kubectl get configmap kibana-config -n production -o yaml
```

---

## 4️⃣ Verificar Problemas Específicos

### 🔴 Gateway no se conecta a Redis/RabbitMQ

```powershell
# Ver logs del gateway
kubectl logs -n production deployment/jobber-gateway --tail=50

# Verificar que Redis está corriendo
kubectl get pods -n production -l app=jobber-redis

# Test de conectividad desde gateway a Redis
kubectl exec -n production deployment/jobber-gateway -- nc -zv jobber-redis.production.svc.cluster.local 6379
```

**Si falla**: Redis no está corriendo o el DNS no resuelve
```powershell
# Reiniciar Redis
kubectl rollout restart deployment/jobber-redis -n production

# Esperar 30 segundos y probar de nuevo
```

### 🗄️ Servicios no encuentran su base de datos

```powershell
# Auth Service → MySQL
kubectl logs -n production deployment/jobber-auth --tail=30
kubectl exec -n production deployment/jobber-mysql -- mysql -uroot -papi -e "SHOW DATABASES;"

# Si no existe jobber_auth:
kubectl exec -n production deployment/jobber-mysql -- mysql -uroot -papi -e "CREATE DATABASE IF NOT EXISTS jobber_auth;"
kubectl rollout restart deployment/jobber-auth -n production
```

```powershell
# Gig Service → PostgreSQL  
kubectl logs -n production deployment/jobber-gig --tail=30
kubectl exec -n production deployment/jobber-postgres -- psql -U jobber -l

# Si no existe la base de datos jobber:
kubectl exec -n production deployment/jobber-postgres -- psql -U jobber -c "CREATE DATABASE jobber;"
kubectl rollout restart deployment/jobber-gig -n production
```

```powershell
# Users/Order Services → MongoDB
kubectl logs -n production deployment/jobber-users --tail=30
kubectl exec -n production deployment/jobber-mongodb -- mongosh --eval "show dbs"
```

---

## 5️⃣ Ver Estado de Todos los Pods

```powershell
kubectl get pods -n production -o wide
```

### Estados Normales:
- ✅ `Running` - Todo bien
- ✅ `Completed` - Jobs que terminaron (normal)

### Estados con Problemas:
- ❌ `CrashLoopBackOff` - El servicio crashea constantemente
- ❌ `Error` - Falló al iniciar
- ❌ `ImagePullBackOff` - No puede descargar la imagen
- ⚠️ `Pending` - Esperando recursos

### Para pods con problemas:

```powershell
# Ver por qué crashea
kubectl logs -n production <pod-name> --previous

# Ver eventos del pod
kubectl describe pod -n production <pod-name>

# Reiniciar el deployment
kubectl rollout restart deployment/<deployment-name> -n production
```

---

## 6️⃣ Comandos para Servicios Específicos

### Gateway
```powershell
kubectl logs -f -n production deployment/jobber-gateway
kubectl exec -n production deployment/jobber-gateway -- env | Select-String "REDIS|ELASTIC|RABBIT"
```

### Auth
```powershell
kubectl logs -f -n production deployment/jobber-auth
kubectl exec -n production deployment/jobber-auth -- nc -zv jobber-mysql.production.svc.cluster.local 3306
```

### Elasticsearch
```powershell
kubectl logs -f -n production deployment/jobber-elastic
kubectl exec -n production deployment/jobber-elastic -- curl -s -u elastic:admin1234 http://localhost:9200/_cluster/health?pretty
```

### Kibana
```powershell
kubectl logs -f -n production deployment/jobber-kibana
kubectl port-forward -n production deployment/jobber-kibana 5601:5601
# Abre: http://localhost:5601
```

---

## 7️⃣ Comandos de Emergencia

### Reiniciar TODO
```powershell
kubectl rollout restart deployment -n production --all
```

### Eliminar y recrear un pod específico
```powershell
kubectl delete pod <pod-name> -n production
# Se recrea automáticamente
```

### Ver eventos recientes (errores)
```powershell
kubectl get events -n production --sort-by='.lastTimestamp' | Select-Object -Last 20
```

### Verificar secrets
```powershell
kubectl get secret jobber-backend-secret -n production
kubectl get secret jobber-backend-secret -n production -o jsonpath='{.data}' | ConvertFrom-Json | Format-List
```

---

## 8️⃣ Acceder a Servicios Localmente (Port Forward)

```powershell
# Kibana
kubectl port-forward -n production deployment/jobber-kibana 5601:5601

# Gateway API
kubectl port-forward -n production deployment/jobber-gateway 4000:4000

# Elasticsearch
kubectl port-forward -n production deployment/jobber-elastic 9200:9200

# RabbitMQ Management UI
kubectl port-forward -n production deployment/jobber-queue 15672:15672

# MySQL
kubectl port-forward -n production deployment/jobber-mysql 3306:3306

# PostgreSQL
kubectl port-forward -n production deployment/jobber-postgres 5432:5432

# MongoDB
kubectl port-forward -n production deployment/jobber-mongodb 27017:27017

# Redis
kubectl port-forward -n production deployment/jobber-redis 6379:6379
```

Luego conéctate desde tu máquina local con cualquier cliente.

---

## 9️⃣ Verificar Todo Está Aplicado

```powershell
# Secrets
kubectl apply -f jobber-secrets/backend-secrets.yaml

# Todos los servicios de bases de datos
kubectl apply -f jobber-elasticsearch/
kubectl apply -f jobber-kibana/
kubectl apply -f jobber-mysql/
kubectl apply -f jobber-postgresql/
kubectl apply -f jobber-mongodb/
kubectl apply -f jobber-redis/
kubectl apply -f jobber-queue/

# Servicios de aplicación
kubectl apply -f 1-gateway/
kubectl apply -f 2-notifications/
kubectl apply -f 3-auth/
kubectl apply -f 4-users/
kubectl apply -f 5-gig/
kubectl apply -f 6-chat/
kubectl apply -f 7-order/
kubectl apply -f 8-reviews/

# Reiniciar todo para tomar cambios
kubectl rollout restart deployment -n production --all
```

---

## 🎯 Checklist de Verificación Rápida

Ejecuta estos comandos en orden:

```powershell
# 1. ¿Todos los pods corriendo?
kubectl get pods -n production

# 2. ¿Algún error reciente?
kubectl get events -n production --sort-by='.lastTimestamp' | Select-Object -Last 10

# 3. ¿MySQL funciona?
kubectl exec -n production deployment/jobber-mysql -- mysql -uroot -papi -e "SHOW DATABASES;"

# 4. ¿PostgreSQL funciona?
kubectl exec -n production deployment/jobber-postgres -- psql -U jobber -l

# 5. ¿MongoDB funciona?
kubectl exec -n production deployment/jobber-mongodb -- mongosh --eval "db.adminCommand('ping')"

# 6. ¿Redis funciona?
kubectl exec -n production deployment/jobber-redis -- redis-cli -a thisisismyownpassword123@ ping

# 7. ¿Elasticsearch funciona?
kubectl exec -n production deployment/jobber-elastic -- curl -s -u elastic:admin1234 http://localhost:9200/_cluster/health

# 8. ¿RabbitMQ funciona?
kubectl exec -n production deployment/jobber-queue -- rabbitmqctl status

# 9. ¿Gateway tiene logs de error?
kubectl logs -n production deployment/jobber-gateway --tail=20

# 10. ¿Todos los servicios tienen endpoints?
kubectl get endpoints -n production
```

---

## 💡 Próximos Pasos

1. **Ejecuta**: `.\diagnostics.ps1`
2. **Lee** los errores que encuentre
3. **Consulta**: `TESTING-GUIDE.md` para soluciones específicas
4. **Arregla** los problemas encontrados
5. **Reinicia** los servicios afectados
6. **Verifica** de nuevo con el diagnóstico

---

## 📚 Documentación Completa

Para tests más detallados, consulta: `TESTING-GUIDE.md`

---

**Tip**: Mantén una terminal con `kubectl get pods -n production -w` corriendo para ver cambios en tiempo real.








