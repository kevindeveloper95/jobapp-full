# Script para verificar conectividad de red entre servicios
# Ejecutar: .\test-connectivity.ps1

$namespace = "production"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "TEST DE CONECTIVIDAD DE RED" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Función para test de conectividad
function Test-ServiceConnection {
    param(
        [string]$FromService,
        [string]$ToHost,
        [int]$ToPort,
        [string]$Description
    )
    
    Write-Host "[TEST] $Description" -NoNewline
    
    $pod = kubectl get pod -n $namespace -l app=$FromService -o jsonpath="{.items[0].metadata.name}" 2>&1
    
    if ($pod -and $LASTEXITCODE -eq 0) {
        $result = kubectl exec -n $namespace $pod -- timeout 5 nc -zv $ToHost $ToPort 2>&1
        
        if ($result -match "open|succeeded|connected") {
            Write-Host " [OK]" -ForegroundColor Green
            return $true
        } else {
            Write-Host " [ERROR]" -ForegroundColor Red
            Write-Host "    Detalle: $result" -ForegroundColor Gray
            return $false
        }
    } else {
        Write-Host " [WARNING] Pod no encontrado" -ForegroundColor Yellow
        return $false
    }
}

Write-Host "1. VERIFICANDO DNS RESOLUTION" -ForegroundColor Yellow
Write-Host "----------------------------------------"

$services = @(
    "jobber-redis",
    "jobber-mysql", 
    "jobber-postgres",
    "jobber-mongodb",
    "jobber-elastic",
    "jobber-queue",
    "jobber-gateway"
)

foreach ($service in $services) {
    $fqdn = "$service.$namespace.svc.cluster.local"
    Write-Host "[DNS] Resolviendo: $fqdn" -NoNewline
    
    # Crear un pod temporal para hacer nslookup
    $result = kubectl run test-dns-temp --image=busybox --rm --restart=Never -n $namespace -- nslookup $fqdn 2>&1
    
    if ($result -match "Address") {
        Write-Host " [OK]" -ForegroundColor Green
    } else {
        Write-Host " [ERROR]" -ForegroundColor Red
    }
    
    Start-Sleep -Milliseconds 500
}

Write-Host ""

Write-Host "2. GATEWAY -> BASES DE DATOS" -ForegroundColor Yellow
Write-Host "----------------------------------------"

Test-ServiceConnection -FromService "jobber-gateway" -ToHost "jobber-redis.$namespace.svc.cluster.local" -ToPort 6379 -Description "Gateway -> Redis (6379)"
Test-ServiceConnection -FromService "jobber-gateway" -ToHost "jobber-mysql.$namespace.svc.cluster.local" -ToPort 3306 -Description "Gateway -> MySQL (3306)"
Test-ServiceConnection -FromService "jobber-gateway" -ToHost "jobber-postgres.$namespace.svc.cluster.local" -ToPort 5432 -Description "Gateway -> PostgreSQL (5432)"
Test-ServiceConnection -FromService "jobber-gateway" -ToHost "jobber-mongodb.$namespace.svc.cluster.local" -ToPort 27017 -Description "Gateway -> MongoDB (27017)"
Test-ServiceConnection -FromService "jobber-gateway" -ToHost "jobber-elastic.$namespace.svc.cluster.local" -ToPort 9200 -Description "Gateway -> Elasticsearch (9200)"
Test-ServiceConnection -FromService "jobber-gateway" -ToHost "jobber-queue.$namespace.svc.cluster.local" -ToPort 5672 -Description "Gateway -> RabbitMQ (5672)"

Write-Host ""

Write-Host "3. AUTH SERVICE -> MYSQL" -ForegroundColor Yellow
Write-Host "----------------------------------------"

Test-ServiceConnection -FromService "jobber-auth" -ToHost "jobber-mysql.$namespace.svc.cluster.local" -ToPort 3306 -Description "Auth -> MySQL (3306)"
Test-ServiceConnection -FromService "jobber-auth" -ToHost "jobber-elastic.$namespace.svc.cluster.local" -ToPort 9200 -Description "Auth -> Elasticsearch (9200)"

Write-Host ""

Write-Host "4. USERS SERVICE -> MONGODB" -ForegroundColor Yellow
Write-Host "----------------------------------------"

Test-ServiceConnection -FromService "jobber-users" -ToHost "jobber-mongodb.$namespace.svc.cluster.local" -ToPort 27017 -Description "Users -> MongoDB (27017)"
Test-ServiceConnection -FromService "jobber-users" -ToHost "jobber-elastic.$namespace.svc.cluster.local" -ToPort 9200 -Description "Users -> Elasticsearch (9200)"

