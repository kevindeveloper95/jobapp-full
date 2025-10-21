#!/bin/bash
# Script de diagnóstico completo para Jobber Microservices
# Ejecutar: bash diagnostics.sh

echo "========================================"
echo "🔍 DIAGNÓSTICO COMPLETO - JOBBER SYSTEM"
echo "========================================"
echo ""

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Namespace
NAMESPACE="production"

echo "📦 1. VERIFICANDO ESTADO DE TODOS LOS PODS"
echo "----------------------------------------"
kubectl get pods -n $NAMESPACE -o wide
echo ""

echo "🔴 2. PODS CON PROBLEMAS (CrashLoopBackOff, Error, Pending)"
echo "----------------------------------------"
kubectl get pods -n $NAMESPACE | grep -E 'CrashLoop|Error|Pending|ImagePull' || echo "✅ No hay pods con errores críticos"
echo ""

echo "💾 3. VERIFICANDO BASES DE DATOS"
echo "----------------------------------------"

# MongoDB
echo "▶ MongoDB:"
kubectl exec -n $NAMESPACE deployment/jobber-mongodb -- mongosh --eval "db.adminCommand('ping')" --quiet 2>/dev/null && echo "  ✅ MongoDB respondiendo" || echo "  ❌ MongoDB no responde"

# MySQL
echo "▶ MySQL:"
kubectl exec -n $NAMESPACE deployment/jobber-mysql -- mysql -uroot -papi -e "SELECT 1;" 2>/dev/null && echo "  ✅ MySQL respondiendo" || echo "  ❌ MySQL no responde"

# PostgreSQL
echo "▶ PostgreSQL:"
kubectl exec -n $NAMESPACE deployment/jobber-postgres -- psql -U jobber -c "SELECT 1;" 2>/dev/null && echo "  ✅ PostgreSQL respondiendo" || echo "  ❌ PostgreSQL no responde"

# Elasticsearch
echo "▶ Elasticsearch:"
kubectl exec -n $NAMESPACE deployment/jobber-elastic -- curl -s -u elastic:admin1234 http://localhost:9200/_cluster/health 2>/dev/null | grep -q "status" && echo "  ✅ Elasticsearch respondiendo" || echo "  ❌ Elasticsearch no responde"

# Redis
echo "▶ Redis:"
kubectl exec -n $NAMESPACE deployment/jobber-redis -- redis-cli -a thisisismyownpassword123@ ping 2>/dev/null && echo "  ✅ Redis respondiendo" || echo "  ❌ Redis no responde"

# RabbitMQ
echo "▶ RabbitMQ:"
kubectl exec -n $NAMESPACE deployment/jobber-queue -- rabbitmqctl status 2>/dev/null | grep -q "RabbitMQ" && echo "  ✅ RabbitMQ respondiendo" || echo "  ❌ RabbitMQ no responde"

echo ""

echo "🗄️ 4. VERIFICANDO BASES DE DATOS ESPECÍFICAS"
echo "----------------------------------------"

# MySQL - Verificar base de datos jobber_auth
echo "▶ MySQL - Base de datos 'jobber_auth':"
kubectl exec -n $NAMESPACE deployment/jobber-mysql -- mysql -uroot -papi -e "SHOW DATABASES;" 2>/dev/null | grep -q "jobber_auth" && echo "  ✅ Base de datos 'jobber_auth' existe" || echo "  ❌ Base de datos 'jobber_auth' NO existe"

# PostgreSQL - Verificar tablas
echo "▶ PostgreSQL - Tablas:"
kubectl exec -n $NAMESPACE deployment/jobber-postgres -- psql -U jobber -c "\dt" 2>/dev/null | grep -q "table" && echo "  ✅ PostgreSQL tiene tablas" || echo "  ⚠️  PostgreSQL no tiene tablas (puede ser normal si no se han creado)"

