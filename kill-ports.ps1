# Script para matar procesos que estan usando los puertos de los servicios
# Uso: .\kill-ports.ps1
param(
    [switch]$NoPrompt
)

$ports = @(4000, 4002, 4003, 4004, 4005, 4007, 4008, 4009, 3000)

Write-Host "Buscando procesos en los puertos de los servicios..." -ForegroundColor Cyan
Write-Host ""

$killedCount = 0

foreach ($port in $ports) {
    # Buscar procesos usando el puerto
    $connections = Get-NetTCPConnection -LocalPort $port -ErrorAction SilentlyContinue | Where-Object { $_.State -eq "Listen" }
    
    if ($connections) {
        $processIds = $connections | Select-Object -ExpandProperty OwningProcess -Unique
        
        foreach ($processId in $processIds) {
            try {
                $process = Get-Process -Id $processId -ErrorAction SilentlyContinue
                if ($process) {
                    Write-Host "[STOP] Matando proceso en puerto $port - PID: $processId - Nombre: $($process.ProcessName)" -ForegroundColor Yellow
                    Stop-Process -Id $processId -Force -ErrorAction SilentlyContinue
                    $killedCount++
                    Start-Sleep -Milliseconds 200
                }
            } catch {
                Write-Host "[WARN] No se pudo matar el proceso $processId en puerto $port" -ForegroundColor Red
            }
        }
    } else {
        Write-Host "[OK] Puerto $port esta libre" -ForegroundColor Green
    }
}

Write-Host ""
if ($killedCount -gt 0) {
    Write-Host "[OK] Se mataron $killedCount proceso(s)" -ForegroundColor Green
    Write-Host "[INFO] Espera 2 segundos para que los puertos se liberen..." -ForegroundColor Yellow
    Start-Sleep -Seconds 2
} else {
    Write-Host "[OK] Todos los puertos estan libres" -ForegroundColor Green
}
