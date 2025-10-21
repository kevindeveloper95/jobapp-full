# Script para crear y configurar bases de datos faltantes
# Ejecutar: .\setup-databases.ps1

$namespace = "production"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "CONFIGURACION DE BASES DE DATOS" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# 1. MySQL - Crear base de datos jobber_auth si no existe
Write-Host "1. CONFIGURANDO MYSQL" -ForegroundColor Yellow
Write-Host "----------------------------------------"

Write-Host "[INFO] Verificando y creando bases de datos en MySQL..."
$mysqlCommands = @"
CREATE DATABASE IF NOT EXISTS jobber_auth;
CREATE DATABASE IF NOT EXISTS jobber_reviews;
CREATE DATABASE IF NOT EXISTS jobber_orders;
SHOW DATABASES;
"@

kubectl exec -n $namespace deployment/jobber-mysql -- mysql -uroot -papi -e "$mysqlCommands" 2>&1

if ($LASTEXITCODE -eq 0) {
    Write-Host "[OK] Bases de datos MySQL configuradas correctamente" -ForegroundColor Green
} else {
    Write-Host "[ERROR] Error al configurar bases de datos MySQL" -ForegroundColor Red
}

Write-Host ""

# 2. PostgreSQL - Crear base de datos jobber si no existe
Write-Host "2. CONFIGURANDO POSTGRESQL" -ForegroundColor Yellow
Write-Host "----------------------------------------"

Write-Host "[INFO] Verificando base de datos 'jobber'..."
$pgCreateDB = kubectl exec -n $namespace deployment/jobber-postgres -- psql -U jobber -tc "SELECT 1 FROM pg_database WHERE datname='jobber'" 2>&1

if ($pgCreateDB -match "1") {
    Write-Host "[OK] Base de datos 'jobber' ya existe" -ForegroundColor Green
} else {
    Write-Host "[INFO] Creando base de datos 'jobber'..." -ForegroundColor Yellow
    kubectl exec -n $namespace deployment/jobber-postgres -- psql -U jobber -c "CREATE DATABASE jobber;" 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "[OK] Base de datos 'jobber' creada" -ForegroundColor Green
    } else {
        Write-Host "[ERROR] No se pudo crear la base de datos 'jobber'" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "[INFO] Tablas en PostgreSQL:"
kubectl exec -n $namespace deployment/jobber-postgres -- psql -U jobber -d jobber -c "\dt" 2>&1

Write-Host ""

# 3. MongoDB - Verificar conexión y colecciones
Write-Host "3. CONFIGURANDO MONGODB" -ForegroundColor Yellow
Write-Host "----------------------------------------"

Write-Host "[INFO] Verificando MongoDB y creando base de datos 'jobber'..."
$mongoCommands = @"
use jobber
db.createCollection('init')
show dbs
"@

kubectl exec -n $namespace deployment/jobber-mongodb -- mongosh --eval "$mongoCommands" 2>&1

if ($LASTEXITCODE -eq 0) {
    Write-Host "[OK] MongoDB configurado correctamente" -ForegroundColor Green
} else {
    Write-Host "[ERROR] Error al configurar MongoDB" -ForegroundColor Red
}

Write-Host ""

# 4. Elasticsearch - Verificar índices
Write-Host "4. VERIFICANDO ELASTICSEARCH" -ForegroundColor Yellow
Write-Host "----------------------------------------"

Write-Host "[INFO] Indices en Elasticsearch:"
kubectl exec -n $namespace deployment/jobber-elastic -- curl -s -u elastic:admin1234 http://localhost:9200/_cat/indices?v 2>&1

Write-Host ""

# 5. Redis - Verificar conexión
Write-Host "5. VERIFICANDO REDIS" -ForegroundColor Yellow
Write-Host "----------------------------------------"

Write-Host "[INFO] Info de Redis:"
kubectl exec -n $namespace deployment/jobber-redis -- redis-cli -a thisisismyownpassword123@ info server 2>&1 | Select-String -Pattern "redis_version|os"

Write-Host ""

# 6. RabbitMQ - Verificar queues
Write-Host "6. VERIFICANDO RABBITMQ" -ForegroundColor Yellow
Write-Host "----------------------------------------"

Write-Host "[INFO] Colas en RabbitMQ:"
kubectl exec -n $namespace deployment/jobber-queue -- rabbitmqctl list_queues 2>&1

Write-Host ""

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "CONFIGURACION COMPLETADA" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "NOTA:" -ForegroundColor Yellow
Write-Host "Las tablas especificas de cada microservicio se crearan automaticamente"
Write-Host "cuando los servicios se ejecuten por primera vez (si usan ORM con auto-migrations)."
Write-Host ""
Write-Host "Para verificar que todo funciona, ejecuta: .\diagnostics.ps1"
Write-Host ""
Write-Host "Si los servicios aun tienen errores, reinicialos:"
Write-Host "  kubectl rollout restart deployment/jobber-auth -n production"
Write-Host "  kubectl rollout restart deployment/jobber-gig -n production"
Write-Host "  kubectl rollout restart deployment/jobber-users -n production"
Write-Host ""