# MongoDB - Verificar colecciones
echo "▶ MongoDB - Colecciones:"
kubectl exec -n $NAMESPACE deployment/jobber-mongodb -- mongosh jobber --eval "db.getCollectionNames()" --quiet 2>/dev/null && echo "  ✅ MongoDB tiene colecciones" || echo "  ⚠️  MongoDB sin colecciones (puede ser normal si no se han creado)"

echo ""

echo "🌐 5. VERIFICANDO SERVICIOS (DNS INTERNO)"
echo "----------------------------------------"
for service in jobber-redis jobber-mysql jobber-postgres jobber-mongodb jobber-elastic jobber-queue; do
    echo "▶ Resolviendo DNS: $service.$NAMESPACE.svc.cluster.local"
    kubectl run test-dns-$service --image=busybox --rm -it --restart=Never -n $NAMESPACE -- nslookup $service.$NAMESPACE.svc.cluster.local 2>/dev/null && echo "  ✅ DNS OK" || echo "  ❌ DNS fallo"
done
echo ""

echo "🔌 6. VERIFICANDO CONECTIVIDAD DE RED"
echo "----------------------------------------"

# Test conectividad desde gateway a otros servicios
echo "▶ Conectividad desde Gateway:"
GATEWAY_POD=$(kubectl get pod -n $NAMESPACE -l app=jobber-gateway -o jsonpath="{.items[0].metadata.name}")
if [ ! -z "$GATEWAY_POD" ]; then
    echo "  Testing desde pod: $GATEWAY_POD"
    # Redis
    kubectl exec -n $NAMESPACE $GATEWAY_POD -- nc -zv jobber-redis.production.svc.cluster.local 6379 2>&1 | grep -q "open" && echo "    ✅ Redis (6379) alcanzable" || echo "    ❌ Redis (6379) NO alcanzable"
    # RabbitMQ
    kubectl exec -n $NAMESPACE $GATEWAY_POD -- nc -zv jobber-queue.production.svc.cluster.local 5672 2>&1 | grep -q "open" && echo "    ✅ RabbitMQ (5672) alcanzable" || echo "    ❌ RabbitMQ (5672) NO alcanzable"
    # Elasticsearch
    kubectl exec -n $NAMESPACE $GATEWAY_POD -- nc -zv jobber-elastic.production.svc.cluster.local 9200 2>&1 | grep -q "open" && echo "    ✅ Elasticsearch (9200) alcanzable" || echo "    ❌ Elasticsearch (9200) NO alcanzable"
else
    echo "  ⚠️  Gateway pod no encontrado"
fi

echo ""

echo "🔑 7. VERIFICANDO SECRETS"
echo "----------------------------------------"
kubectl get secret jobber-backend-secret -n $NAMESPACE &>/dev/null && echo "✅ Secret 'jobber-backend-secret' existe" || echo "❌ Secret 'jobber-backend-secret' NO existe"
echo ""

echo "📋 8. LOGS DE PODS CON ERRORES (últimas 20 líneas)"
echo "----------------------------------------"
for pod in $(kubectl get pods -n $NAMESPACE --no-headers | grep -E 'CrashLoop|Error|ImagePull' | awk '{print $1}'); do
    echo "▶ Logs del pod: $pod"
    kubectl logs --tail=20 -n $NAMESPACE $pod 2>&1 | head -20
    echo "---"
done

echo ""

echo "🔍 9. EVENTOS RECIENTES DEL NAMESPACE"
echo "----------------------------------------"
kubectl get events -n $NAMESPACE --sort-by='.lastTimestamp' | tail -20
echo ""

echo "📊 10. RECURSOS (CPU/MEMORIA)"
echo "----------------------------------------"
kubectl top pods -n $NAMESPACE 2>/dev/null || echo "⚠️  Metrics server no disponible (ejecuta: minikube addons enable metrics-server)"
echo ""

echo "========================================"
echo "✅ DIAGNÓSTICO COMPLETADO"
echo "========================================"








