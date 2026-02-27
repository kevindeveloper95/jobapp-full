/**
 * Libera el puerto 4004 (o el que se pase como argumento) en Windows.
 * Uso: node scripts/free-port.js [4004]
 * Útil cuando el contenedor gig de Docker o otra instancia ya está usando el puerto.
 */
const { execSync } = require('child_process');
const port = process.argv[2] || '4004';

function freePortWin(portNum) {
  try {
    const out = execSync(`netstat -ano | findstr :${portNum}`, { encoding: 'utf8', stdio: ['pipe', 'pipe', 'pipe'] });
    const lines = out.trim().split('\n').filter((line) => line.includes('LISTENING'));
    const pids = new Set();
    for (const line of lines) {
      const parts = line.trim().split(/\s+/);
      const pid = parts[parts.length - 1];
      if (pid && /^\d+$/.test(pid)) pids.add(pid);
    }
    for (const pid of pids) {
      console.log(`Liberando puerto ${portNum}: terminando proceso PID ${pid}...`);
      execSync(`taskkill /PID ${pid} /F`, { stdio: 'inherit' });
    }
    if (pids.size === 0) {
      console.log(`Ningún proceso encontrado en el puerto ${portNum}.`);
    } else {
      console.log(`Puerto ${portNum} liberado.`);
    }
  } catch (e) {
    if (e.status === 1 && e.stderr && e.message.includes('findstr')) {
      console.log(`Ningún proceso escuchando en el puerto ${portNum}.`);
      return;
    }
    throw e;
  }
}

freePortWin(port);