Write-Host ""

Write-Host "5. GIG SERVICE -> POSTGRESQL" -ForegroundColor Yellow
Write-Host "----------------------------------------"

Test-ServiceConnection -FromService "jobber-gig" -ToHost "jobber-postgres.$namespace.svc.cluster.local" -ToPort 5432 -Description "Gig -> PostgreSQL (5432)"
Test-ServiceConnection -FromService "jobber-gig" -ToHost "jobber-elastic.$namespace.svc.cluster.local" -ToPort 9200 -Description "Gig -> Elasticsearch (9200)"

Write-Host ""

Write-Host "6. CHAT SERVICE -> MONGODB" -ForegroundColor Yellow
Write-Host "----------------------------------------"

Test-ServiceConnection -FromService "jobber-chat" -ToHost "jobber-mongodb.$namespace.svc.cluster.local" -ToPort 27017 -Description "Chat -> MongoDB (27017)"

Write-Host ""

Write-Host "7. ORDER SERVICE -> MONGODB" -ForegroundColor Yellow
Write-Host "----------------------------------------"

Test-ServiceConnection -FromService "jobber-order" -ToHost "jobber-mongodb.$namespace.svc.cluster.local" -ToPort 27017 -Description "Order -> MongoDB (27017)"

Write-Host ""

Write-Host "8. REVIEW SERVICE -> MYSQL" -ForegroundColor Yellow
Write-Host "----------------------------------------"

Test-ServiceConnection -FromService "jobber-reviews" -ToHost "jobber-mysql.$namespace.svc.cluster.local" -ToPort 3306 -Description "Review -> MySQL (3306)"
Test-ServiceConnection -FromService "jobber-reviews" -ToHost "jobber-postgres.$namespace.svc.cluster.local" -ToPort 5432 -Description "Review -> PostgreSQL (5432)"

Write-Host ""

Write-Host "9. TODOS LOS SERVICIOS -> RABBITMQ" -ForegroundColor Yellow
Write-Host "----------------------------------------"

$microservices = @("jobber-gateway", "jobber-auth", "jobber-users", "jobber-gig", "jobber-chat", "jobber-order", "jobber-reviews", "jobber-notification")

foreach ($service in $microservices) {
    Test-ServiceConnection -FromService $service -ToHost "jobber-queue.$namespace.svc.cluster.local" -ToPort 5672 -Description "$service -> RabbitMQ (5672)"
}

Write-Host ""

Write-Host "10. VERIFICANDO ENDPOINTS DE KUBERNETES" -ForegroundColor Yellow
Write-Host "----------------------------------------"

Write-Host "[INFO] Endpoints de servicios (deben tener IPs):"
kubectl get endpoints -n $namespace | Select-String -Pattern "redis|mysql|postgres|mongo|elastic|queue|gateway|auth|users|gig|chat|order|review|notification"

Write-Host ""

Write-Host "11. VERIFICANDO SERVICIOS DE KUBERNETES" -ForegroundColor Yellow
Write-Host "----------------------------------------"

Write-Host "[INFO] Servicios y sus ClusterIPs:"
kubectl get svc -n $namespace -o custom-columns=NAME:.metadata.name,TYPE:.spec.type,CLUSTER-IP:.spec.clusterIP,PORT:.spec.ports[0].port

Write-Host ""

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "TEST DE CONECTIVIDAD COMPLETADO" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "RESUMEN:" -ForegroundColor Yellow
Write-Host ""
Write-Host "Si ves muchos [ERROR]:" -ForegroundColor Red
Write-Host "  1. Verifica que los pods esten corriendo: kubectl get pods -n production"
Write-Host "  2. Verifica que los servicios existan: kubectl get svc -n production"
Write-Host "  3. Verifica que los endpoints tengan IPs: kubectl get endpoints -n production"
Write-Host "  4. Reinicia los pods con problemas: kubectl rollout restart deployment/<nombre> -n production"
Write-Host ""
Write-Host "Si los pods no tienen la herramienta 'nc' (netcat):"
Write-Host "  Es normal en algunas imagenes. Mientras los logs no muestren errores de conexion, esta OK."
Write-Host ""
Write-Host "Para ver logs de un servicio especifico:"
Write-Host "  kubectl logs -f -n production deployment/<nombre-servicio>"
Write-Host ""
