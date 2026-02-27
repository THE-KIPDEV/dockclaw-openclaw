#!/bin/sh
# Patch nginx config before starting
for f in /etc/nginx/conf.d/*.conf; do
  # 1. Remove browser upstream (no browser sidecar)
  sed -i '/upstream browser/,/}/d' "$f" 2>/dev/null
  sed -i '/location.*\/browser/,/}/d' "$f" 2>/dev/null
  # 2. Disable basic auth entirely — security relies on:
  #    - Railway domain URL as shared secret (random hash, not guessable)
  #    - OpenClaw gateway token for API auth
  #    - URL only exposed to Clerk-authenticated users
  sed -i 's/auth_basic .*;//g' "$f" 2>/dev/null
  sed -i 's/auth_basic_user_file .*;//g' "$f" 2>/dev/null
done
# Find and exec the real nginx binary
exec "$(dirname "$0")/nginx-real" "$@"
