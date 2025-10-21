# Script de diagnostico completo para Jobber Microservices (PowerShell)
# Ejecutar: .\diagnostics.ps1

$namespace = "production"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "DIAGNOSTICO COMPLETO - JOBBER SYSTEM" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# 1. Estado de todos los pods
Write-Host "1. VERIFICANDO ESTADO DE TODOS LOS PODS" -ForegroundColor Yellow
Write-Host "----------------------------------------"
kubectl get pods -n $namespace -o wide
Write-Host ""

# 2. Pods con problemas
Write-Host "2. PODS CON PROBLEMAS" -ForegroundColor Yellow
Write-Host "----------------------------------------"
$problematicPods = kubectl get pods -n $namespace --no-headers | Select-String -Pattern "CrashLoop|Error|Pending|ImagePull"
if ($problematicPods) {
    $problematicPods
} else {
    Write-Host "[OK] No hay pods con errores criticos" -ForegroundColor Green
}
Write-Host ""

# 3. Verificar bases de datos
Write-Host "3. VERIFICANDO BASES DE DATOS" -ForegroundColor Yellow
Write-Host "----------------------------------------"

# MongoDB (el pod se llama jobber-mongo-0, no jobber-mongodb)
Write-Host "[TEST] MongoDB:" -NoNewline
$mongoResult = kubectl exec -n $namespace jobber-mongo-0 -- mongosh --eval "db.adminCommand('ping')" --quiet 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host " [OK] MongoDB respondiendo" -ForegroundColor Green
} else {
    Write-Host " [ERROR] MongoDB no responde" -ForegroundColor Red
    Write-Host "  Detalles: $mongoResult" -ForegroundColor Gray
}

# MySQL
Write-Host "[TEST] MySQL:" -NoNewline
$mysqlResult = kubectl exec -n $namespace deployment/jobber-mysql -- mysql -uroot -papi -e "SELECT 1;" 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host " [OK] MySQL respondiendo" -ForegroundColor Green
} else {
    Write-Host " [ERROR] MySQL no responde" -ForegroundColor Red
    Write-Host "  Detalles: $mysqlResult" -ForegroundColor Gray
}

# PostgreSQL
Write-Host "[TEST] PostgreSQL:" -NoNewline
$pgResult = kubectl exec -n $namespace deployment/jobber-postgres -- psql -U jobber -c "SELECT 1;" 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host " [OK] PostgreSQL respondiendo" -ForegroundColor Green
} else {
    Write-Host " [ERROR] PostgreSQL no responde" -ForegroundColor Red
    Write-Host "  Detalles: $pgResult" -ForegroundColor Gray
}

# Elasticsearch
Write-Host "[TEST] Elasticsearch:" -NoNewline
$esResult = kubectl exec -n $namespace deployment/jobber-elastic -- curl -s -u elastic:admin1234 http://localhost:9200/_cluster/health 2>&1
if ($esResult -match "status") {
    Write-Host " [OK] Elasticsearch respondiendo" -ForegroundColor Green
} else {
    Write-Host " [ERROR] Elasticsearch no responde" -ForegroundColor Red
}

# Redis (el pod se llama jobber-redis-0, contraseña: thisismyownpassword123@)
Write-Host "[TEST] Redis:" -NoNewline
$redisResult = kubectl exec -n $namespace jobber-redis-0 -- redis-cli -a "thisismyownpassword123@" ping 2>&1
if ($redisResult -match "PONG") {
    Write-Host " [OK] Redis respondiendo" -ForegroundColor Green
} else {
    Write-Host " [ERROR] Redis no responde" -ForegroundColor Red
    Write-Host "  Detalles: $redisResult" -ForegroundColor Gray
}

# RabbitMQ
Write-Host "[TEST] RabbitMQ:" -NoNewline
$rabbitResult = kubectl exec -n $namespace deployment/jobber-queue -- rabbitmqctl status 2>&1
if ($rabbitResult -match "RabbitMQ") {
    Write-Host " [OK] RabbitMQ respondiendo" -ForegroundColor Green
} else {
    Write-Host " [ERROR] RabbitMQ no responde" -ForegroundColor Red
}

Write-Host ""

# 4. Verificar bases de datos específicas
Write-Host "4. VERIFICANDO BASES DE DATOS ESPECIFICAS" -ForegroundColor Yellow
Write-Host "----------------------------------------"

