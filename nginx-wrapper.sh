#!/bin/sh
# Patch nginx config before starting
for f in /etc/nginx/conf.d/*.conf; do
  # 1. Disable basic auth entirely — security relies on:
  #    - Railway domain URL as shared secret (random hash, not guessable)
  #    - OpenClaw gateway token for API auth
  #    - URL only exposed to Clerk-authenticated users
  sed -i 's/auth_basic .*;//g' "$f" 2>/dev/null
  sed -i 's/auth_basic_user_file .*;//g' "$f" 2>/dev/null
  # 2. Remove browser upstream & location — the browser sidecar doesn't exist
  #    in our image, and nginx crashes if it can't resolve the upstream host.
  sed -i '/upstream browser/,/}/d' "$f" 2>/dev/null
  sed -i '/location.*\/browser/,/}/d' "$f" 2>/dev/null
  # 3. Remove restrictive framing headers so dashboard can embed via iframe
  sed -i '/add_header X-Frame-Options/d' "$f" 2>/dev/null
  sed -i '/add_header Content-Security-Policy/d' "$f" 2>/dev/null
  # 4. Strip framing headers sent by the upstream gateway (proxy_hide_header)
  #    add_header only removes nginx-added headers; the gateway also sends them
  sed -i '/location/a\        proxy_hide_header X-Frame-Options;\n        proxy_hide_header Content-Security-Policy;' "$f" 2>/dev/null
done
# Find and exec the real nginx binary
exec "$(dirname "$0")/nginx-real" "$@"
