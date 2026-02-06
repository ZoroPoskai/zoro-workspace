#!/bin/bash
# Zoro System Health Check
# Quick snapshot of the machine state

echo "{"
echo "  \"timestamp\": \"$(date -Iseconds)\","
echo "  \"uptime\": \"$(uptime -p)\","
echo "  \"load\": \"$(cat /proc/loadavg | cut -d' ' -f1-3)\","
echo "  \"memUsedPct\": $(free | awk '/Mem:/ {printf "%.1f", $3/$2 * 100}'),"
echo "  \"diskUsedPct\": $(df / | awk 'NR==2 {gsub(/%/,""); print $5}'),"
echo "  \"gpuTemp\": $(nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader,nounits 2>/dev/null || echo "null"),"
echo "  \"openclawRunning\": $(systemctl is-active openclaw-gateway >/dev/null 2>&1 && echo "true" || echo "false"),"
echo "  \"networkUp\": $(curl -s --max-time 3 -o /dev/null -w '%{http_code}' https://api.anthropic.com | grep -q 200 && echo "true" || echo "false")"
echo "}"
