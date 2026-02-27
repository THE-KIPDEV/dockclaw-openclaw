FROM coollabsio/openclaw:latest

USER root

# Replace nginx binary with wrapper that patches config at runtime.
RUN NGINX_BIN=$(which nginx) && \
    mv "$NGINX_BIN" "${NGINX_BIN}-real" && \
    mkdir -p /home/node/.openclaw /home/node/workspace && \
    chown -R 1000:1000 /home/node

# Copy wrapper to same directory as the original nginx binary
COPY nginx-wrapper.sh /usr/sbin/nginx
RUN chmod +x /usr/sbin/nginx && \
    # Also link in case nginx was elsewhere
    REAL=$(find / -name 'nginx-real' -type f 2>/dev/null | head -1) && \
    if [ -n "$REAL" ] && [ "$(dirname "$REAL")" != "/usr/sbin" ]; then \
      cp /usr/sbin/nginx "$(dirname "$REAL")/nginx"; \
    fi

# Base config: allow Control UI from any origin (Railway domains are dynamic)
COPY base-config.json /etc/openclaw/base-config.json
ENV OPENCLAW_CUSTOM_CONFIG=/etc/openclaw/base-config.json

# Run as root so Railway volume mounts (owned by root) are writable.
