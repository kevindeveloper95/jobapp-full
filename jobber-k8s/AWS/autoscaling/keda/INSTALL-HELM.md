# Instalar Helm en Windows

Esta guía te ayudará a instalar Helm en Windows para poder usar KEDA.

---

## Verificar si Helm está instalado

### Opción 1: Verificar en PowerShell

```powershell
# Verificar si Helm está en el PATH
Get-Command helm -ErrorAction SilentlyContinue

# O verificar versión
helm version
```

### Opción 2: Buscar manualmente

```powershell
# Buscar Helm en ubicaciones comunes
Test-Path "$env:ProgramFiles\Helm\helm.exe"
Test-Path "$env:LOCALAPPDATA\Programs\Helm\helm.exe"
```

---

## Instalar Helm en Windows

### Método 1: Usando Chocolatey (Recomendado)

Si tienes Chocolatey instalado:

```powershell
# Instalar Helm
choco install kubernetes-helm

# Verificar instalación
helm version
```

### Método 2: Descarga manual

1. **Descargar Helm:**
   - Ve a: https://github.com/helm/helm/releases
   - Descarga la última versión para Windows (ej: `helm-v3.14.0-windows-amd64.zip`)

2. **Extraer y mover:**
   ```powershell
   # Extraer el ZIP
   # Mover helm.exe a una carpeta en tu PATH, por ejemplo:
   # C:\Program Files\Helm\
   ```

3. **Agregar al PATH:**
   - Abre "Variables de entorno" en Windows
   - Agrega la carpeta de Helm al PATH del sistema
   - Reinicia PowerShell

### Método 3: Usando winget (Windows 10/11)

```powershell
# Instalar Helm
winget install Helm.Helm

# Verificar
helm version
```

### Método 4: Usando Scoop

Si tienes Scoop instalado:

```powershell
scoop install helm
```

---

## Verificar instalación

Después de instalar, **cierra y vuelve a abrir PowerShell** (importante para que cargue el PATH actualizado), luego:

```powershell
# Verificar que Helm funciona
helm version

# Deberías ver algo como:
# version.BuildInfo{Version:"v3.14.0", ...}
```

---

## Si Helm ya estaba instalado pero no se encuentra

### Solución 1: Reiniciar PowerShell

Cierra y vuelve a abrir PowerShell. A veces el PATH no se carga en la sesión actual.

### Solución 2: Agregar Helm al PATH manualmente

```powershell
# Encontrar dónde está Helm
Get-ChildItem -Path "C:\" -Filter "helm.exe" -Recurse -ErrorAction SilentlyContinue | Select-Object FullName

# Una vez encontrado, agregar al PATH de la sesión actual:
$env:Path += ";C:\ruta\donde\esta\helm"

# O agregar permanentemente:
[Environment]::SetEnvironmentVariable("Path", $env:Path + ";C:\ruta\donde\esta\helm", "User")
```

### Solución 3: Usar ruta completa

Si sabes dónde está Helm, puedes usarlo directamente:

```powershell
# Ejemplo si está en C:\Program Files\Helm\
& "C:\Program Files\Helm\helm.exe" version
```

---

## Instalar Helm rápidamente (si no lo tienes)

### Opción más rápida: Chocolatey

```powershell
# Si no tienes Chocolatey, instálalo primero:
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# Luego instala Helm:
choco install kubernetes-helm -y

# Cierra y vuelve a abrir PowerShell
```

### Opción alternativa: winget

```powershell
winget install Helm.Helm
```

---

## Después de instalar

1. **Cierra y vuelve a abrir PowerShell** (importante)
2. Verifica: `helm version`
3. Continúa con la instalación de KEDA según `README-KEDA.md`

---

## Troubleshooting

| Problema | Solución |
|----------|----------|
| `helm: command not found` | Reiniciar PowerShell o agregar al PATH |
| `helm version` muestra error | Verificar que la instalación fue exitosa |
| Helm no persiste después de reiniciar | Agregar permanentemente al PATH del sistema |

---

## Verificar que funciona

```powershell
# Ver versión
helm version

# Agregar repositorio de prueba
helm repo add stable https://charts.helm.sh/stable
helm repo update

# Si todo funciona, puedes continuar con KEDA
```









