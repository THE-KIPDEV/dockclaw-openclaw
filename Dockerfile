FROM coollabsio/openclaw:latest

USER root

# Intercept nginx binary to fix browser upstream at runtime.
# The entrypoint regenerates nginx config from templates, so build-time
# patches get overwritten. This wrapper patches the config right before
# nginx actually starts.
RUN NGINX_BIN=$(which nginx) && \
    mv "$NGINX_BIN" "${NGINX_BIN}-real" && \
    printf '#!/bin/sh\n\
# Remove browser upstream that causes "host not found" without browser sidecar\n\
for f in /etc/nginx/conf.d/*.conf; do\n\
  sed -i "/upstream browser/,/}/d" "$f" 2>/dev/null\n\
  sed -i "/location.*\\/browser/,/}/d" "$f" 2>/dev/null\n\
done\n\
exec %s-real "$@"\n' "$NGINX_BIN" > "$NGINX_BIN" && \
    chmod +x "$NGINX_BIN" && \
    # Ensure dirs exist (volume may override at runtime)
    mkdir -p /home/node/.openclaw /home/node/workspace && \
    chown -R 1000:1000 /home/node

# Run as root so Railway volume mounts (owned by root) are writable.
