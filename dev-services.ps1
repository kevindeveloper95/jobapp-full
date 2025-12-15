# Script de PowerShell para ejecutar todos los servicios en desarrollo
# Uso: .\dev-services.ps1

$rootPath = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $rootPath

Write-Host "Iniciando todos los servicios..." -ForegroundColor Green
Write-Host "Directorio raiz: $rootPath" -ForegroundColor Cyan
Write-Host ""

# Matar procesos en puertos antes de iniciar
Write-Host "Liberando puertos..." -ForegroundColor Yellow
$killPortsScript = Join-Path $rootPath "kill-ports.ps1"
if (Test-Path $killPortsScript) {
    & $killPortsScript
    Write-Host ""
} else {
    Write-Host "[WARN] Script kill-ports.ps1 no encontrado, continuando..." -ForegroundColor Yellow
    Write-Host ""
}

$services = @(
    @{Name="GATEWAY"; Path="services\gateway-service"; Color="Blue"},
    @{Name="AUTH"; Path="services\auth-service"; Color="Green"},
    @{Name="USERS"; Path="services\users-service"; Color="Yellow"},
    @{Name="NOTIFICATIONS"; Path="services\notification-service"; Color="Magenta"},
    @{Name="CHAT"; Path="services\chat-service"; Color="Cyan"},
    @{Name="GIG"; Path="services\gig-service"; Color="Red"},
    @{Name="ORDER"; Path="services\order-service"; Color="White"},
    @{Name="REVIEW"; Path="services\review-service"; Color="Blue"},
    @{Name="CLIENT"; Path="jobber-client"; Color="Green"}
)

$jobs = @()

foreach ($service in $services) {
    Write-Host "[START] Iniciando $($service.Name)..." -ForegroundColor $service.Color
    $serviceFullPath = Join-Path $rootPath $service.Path
    
    $job = Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$serviceFullPath'; Write-Host '[$($service.Name)] Iniciando...' -ForegroundColor $($service.Color); npm run dev" -PassThru -WindowStyle Normal
    
    $jobs += @{
        Name = $service.Name
        Process = $job
    }
    
    Start-Sleep -Milliseconds 500
}

Write-Host ""
Write-Host "[OK] Todos los servicios estan iniciando en ventanas separadas..." -ForegroundColor Green
Write-Host "[STOP] Cierra las ventanas individuales para detener cada servicio" -ForegroundColor Yellow
Write-Host ""
Write-Host "Presiona Enter para ver el estado de los procesos..." -ForegroundColor Cyan
Read-Host

# Mostrar procesos activos
Write-Host ""
Write-Host "Procesos activos:" -ForegroundColor Cyan
$jobs | ForEach-Object {
    if (-not $_.Process.HasExited) {
        Write-Host "  [OK] $($_.Name) - PID: $($_.Process.Id)" -ForegroundColor Green
    } else {
        Write-Host "  [STOP] $($_.Name) - Finalizado" -ForegroundColor Red
    }
}
