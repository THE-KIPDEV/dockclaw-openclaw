FROM coollabsio/openclaw:latest

USER root

# Replace nginx binary with wrapper that patches config at runtime.
# The entrypoint regenerates nginx config from templates, so build-time
# patches get overwritten. The wrapper patches right before nginx starts.
RUN NGINX_BIN=$(which nginx) && \
    mv "$NGINX_BIN" "${NGINX_BIN}-real" && \
    mkdir -p /home/node/.openclaw /home/node/workspace && \
    chown -R 1000:1000 /home/node

COPY nginx-wrapper.sh /usr/sbin/nginx
RUN chmod +x /usr/sbin/nginx

# Run as root so Railway volume mounts (owned by root) are writable.
