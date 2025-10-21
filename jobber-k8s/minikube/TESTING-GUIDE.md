# 🧪 Guía Completa de Testing - Jobber Microservices

## 📋 Índice
1. [Scripts Automáticos](#scripts-automáticos)
2. [Tests Manuales por Componente](#tests-manuales-por-componente)
3. [Troubleshooting Común](#troubleshooting-común)
4. [Verificación de Conectividad](#verificación-de-conectividad)

---

## 🚀 Scripts Automáticos

### 1. Diagnóstico Completo
```powershell
cd jobber-k8s/minikube
.\diagnostics.ps1
```
Este script verifica:
- Estado de todos los pods
- Conectividad de bases de datos
- Servicios de red
- Secrets y ConfigMaps
- Logs de errores

### 2. Configuración de Bases de Datos
```powershell
.\setup-databases.ps1
```
Crea todas las bases de datos necesarias si no existen.

---

## 🔍 Tests Manuales por Componente

### 📦 1. VERIFICAR ESTADO GENERAL

```powershell
# Ver todos los pods
kubectl get pods -n production

# Ver servicios
kubectl get svc -n production

# Ver eventos recientes
kubectl get events -n production --sort-by='.lastTimestamp' | Select-Object -Last 20
```

**Resultado Esperado:**
- Todos los pods en estado `Running`
- Restarts en `0` o muy pocos
- No debe haber eventos de error recientes

---

### 💾 2. BASES DE DATOS

#### 🗃️ MySQL (Auth Service)

```powershell
# Conectarse a MySQL
kubectl exec -it -n production deployment/jobber-mysql -- mysql -uroot -papi

# Dentro de MySQL:
SHOW DATABASES;
USE jobber_auth;
SHOW TABLES;
EXIT;
```

**Verificar:**
- ✅ Base de datos `jobber_auth` existe
- ✅ Tablas de autenticación creadas (users, etc.)
- ❌ Si no existe: ejecutar `setup-databases.ps1`

#### 🗃️ PostgreSQL (Gig, Chat Services)

```powershell
# Conectarse a PostgreSQL
kubectl exec -it -n production deployment/jobber-postgres -- psql -U jobber

# Dentro de psql:
\l                    # Listar bases de datos
\c jobber            # Conectar a jobber
\dt                  # Listar tablas
\q                   # Salir
```

**Verificar:**
- ✅ Base de datos `jobber` existe
- ✅ Tablas de gigs, chats creadas
- ❌ Si falla: Revisar logs del servicio PostgreSQL

#### 🗃️ MongoDB (User, Order Services)

```powershell
# Conectarse a MongoDB
kubectl exec -it -n production deployment/jobber-mongodb -- mongosh

# Dentro de mongosh:
show dbs
use jobber
show collections
exit
```

**Verificar:**
- ✅ Base de datos `jobber` existe
- ✅ Colecciones creadas (users, orders, etc.)
- ⚠️ Es normal que esté vacía si es la primera vez

---

### 🔍 3. ELASTICSEARCH & KIBANA

#### Elasticsearch

```powershell
# Health check
kubectl exec -n production deployment/jobber-elastic -- curl -u elastic:admin1234 http://localhost:9200/_cluster/health?pretty

# Ver índices
kubectl exec -n production deployment/jobber-elastic -- curl -u elastic:admin1234 http://localhost:9200/_cat/indices?v

# Verificar usuario kibana_system
kubectl exec -n production deployment/jobber-elastic -- curl -u elastic:admin1234 -X GET "http://localhost:9200/_security/user/kibana_system?pretty"
```

**Verificar:**
- ✅ Status: `green` o `yellow` (yellow es OK para desarrollo)
- ✅ Usuario `kibana_system` existe
- ❌ Si status es `red`: hay problema con los nodos

#### Kibana

```powershell
# Ver logs de Kibana
kubectl logs -f -n production deployment/jobber-kibana

# Port forward para acceder localmente
kubectl port-forward -n production deployment/jobber-kibana 5601:5601
```

Luego abre: http://localhost:5601

**Verificar:**
- ✅ Kibana carga sin errores
- ✅ Puedes hacer login (si está configurado)
- ❌ Error de autenticación: Revisar secrets y variables de entorno

---

### 🔴 4. REDIS

```powershell
# Ping test
kubectl exec -n production deployment/jobber-redis -- redis-cli -a thisisismyownpassword123@ ping

# Info del servidor
kubectl exec -n production deployment/jobber-redis -- redis-cli -a thisisismyownpassword123@ info server

# Ver keys (si hay)
kubectl exec -n production deployment/jobber-redis -- redis-cli -a thisisismyownpassword123@ keys "*"
```

**Verificar:**
- ✅ Responde `PONG`
- ✅ Versión de Redis mostrada
- ⚠️ Keys vacías es normal si no hay sesiones activas

---

### 🐰 5. RABBITMQ

```powershell
# Status de RabbitMQ
kubectl exec -n production deployment/jobber-queue -- rabbitmqctl status

# Ver colas
kubectl exec -n production deployment/jobber-queue -- rabbitmqctl list_queues

# Ver conexiones activas
kubectl exec -n production deployment/jobber-queue -- rabbitmqctl list_connections

# Port forward para acceder al management UI
kubectl port-forward -n production deployment/jobber-queue 15672:15672
```

Abre: http://localhost:15672 (user: jobber, pass: jobberpass)

**Verificar:**
- ✅ RabbitMQ está corriendo
- ✅ Colas creadas por los microservicios
- ✅ Conexiones activas de los servicios
- ❌ Sin colas: Los servicios no se han conectado aún

---

### 🌐 6. GATEWAY SERVICE

```powershell
# Ver logs en tiempo real
kubectl logs -f -n production deployment/jobber-gateway

# Ver últimas 50 líneas
kubectl logs -n production deployment/jobber-gateway --tail=50

# Verificar variables de entorno
kubectl exec -n production deployment/jobber-gateway -- env | grep -E "REDIS|RABBITMQ|ELASTICSEARCH"
```

**Errores Comunes y Soluciones:**

#### ❌ "Cannot connect to Redis"
```powershell
# Verificar que Redis está corriendo
kubectl get pods -n production -l app=jobber-redis

# Test de conectividad desde gateway
kubectl exec -n production deployment/jobber-gateway -- nc -zv jobber-redis.production.svc.cluster.local 6379
```

#### ❌ "RabbitMQ connection refused"
```powershell
# Verificar RabbitMQ
kubectl get pods -n production -l app=jobber-queue

# Verificar secret de RabbitMQ
kubectl get secret jobber-backend-secret -n production -o jsonpath='{.data.jobber-rabbitmq-endpoint}' | base64 -d
echo ""
```

#### ❌ "Elasticsearch timeout"
```powershell
# Verificar Elasticsearch
kubectl exec -n production deployment/jobber-elastic -- curl -s http://localhost:9200

# Test desde gateway
kubectl exec -n production deployment/jobber-gateway -- nc -zv jobber-elastic.production.svc.cluster.local 9200
```

---

### 🔐 7. AUTH SERVICE

```powershell
# Ver logs
kubectl logs -f -n production deployment/jobber-auth

# Verificar conexión a MySQL
kubectl exec -n production deployment/jobber-auth -- nc -zv jobber-mysql.production.svc.cluster.local 3306

# Ver variables de entorno
kubectl exec -n production deployment/jobber-auth -- env | grep MYSQL
```

**Test de Endpoint (requiere port-forward):**
```powershell
# Port forward del gateway
kubectl port-forward -n production deployment/jobber-gateway 4000:4000

# Test con curl o Postman
curl http://localhost:4000/auth-health
```

---

### 👥 8. USERS SERVICE

```powershell
# Ver logs
kubectl logs -f -n production deployment/jobber-users

# Verificar conexión a MongoDB
kubectl exec -n production deployment/jobber-users -- nc -zv jobber-mongodb.production.svc.cluster.local 27017
```

---

### 💼 9. GIG SERVICE

```powershell
# Ver logs
kubectl logs -f -n production deployment/jobber-gig

# Verificar conexión a PostgreSQL
kubectl exec -n production deployment/jobber-gig -- nc -zv jobber-postgres.production.svc.cluster.local 5432
```

---

### 💬 10. CHAT SERVICE

```powershell
# Ver logs
kubectl logs -f -n production deployment/jobber-chat

# Verificar WebSocket
kubectl logs -n production deployment/jobber-chat | grep -i "websocket\|socket"
```

---

### 📦 11. ORDER SERVICE

```powershell
# Ver logs
kubectl logs -f -n production deployment/jobber-order

# Verificar conexión a MongoDB
kubectl exec -n production deployment/jobber-order -- nc -zv jobber-mongodb.production.svc.cluster.local 27017
```

---

### ⭐ 12. REVIEW SERVICE

```powershell
# Ver logs
kubectl logs -f -n production deployment/jobber-reviews

# Verificar conexión a MySQL
kubectl exec -n production deployment/jobber-reviews -- nc -zv jobber-mysql.production.svc.cluster.local 3306
```

---

### 📧 13. NOTIFICATION SERVICE

```powershell
# Ver logs
kubectl logs -f -n production deployment/jobber-notification

# Verificar que escucha queues de RabbitMQ
kubectl logs -n production deployment/jobber-notification | grep -i "queue\|listening"
```

---

## 🔧 Verificación de Conectividad

### Test de DNS Interno

```powershell
# Crear un pod temporal de prueba
kubectl run test-dns --image=busybox --rm -it --restart=Never -n production -- sh

# Dentro del pod, probar DNS:
nslookup jobber-redis.production.svc.cluster.local
nslookup jobber-mysql.production.svc.cluster.local
nslookup jobber-postgres.production.svc.cluster.local
nslookup jobber-mongodb.production.svc.cluster.local
nslookup jobber-elastic.production.svc.cluster.local
nslookup jobber-queue.production.svc.cluster.local
exit
```

### Test de Conectividad de Red

```powershell
# Desde cualquier pod de servicio al gateway
kubectl exec -n production deployment/jobber-auth -- nc -zv jobber-gateway.production.svc.cluster.local 4000

# Gateway a bases de datos
kubectl exec -n production deployment/jobber-gateway -- nc -zv jobber-redis.production.svc.cluster.local 6379
kubectl exec -n production deployment/jobber-gateway -- nc -zv jobber-mysql.production.svc.cluster.local 3306
kubectl exec -n production deployment/jobber-gateway -- nc -zv jobber-postgres.production.svc.cluster.local 5432
```

---

## 🚨 Troubleshooting Común

### Pod en CrashLoopBackOff

```powershell
# Ver logs del pod que crashea
kubectl logs -n production <pod-name> --previous

# Describir el pod para ver eventos
kubectl describe pod -n production <pod-name>

# Reiniciar el deployment
kubectl rollout restart deployment/<deployment-name> -n production
```

### Base de datos no existe

```powershell
# Ejecutar script de setup
.\setup-databases.ps1

# O crear manualmente
kubectl exec -it -n production deployment/jobber-mysql -- mysql -uroot -papi -e "CREATE DATABASE IF NOT EXISTS jobber_auth;"
```

### Secrets no cargados

```powershell
# Verificar que existe
kubectl get secret jobber-backend-secret -n production

# Ver claves disponibles
kubectl get secret jobber-backend-secret -n production -o jsonpath='{.data}' | ConvertFrom-Json

# Re-aplicar secrets
kubectl apply -f jobber-secrets/backend-secrets.yaml

# Reiniciar pods que usan el secret
kubectl rollout restart deployment/<deployment-name> -n production
```

### ConfigMap no actualizado

```powershell
# Re-aplicar ConfigMap
kubectl apply -f jobber-kibana/configMap.yaml

# IMPORTANTE: Reiniciar el pod para que tome los cambios
kubectl rollout restart deployment/jobber-kibana -n production

# Verificar que se aplicó
kubectl get configmap kibana-config -n production -o yaml
```

### Service no accesible

```powershell
# Verificar endpoints
kubectl get endpoints -n production <service-name>

# Debe mostrar IPs de los pods. Si está vacío, hay problema con los labels.

# Verificar labels del service y deployment
kubectl get svc <service-name> -n production -o yaml | grep -A 3 selector
kubectl get pods -n production --show-labels | grep <service-name>
```

---

## ✅ Checklist Final

Usa este checklist para verificar que todo está funcionando:

### Infraestructura
- [ ] Minikube está corriendo (`minikube status`)
- [ ] Namespace `production` existe
- [ ] Todos los secrets aplicados
- [ ] Todos los ConfigMaps aplicados

### Bases de Datos
- [ ] MySQL corriendo y accesible
- [ ] PostgreSQL corriendo y accesible
- [ ] MongoDB corriendo y accesible
- [ ] Elasticsearch corriendo (status yellow o green)
- [ ] Redis respondiendo PONG
- [ ] RabbitMQ corriendo y con colas

### Servicios Backend
- [ ] Gateway sin errores de conexión
- [ ] Auth Service conectado a MySQL
- [ ] Users Service conectado a MongoDB
- [ ] Gig Service conectado a PostgreSQL
- [ ] Chat Service corriendo
- [ ] Order Service conectado a MongoDB
- [ ] Review Service conectado a MySQL
- [ ] Notification Service escuchando queues

### Conectividad
- [ ] DNS interno resuelve todos los servicios
- [ ] Servicios pueden conectarse a sus bases de datos
- [ ] Gateway puede alcanzar todos los microservicios
- [ ] RabbitMQ tiene conexiones activas

### Frontend
- [ ] Kibana accesible y sin errores de autenticación
- [ ] Cliente web puede conectarse al gateway (si aplica)

---

## 📞 Comandos Útiles de Referencia

```powershell
# Ver todos los recursos
kubectl get all -n production

# Describir un recurso específico
kubectl describe <resource-type> <resource-name> -n production

# Logs en tiempo real
kubectl logs -f -n production <pod-name>

# Logs anteriores (si el pod crasheó)
kubectl logs -n production <pod-name> --previous

# Ejecutar comando en pod
kubectl exec -it -n production <pod-name> -- <command>

# Port forward
kubectl port-forward -n production <pod-name> <local-port>:<pod-port>

# Reiniciar deployment
kubectl rollout restart deployment/<deployment-name> -n production

# Ver historial de rollout
kubectl rollout history deployment/<deployment-name> -n production

# Hacer rollback
kubectl rollout undo deployment/<deployment-name> -n production

# Escalar deployment
kubectl scale deployment/<deployment-name> --replicas=<number> -n production

# Eliminar pod (se recrea automáticamente)
kubectl delete pod <pod-name> -n production

# Aplicar todos los archivos de un directorio
kubectl apply -f <directory-path>/

# Ver uso de recursos (requiere metrics-server)
kubectl top pods -n production
kubectl top nodes
```

---

## 🎯 Orden Recomendado de Verificación

1. **Primero**: Bases de datos (MySQL, PostgreSQL, MongoDB, Redis, Elasticsearch, RabbitMQ)
2. **Segundo**: Secrets y ConfigMaps
3. **Tercero**: Servicios de infraestructura (Gateway, Notification)
4. **Cuarto**: Servicios de negocio (Auth, Users, Gig, Chat, Order, Review)
5. **Quinto**: Conectividad end-to-end
6. **Último**: Cliente frontend

---

**Nota**: Guarda este documento para referencia futura. Actualízalo según cambien tus configuraciones.








