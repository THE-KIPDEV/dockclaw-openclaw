FROM coollabsio/openclaw:latest

# Fix: Remove the "browser" upstream from nginx config that causes
# "host not found in upstream" when running without the browser sidecar.
USER root
RUN if [ -f /etc/nginx/conf.d/openclaw.conf ]; then \
      sed -i '/upstream browser/,/}/d' /etc/nginx/conf.d/openclaw.conf; \
      sed -i '/location.*browser/,/}/d' /etc/nginx/conf.d/openclaw.conf; \
    fi && \
    find /app/scripts -name '*.conf' -o -name '*.conf.template' 2>/dev/null | \
      xargs -r sed -i '/upstream browser/,/}/d' 2>/dev/null && \
    # Ensure dirs exist (volume may override at runtime)
    mkdir -p /home/node/.openclaw /home/node/workspace && \
    chown -R 1000:1000 /home/node

# Run as root so volume mounts (owned by root) are writable.
# Security boundary is the Railway container isolation, not the UID.
# The original entrypoint handles everything else.
