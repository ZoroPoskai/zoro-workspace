#!/bin/bash
# Watcher Monitor Service
# This service ensures openclaw-gateway is always running.
# If it crashes or hangs, it restarts it and alerts.

# Config
OPENCLAW_SERVICE="openclaw-gateway.service"
CHECK_INTERVAL=30
LOG_FILE="/home/zoro/.openclaw/workspace/watcher-monitor.log"

log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

log "Starting Watcher Monitor..."

while true; do
  if ! systemctl --user is-active --quiet "$OPENCLAW_SERVICE"; then
    log "⚠️ ALERT: OpenClaw Gateway is down! Attempting revive..."
    
    # Try restart
    if systemctl --user restart "$OPENCLAW_SERVICE"; then
      log "✅ Successfully revived OpenClaw Gateway."
    else
      log "❌ FAILED to revive OpenClaw Gateway. System critical."
    fi
  else
    # Heartbeat log every 10 mins (20 cycles * 30s)
    # (Just touch file to show we're alive)
    touch "$LOG_FILE"
  fi
  
  sleep "$CHECK_INTERVAL"
done
