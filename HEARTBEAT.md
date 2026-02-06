# HEARTBEAT.md — Zoro's Pulse

## 1. The Watcher Check 👁️
- Read `/home/zoro/.openclaw/workspace/watcher-state.json`.
- If `alerts` array is not empty, REPORT IT IMMEDIATELY.
- If `last_check` is older than 20 minutes, REPORT "Watcher is dead".

## 2. System Pulse 🩺
- Run `/home/zoro/.openclaw/workspace/scripts/health-check.sh`
- If `disk_pct` > 90% or `memory_pct` > 90%, ALERT.

## 3. Engagement Check 🗣️
- If it is between 09:00 and 22:00 (Vilnius time) AND last user message was > 8 hours ago:
  - Send a brief status update (e.g., "Systems stable. Watcher reporting nominal. Anything for me?").

## 4. Self-Correction 🧠
- If you notice you are repeating yourself or stuck in a loop, running `/compact` is authorized.
