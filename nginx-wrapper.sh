#!/bin/sh
# Patch nginx config before starting
for f in /etc/nginx/conf.d/*.conf; do
  # 1. Remove browser upstream (no browser sidecar)
  sed -i '/upstream browser/,/}/d' "$f" 2>/dev/null
  sed -i '/location.*\/browser/,/}/d' "$f" 2>/dev/null
  # 2. Disable auth_basic on WebSocket locations so browser WS API works
  sed -i '/location.*\/ws/,/}/{s/auth_basic .*;//}' "$f" 2>/dev/null
  sed -i '/location.*\/gateway/,/}/{s/auth_basic .*;//}' "$f" 2>/dev/null
  sed -i '/location.*\/socket/,/}/{s/auth_basic .*;//}' "$f" 2>/dev/null
done
# Find and exec the real nginx binary
exec "$(dirname "$0")/nginx-real" "$@"
