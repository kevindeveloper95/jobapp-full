/**
 * Ejecuta el gig-service y escribe logs a archivo para que Alloy/Loki los recoja.
 * Uso: node scripts/dev-with-logs.js
 * Requiere: npm run dev debe estar configurado. Este script lo invoca via nodemon.
 */
const { spawn } = require('child_process');
const fs = require('fs');
const path = require('path');

const logsDir = path.join(__dirname, '..', 'logs');
const logFile = path.join(logsDir, 'gig.log');

fs.mkdirSync(logsDir, { recursive: true });
const logStream = fs.createWriteStream(logFile, { flags: 'a' });

const child = spawn('npx', ['nodemon', '-r', 'tsconfig-paths/register', 'src/app.ts', 'pino-pretty', '-c'], {
  cwd: path.join(__dirname, '..'),
  stdio: ['inherit', 'pipe', 'pipe'],
  shell: true
});

child.stdout?.on('data', (data) => {
  process.stdout.write(data);
  logStream.write(data);
});

child.stderr?.on('data', (data) => {
  process.stderr.write(data);
  logStream.write(data);
});

child.on('close', (code) => {
  logStream.end();
  process.exit(code ?? 0);
});
