# Scripts para Ejecutar Servicios en Desarrollo

Este proyecto incluye varios scripts para ejecutar todos los servicios en paralelo durante el desarrollo. Todos los scripts **liberan automáticamente los puertos** antes de iniciar los servicios para evitar conflictos.

## ⚠️ IMPORTANTE: Iniciar Bases de Datos Primero

**Antes de ejecutar los servicios, necesitas iniciar las bases de datos:**

```powershell
# Opcion 1: Usando el script
.\start-databases.ps1

# Opcion 2: Usando npm
npm run start-databases

# Opcion 3: Manualmente
cd services\volumes
docker-compose up -d
```

Esto iniciará:
- Redis (puerto 6379)
- MongoDB (puerto 27017)
- MySQL (puerto 3307)
- PostgreSQL (puerto 5432)
- RabbitMQ (puertos 5672, 15672)
- **Elasticsearch (puerto 9200)** ← **Necesario para que los servicios funcionen**
- Kibana (puerto 5601)
- APM Server (puerto 8200)

**Espera 30-60 segundos después de iniciar docker-compose para que Elasticsearch esté completamente listo.**

## Opción 1: Usando npm con concurrently (Recomendado)

Esta es la opción más limpia y organizada. Muestra todos los logs en una sola ventana con colores diferentes para cada servicio.

### Instalación
**IMPORTANTE:** Ejecuta desde la raíz del proyecto (donde está este package.json):
```bash
cd "C:\Jobapp final\jobapp-full"
npm install
```

### Uso

**Ejecutar todos los servicios (incluyendo el cliente):**
```bash
npm run dev
```

**Ejecutar solo los servicios backend (sin el cliente):**
```bash
npm run dev:services
```

**Ejecutar un servicio individual:**
```bash
npm run dev:gateway
npm run dev:auth
npm run dev:users
npm run dev:notifications
npm run dev:chat
npm run dev:gig
npm run dev:order
npm run dev:review
npm run dev:client
```

**Liberar puertos manualmente:**
```bash
npm run kill-ports
```

## Opción 2: Script de PowerShell (Windows)

Abre una ventana de PowerShell y ejecuta (desde la raíz del proyecto):
```powershell
.\dev-services.ps1
```

Este script abre cada servicio en una ventana de PowerShell separada. Cada servicio tiene su propia ventana con su propio log.

**Ventajas:**
- No requiere instalación de dependencias adicionales
- Cada servicio tiene su propia ventana
- Fácil de ver los logs individuales
- Cierra cada ventana para detener ese servicio
- Libera puertos automáticamente antes de iniciar

## Scripts para Liberar Puertos

Si necesitas liberar los puertos manualmente:

**PowerShell:**
```powershell
.\kill-ports.ps1
```

**npm:**
```bash
npm run kill-ports
```

Estos scripts liberan automáticamente los siguientes puertos:
- **4000** - Gateway Service
- **4002** - Notification Service
- **4003** - Auth Service
- **4004** - Gig Service
- **4005** - Users Service
- **4007** - Chat Service
- **4008** - Order Service
- **4009** - Review Service
- **3000** - Frontend Client

## Servicios incluidos

- **GATEWAY** - Gateway Service (Puerto 4000)
- **AUTH** - Auth Service (Puerto 4003)
- **USERS** - Users Service (Puerto 4005)
- **NOTIFICATIONS** - Notification Service (Puerto 4002)
- **CHAT** - Chat Service (Puerto 4007)
- **GIG** - Gig Service (Puerto 4004)
- **ORDER** - Order Service (Puerto 4008)
- **REVIEW** - Review Service (Puerto 4009)
- **CLIENT** - Frontend Client (Puerto 3000 por defecto)

## Solución de problemas

### Error: "EADDRINUSE: address already in use" (Puerto en uso)

Si ves este error, significa que hay procesos anteriores aún ejecutándose en los puertos. 

**Solución rápida:**
```powershell
# Desde la raíz del proyecto
.\kill-ports.ps1
```

**O manualmente en PowerShell:**
```powershell
# Matar proceso en puerto específico (ejemplo: puerto 4000)
$port = 4000
$process = Get-NetTCPConnection -LocalPort $port -ErrorAction SilentlyContinue | Select-Object -ExpandProperty OwningProcess -First 1
if ($process) { Stop-Process -Id $process -Force }
```

**Nota:** Los scripts principales (`npm run dev`, `dev-services.ps1`) ejecutan automáticamente `kill-ports` antes de iniciar los servicios para evitar este problema.

### Error: "concurrently no se reconoce"

- Asegúrate de estar en el directorio raíz del proyecto
- Ejecuta `npm install` primero
- O usa la opción 2 (PowerShell) que no requiere instalación adicional

### Error: "npm run dev" no funciona

- Asegúrate de estar en la raíz del proyecto donde está el `package.json`
- Verifica que hayas ejecutado `npm install` en la raíz
- Si el problema persiste, usa el script alternativo (`dev-services.ps1`)

## Notas

- Asegúrate de tener todos los servicios instalados con `npm install` en cada directorio
- Si prefieres instalar todas las dependencias de una vez, puedes usar:
  ```bash
  npm run install:all
  ```
- Los servicios requieren que las bases de datos estén corriendo (Redis, MongoDB, MySQL, PostgreSQL, RabbitMQ, Elasticsearch)
- Para detener los servicios con concurrently, presiona `Ctrl+C`
- Para detener los servicios con el script de PowerShell, cierra las ventanas correspondientes
- Si los servicios crashean, ejecuta `kill-ports.ps1` antes de volver a iniciarlos

## Instalación de todas las dependencias

Para instalar todas las dependencias de todos los servicios y el cliente de una vez:

```bash
npm run install:all
```

Esto instalará:
- Dependencias de la raíz (concurrently)
- Dependencias de cada servicio (gateway, auth, users, notifications, chat, gig, order, review)
- Dependencias del cliente (jobber-client)
