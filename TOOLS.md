# TOOLS.md — Zoro's Local Notes 🗡️

## Discord Channels (Guild: 1469394389414707373)
| Channel | ID | Purpose |
|---------|-----|---------|
| #general | 1469394389414707376 | Main chat with Gvidas |
| #status-log | 1469424783031668756 | Status updates, phase completions |
| #brain-dump | 1469424825763102841 | Thoughts, research findings |
| #backlog | 1469425093842174045 | Task tracking |
| #news-feed | 1469425135776829585 | News, discoveries, tool drops |
| #console | 1469435745927168186 | Live execution logs (via webhook) |

## Google Account (john123a3@gmail.com)
- **Gmail:** ✅ Working — 501 unread (mostly old junk)
- **Calendar:** ✅ Working — empty, fresh
- **Drive:** ✅ Working — 7.45/15 GB used
- **Contacts:** Available
- **Keep:** Available
- **Tasks:** Available
- **Account name:** George Washington (legacy, not ours)

## GitHub
- **Account:** ZoroPoskai
- **Email:** john123a3@gmail.com
- **Repo:** ZoroPoskai/zoro-workspace (public)
- **SSH:** ed25519 key "Zoro OpenClaw Machine" added

## Console Stream
- **Webhook URL:** stored in `scripts/.console-webhook-url`
- **Service:** `zoro-console.service` (systemd user service, auto-starts)
- **How it works:** Tails journalctl → batches every 10s → posts to #console via Discord webhook
- **Zero LLM tokens** — pure bash, no AI involved

## Systemd Services
- `zoro-watcher.service` — Monitors & restarts OpenClaw gateway
- `zoro-console.service` — Streams logs to Discord #console

## Cron Jobs (OpenClaw)
- **The Watcher (L1):** Every 10min, health check via gemini flash lite
- **Status Ping:** Every 5min, posts to #status-log

## Machine
- **Hostname:** Zoro
- **CPU:** AMD Ryzen 5 4600H (12 threads)
- **RAM:** 14GB
- **GPU:** GTX 1650 4GB
- **Disk:** 234GB NVMe (~203GB free)
- **OS:** Ubuntu 24.04, kernel 6.17.0

## SSH
- **Key:** `~/.ssh/id_ed25519` (ed25519, added to GitHub)
- **Fingerprint:** SHA256:EwzU4a7hRnHKShsnmPT84D0qgxGkoJRHRnCxep0LFOc

## Browser
- **Profile:** "openclaw" (Chromium, managed by OpenClaw)
- **Currently logged into:** GitHub (ZoroPoskai), Google (john123a3@gmail.com)
