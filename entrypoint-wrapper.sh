#!/bin/sh
set -e

# Fix Railway volume permissions
# Railway mounts volumes as root, but OpenClaw runs as uid 1000 (node)
chown -R 1000:1000 /home/node 2>/dev/null || true

# Find and exec the original entrypoint as node user
if command -v su-exec >/dev/null 2>&1; then
  exec su-exec node /app/scripts/entrypoint.sh "$@"
elif command -v gosu >/dev/null 2>&1; then
  exec gosu node /app/scripts/entrypoint.sh "$@"
else
  exec su -s /bin/sh node -c "/app/scripts/entrypoint.sh $*"
fi
