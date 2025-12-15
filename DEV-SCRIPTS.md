# Scripts for Running Services in Development

This project includes several scripts to run all services in parallel during development. All scripts **automatically free ports** before starting services to avoid conflicts.

## ⚠️ IMPORTANT: Start Databases First

**Before running the services, you need to start the databases:**

```powershell
# Option 1: Using the script
.\start-databases.ps1

# Option 2: Using npm
npm run start-databases

# Option 3: Manually
cd services\volumes
docker-compose up -d
```

This will start:
- Redis (port 6379)
- MongoDB (port 27017)
- MySQL (port 3307)
- PostgreSQL (port 5432)
- RabbitMQ (ports 5672, 15672)
- **Elasticsearch (port 9200)** ← **Required for services to work**
- Kibana (port 5601)
- APM Server (port 8200)

**Wait 30-60 seconds** after starting docker-compose for Elasticsearch to be completely ready.

## Option 1: Using npm with concurrently (Recommended)

This is the cleanest and most organized option. Shows all logs in a single window with different colors for each service.

### Installation
**IMPORTANT:** Run from the project root (where this package.json is):
```bash
cd "C:\Jobapp final\jobapp-full"
npm install
```

### Usage

**Run all services (including client):**
```bash
npm run dev
```

**Run only backend services (without client):**
```bash
npm run dev:services
```

**Run an individual service:**
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

**Free ports manually:**
```bash
npm run kill-ports
```

## Option 2: PowerShell Script (Windows)

Open a PowerShell window and run (from the project root):
```powershell
.\dev-services.ps1
```

This script opens each service in a separate PowerShell window. Each service has its own window with its own log.

**Advantages:**
- No additional dependencies required
- Each service has its own window
- Easy to see individual logs
- Close each window to stop that service
- Automatically frees ports before starting

## Scripts to Free Ports

If you need to free ports manually:

**PowerShell:**
```powershell
.\kill-ports.ps1
```

**npm:**
```bash
npm run kill-ports
```

These scripts automatically free the following ports:
- **4000** - Gateway Service
- **4002** - Notification Service
- **4003** - Auth Service
- **4004** - Gig Service
- **4005** - Users Service
- **4007** - Chat Service
- **4008** - Order Service
- **4009** - Review Service
- **3000** - Frontend Client

## Included Services

- **GATEWAY** - Gateway Service (Port 4000)
- **AUTH** - Auth Service (Port 4003)
- **USERS** - Users Service (Port 4005)
- **NOTIFICATIONS** - Notification Service (Port 4002)
- **CHAT** - Chat Service (Port 4007)
- **GIG** - Gig Service (Port 4004)
- **ORDER** - Order Service (Port 4008)
- **REVIEW** - Review Service (Port 4009)
- **CLIENT** - Frontend Client (Port 3000 by default)

## Troubleshooting

### Error: "EADDRINUSE: address already in use" (Port in use)

If you see this error, it means there are previous processes still running on the ports.

**Quick solution:**
```powershell
# From the project root
.\kill-ports.ps1
```

**Or manually in PowerShell:**
```powershell
# Kill process on specific port (example: port 4000)
$port = 4000
$process = Get-NetTCPConnection -LocalPort $port -ErrorAction SilentlyContinue | Select-Object -ExpandProperty OwningProcess -First 1
if ($process) { Stop-Process -Id $process -Force }
```

**Note:** The main scripts (`npm run dev`, `dev-services.ps1`) automatically run `kill-ports` before starting services to avoid this problem.

### Error: "concurrently is not recognized"

- Make sure you're in the project root directory
- Run `npm install` first
- Or use option 2 (PowerShell) which doesn't require additional installation

### Error: "npm run dev" doesn't work

- Make sure you're in the project root where the `package.json` is
- Verify you've run `npm install` in the root
- If the problem persists, use the alternative script (`dev-services.ps1`)

## Notes

- Make sure you have all services installed with `npm install` in each directory
- If you prefer to install all dependencies at once, you can use:
  ```bash
  npm run install:all
  ```
- Services require databases to be running (Redis, MongoDB, MySQL, PostgreSQL, RabbitMQ, Elasticsearch)
- To stop services with concurrently, press `Ctrl+C`
- To stop services with the PowerShell script, close the corresponding windows
- If services crash, run `kill-ports.ps1` before starting them again

## Installing All Dependencies

To install all dependencies for all services and the client at once:

```bash
npm run install:all
```

This will install:
- Root dependencies (concurrently)
- Dependencies for each service (gateway, auth, users, notifications, chat, gig, order, review)
- Client dependencies (jobber-client)
