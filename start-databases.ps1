# Script para iniciar las bases de datos con docker-compose
# Uso: .\start-databases.ps1

$rootPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$dockerComposePath = Join-Path $rootPath "services\volumes\docker-compose.yaml"

Write-Host "Iniciando bases de datos con docker-compose..." -ForegroundColor Cyan
Write-Host "Ruta: $dockerComposePath" -ForegroundColor Gray
Write-Host ""

if (-not (Test-Path $dockerComposePath)) {
    Write-Host "[ERROR] No se encontro el archivo docker-compose.yaml en: $dockerComposePath" -ForegroundColor Red
    exit 1
}

# Verificar si docker-compose esta instalado
$dockerCompose = Get-Command docker-compose -ErrorAction SilentlyContinue
if (-not $dockerCompose) {
    $dockerCompose = Get-Command docker -ErrorAction SilentlyContinue
    if ($dockerCompose) {
        $composeCommand = "docker compose"
    } else {
        Write-Host "[ERROR] Docker no esta instalado o no esta en el PATH" -ForegroundColor Red
        exit 1
    }
} else {
    $composeCommand = "docker-compose"
}

# Cambiar al directorio donde esta el docker-compose.yaml
$composeDir = Split-Path -Parent $dockerComposePath
Set-Location $composeDir

Write-Host "[INFO] Ejecutando: $composeCommand up -d" -ForegroundColor Yellow
Write-Host ""

# Ejecutar docker-compose
if ($composeCommand -eq "docker compose") {
    docker compose -f docker-compose.yaml up -d
} else {
    docker-compose -f docker-compose.yaml up -d
}

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "[OK] Bases de datos iniciadas correctamente" -ForegroundColor Green
    Write-Host "[INFO] Espera unos segundos para que todos los servicios se inicien completamente" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Servicios iniciados:" -ForegroundColor Cyan
    Write-Host "  - Redis (puerto 6379)" -ForegroundColor Gray
    Write-Host "  - MongoDB (puerto 27017)" -ForegroundColor Gray
    Write-Host "  - MySQL (puerto 3307)" -ForegroundColor Gray
    Write-Host "  - PostgreSQL (puerto 5432)" -ForegroundColor Gray
    Write-Host "  - RabbitMQ (puertos 5672, 15672)" -ForegroundColor Gray
    Write-Host "  - Elasticsearch (puerto 9200)" -ForegroundColor Gray
    Write-Host "  - Kibana (puerto 5601)" -ForegroundColor Gray
    Write-Host "  - APM Server (puerto 8200)" -ForegroundColor Gray
} else {
    Write-Host ""
    Write-Host "[ERROR] Error al iniciar las bases de datos" -ForegroundColor Red
    exit 1
}