# MySQL - Verificar base de datos jobber_auth
Write-Host "[INFO] MySQL - Bases de datos existentes:"
kubectl exec -n $namespace deployment/jobber-mysql -- mysql -uroot -papi -e "SHOW DATABASES;" 2>&1 | Select-String -Pattern "jobber"

# PostgreSQL - Verificar base de datos jobber
Write-Host ""
Write-Host "[INFO] PostgreSQL - Bases de datos existentes:"
kubectl exec -n $namespace deployment/jobber-postgres -- psql -U jobber -l 2>&1 | Select-String -Pattern "jobber"

# MongoDB - Verificar bases de datos
Write-Host ""
Write-Host "[INFO] MongoDB - Bases de datos existentes:"
kubectl exec -n $namespace jobber-mongo-0 -- mongosh --eval "db.adminCommand('listDatabases')" --quiet 2>&1 | Select-String -Pattern "jobber"

Write-Host ""

# 5. Verificar servicios
Write-Host "5. VERIFICANDO SERVICIOS" -ForegroundColor Yellow
Write-Host "----------------------------------------"
kubectl get svc -n $namespace
Write-Host ""

# 6. Verificar secrets
Write-Host "6. VERIFICANDO SECRETS" -ForegroundColor Yellow
Write-Host "----------------------------------------"
$secretExists = kubectl get secret jobber-backend-secret -n $namespace 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "[OK] Secret 'jobber-backend-secret' existe" -ForegroundColor Green
    Write-Host ""
    Write-Host "Claves disponibles en el secret:"
    $secretData = kubectl get secret jobber-backend-secret -n $namespace -o json 2>&1
    if ($secretData) {
        $secretObj = $secretData | ConvertFrom-Json
        $secretObj.data.PSObject.Properties.Name | ForEach-Object { Write-Host "  - $_" -ForegroundColor Cyan }
    }
} else {
    Write-Host "[ERROR] Secret 'jobber-backend-secret' NO existe" -ForegroundColor Red
}
Write-Host ""

# 7. Logs recientes de cada servicio
Write-Host "7. ESTADO Y LOGS RECIENTES DE SERVICIOS" -ForegroundColor Yellow
Write-Host "----------------------------------------"

$services = @("jobber-gateway", "jobber-auth", "jobber-users", "jobber-gig", "jobber-chat", "jobber-order", "jobber-review", "jobber-notification")

foreach ($service in $services) {
    Write-Host ""
    Write-Host "[SERVICIO] $service" -ForegroundColor Cyan
    $pod = kubectl get pod -n $namespace -l app=$service -o jsonpath="{.items[0].metadata.name}" 2>&1
    if ($pod -and $LASTEXITCODE -eq 0) {
        $status = kubectl get pod -n $namespace $pod -o jsonpath="{.status.phase}" 2>&1
        Write-Host "  Pod: $pod - Estado: $status"
        
        if ($status -ne "Running") {
            Write-Host "  [ATENCION] Ultimas 10 lineas del log:" -ForegroundColor Yellow
            kubectl logs --tail=10 -n $namespace $pod 2>&1
        } else {
            Write-Host "  [OK] Pod corriendo correctamente" -ForegroundColor Green
        }
    } else {
        Write-Host "  [ERROR] No se encontro pod para $service" -ForegroundColor Red
    }
}

Write-Host ""

# 8. Eventos recientes
Write-Host "8. EVENTOS RECIENTES (ultimos 15)" -ForegroundColor Yellow
Write-Host "----------------------------------------"
kubectl get events -n $namespace --sort-by='.lastTimestamp' 2>&1 | Select-Object -Last 15
Write-Host ""

# 9. Configuraciones importantes
Write-Host "9. VERIFICANDO CONFIGMAPS" -ForegroundColor Yellow
Write-Host "----------------------------------------"
kubectl get configmap -n $namespace
Write-Host ""

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "DIAGNOSTICO COMPLETADO" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "PROXIMOS PASOS RECOMENDADOS:" -ForegroundColor Yellow
Write-Host "1. Si hay bases de datos que no existen, ejecuta: .\setup-databases.ps1"
Write-Host "2. Para ver logs detallados de un servicio: kubectl logs -f -n production deployment/[nombre-servicio]"
Write-Host "3. Para reiniciar un servicio con problemas: kubectl rollout restart deployment/[nombre-servicio] -n production"
Write-Host ""
