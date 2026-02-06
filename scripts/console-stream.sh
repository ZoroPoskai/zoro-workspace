#!/usr/bin/env bash
# Console Stream — Pipes OpenClaw gateway logs to Discord #console channel
# Runs as a background daemon. Zero LLM tokens — pure log forwarding.
#
# Usage: ./console-stream.sh [start|stop|status]

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PID_FILE="$SCRIPT_DIR/.console-stream.pid"
LOG_FILE="$SCRIPT_DIR/.console-stream.log"
WEBHOOK_URL_FILE="$SCRIPT_DIR/.console-webhook-url"

# Load secrets from .env
if [[ -f "$SCRIPT_DIR/.env" ]]; then
    source "$SCRIPT_DIR/.env"
fi

# Discord config
CHANNEL_ID="1469435745927168186"
BOT_TOKEN="${DISCORD_BOT_TOKEN:?DISCORD_BOT_TOKEN not set — add it to scripts/.env}"

# Streaming config
BATCH_INTERVAL=10        # seconds between Discord posts
MAX_MSG_LENGTH=1900      # Discord limit is 2000, leave margin
JOURNAL_UNIT="openclaw-gateway"

get_or_create_webhook() {
    local webhook_url

    # Check if we already have a webhook
    if [[ -f "$WEBHOOK_URL_FILE" ]]; then
        webhook_url=$(cat "$WEBHOOK_URL_FILE")
        # Verify it still works
        local status
        status=$(curl -s -o /dev/null -w "%{http_code}" "$webhook_url")
        if [[ "$status" == "200" ]]; then
            echo "$webhook_url"
            return
        fi
    fi

    # Create a new webhook
    local response
    response=$(curl -s -X POST \
        "https://discord.com/api/v10/channels/${CHANNEL_ID}/webhooks" \
        -H "Authorization: Bot ${BOT_TOKEN}" \
        -H "Content-Type: application/json" \
        -d '{"name":"Zoro Console","avatar":null}')

    local webhook_id webhook_token
    webhook_id=$(echo "$response" | jq -r '.id // empty')
    webhook_token=$(echo "$response" | jq -r '.token // empty')

    if [[ -z "$webhook_id" || -z "$webhook_token" ]]; then
        echo "ERROR: Failed to create webhook: $response" >&2
        exit 1
    fi

    webhook_url="https://discord.com/api/v10/webhooks/${webhook_id}/${webhook_token}"
    echo "$webhook_url" > "$WEBHOOK_URL_FILE"
    echo "$webhook_url"
}

send_to_discord() {
    local webhook_url="$1"
    local content="$2"

    # Escape for JSON
    local escaped
    escaped=$(printf '%s' "$content" | python3 -c 'import sys,json; print(json.dumps(sys.stdin.read()))')

    curl -s -X POST "$webhook_url" \
        -H "Content-Type: application/json" \
        -d "{\"content\":${escaped}}" > /dev/null 2>&1
}

stream_logs() {
    local webhook_url
    webhook_url=$(get_or_create_webhook)
    echo "$(date -Iseconds) Webhook ready. Streaming logs..." >> "$LOG_FILE"

    local buffer=""
    local last_send=$(date +%s)

    # Tail journalctl for the openclaw gateway process
    # Since it's not a systemd service, we tail by the PID's syslog identifier
    journalctl --user -f --no-pager --output=short-iso 2>/dev/null | while IFS= read -r line; do
        # Filter: only openclaw-related lines
        if [[ "$line" == *"openclaw"* ]] || [[ "$line" == *"node["* ]]; then
            # Clean up the line — remove the hostname and PID noise
            local clean_line
            clean_line=$(echo "$line" | sed 's/^[^ ]* [^ ]* node\[[0-9]*\]: //' | sed 's/^[0-9T:.Z-]* //')

            # Skip noisy/spam lines
            if [[ "$clean_line" == *"google tool schema snapshot"* ]]; then
                continue
            fi
            if [[ "$clean_line" == *"typing TTL"* ]]; then
                continue
            fi

            # Add to buffer
            if [[ -n "$buffer" ]]; then
                buffer="${buffer}\n${clean_line}"
            else
                buffer="${clean_line}"
            fi
        fi

        # Check if it's time to send
        local now=$(date +%s)
        local elapsed=$(( now - last_send ))

        if [[ $elapsed -ge $BATCH_INTERVAL && -n "$buffer" ]]; then
            # Truncate if too long
            local msg
            msg=$(printf '%b' "$buffer" | head -c $MAX_MSG_LENGTH)

            send_to_discord "$webhook_url" "\`\`\`\n${msg}\n\`\`\`"
            buffer=""
            last_send=$now
        fi
    done
}

case "${1:-start}" in
    start)
        if [[ -f "$PID_FILE" ]] && kill -0 "$(cat "$PID_FILE")" 2>/dev/null; then
            echo "Console stream already running (PID $(cat "$PID_FILE"))"
            exit 0
        fi
        echo "Starting console stream..."
        nohup bash "$0" _run >> "$LOG_FILE" 2>&1 &
        echo $! > "$PID_FILE"
        echo "Started (PID $!)"
        ;;
    stop)
        if [[ -f "$PID_FILE" ]]; then
            kill "$(cat "$PID_FILE")" 2>/dev/null || true
            rm -f "$PID_FILE"
            echo "Stopped"
        else
            echo "Not running"
        fi
        ;;
    status)
        if [[ -f "$PID_FILE" ]] && kill -0 "$(cat "$PID_FILE")" 2>/dev/null; then
            echo "Running (PID $(cat "$PID_FILE"))"
        else
            echo "Not running"
        fi
        ;;
    _run)
        stream_logs
        ;;
    *)
        echo "Usage: $0 {start|stop|status}"
        exit 1
        ;;
esac
