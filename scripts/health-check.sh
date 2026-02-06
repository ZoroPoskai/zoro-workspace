#!/bin/bash
# Zoro System Health Check v2
# Robust, JSON-outputting health script for The Watcher

# Timestamp
TS=$(date -Iseconds)

# Uptime (human readable)
UPTIME=$(uptime -p | sed 's/^up //')

# Load Average (1m 5m 15m)
LOAD=$(cat /proc/loadavg | awk '{print $1" "$2" "$3}')

# Memory Usage % (integer)
# free output: total used free shared buff/cache available
# We want: (total - available) / total * 100
MEM_PCT=$(free | grep Mem | awk '{printf "%.0f", ($2-$7)/$2 * 100}')

# Disk Usage % (root)
DISK_PCT=$(df / | awk 'NR==2 {gsub(/%/,""); print $5}')

# GPU Temp (if nvidia-smi exists)
if command -v nvidia-smi &> /dev/null; then
    GPU_TEMP=$(nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader,nounits 2>/dev/null | head -1)
else
    GPU_TEMP="null"
fi

# Service Status
if systemctl is-active --quiet openclaw-gateway; then
    OC_STATUS="true"
else
    OC_STATUS="false"
fi

# Network Check (Google DNS)
if ping -c 1 -W 2 8.8.8.8 &> /dev/null; then
    NET_STATUS="true"
else
    NET_STATUS="false"
fi

# JSON Output
cat <<EOF
{
  "timestamp": "$TS",
  "uptime": "$UPTIME",
  "load": "$LOAD",
  "memory_pct": $MEM_PCT,
  "disk_pct": $DISK_PCT,
  "gpu_temp": $GPU_TEMP,
  "openclaw_active": $OC_STATUS,
  "network_up": $NET_STATUS
}
EOF
