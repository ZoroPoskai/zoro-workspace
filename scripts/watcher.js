const fs = require('fs');
const { execSync } = require('child_process');

// Config
const STATE_FILE = '/home/zoro/.openclaw/workspace/watcher-state.json';
const HEALTH_SCRIPT = '/home/zoro/.openclaw/workspace/scripts/health-check.sh';

function run() {
  console.log('👁️ Watcher running...');

  // 1. Run health check
  let health = {};
  try {
    const output = execSync(HEALTH_SCRIPT, { encoding: 'utf8' });
    health = JSON.parse(output);
  } catch (err) {
    console.error('Health check failed:', err.message);
    health = { error: err.message, timestamp: new Date().toISOString() };
  }

  // 2. Read previous state
  let state = {};
  try {
    if (fs.existsSync(STATE_FILE)) {
      state = JSON.parse(fs.readFileSync(STATE_FILE, 'utf8'));
    }
  } catch (err) {
    console.error('Read state failed:', err.message);
  }

  // 3. Update state
  state.last_check = new Date().toISOString();
  state.health = health;
  state.watcher_generation = (state.watcher_generation || 0) + 1;

  // 4. Alert logic (simple threshold)
  const alerts = [];
  if (health.disk_pct > 90) alerts.push(`High disk usage: ${health.disk_pct}%`);
  if (health.memory_pct > 95) alerts.push(`High memory usage: ${health.memory_pct}%`);
  if (health.gpu_temp > 85) alerts.push(`High GPU temp: ${health.gpu_temp}°C`);
  
  if (alerts.length > 0) {
    console.log('🚨 ALERTS:', alerts.join(', '));
    // In a real relay, we might wake the main agent here
    state.alerts = alerts;
  } else {
    state.alerts = [];
  }

  // 5. Write state
  fs.writeFileSync(STATE_FILE, JSON.stringify(state, null, 2));
  console.log('👁️ Watcher sleep.');
}

run();
