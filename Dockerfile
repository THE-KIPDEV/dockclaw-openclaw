FROM coollabsio/openclaw:latest

# Fix: Remove the "browser" upstream from nginx config that causes
# "host not found in upstream" when running without the browser sidecar.
# The browser upstream is only needed for the CDP browser automation feature.
# Users who need it can configure BROWSER_CDP_URL later.
USER root
RUN if [ -f /etc/nginx/conf.d/openclaw.conf ]; then \
      sed -i '/upstream browser/,/}/d' /etc/nginx/conf.d/openclaw.conf; \
      sed -i '/location.*browser/,/}/d' /etc/nginx/conf.d/openclaw.conf; \
    fi && \
    # Also fix any nginx template if it exists
    find /app/scripts -name '*.conf' -o -name '*.conf.template' 2>/dev/null | \
      xargs -r sed -i '/upstream browser/,/}/d' 2>/dev/null; \
    # Ensure /home/node dirs are writable (for Railway volume mounts)
    mkdir -p /home/node/.openclaw /home/node/workspace && \
    chown -R 1000:1000 /home/node
USER node
