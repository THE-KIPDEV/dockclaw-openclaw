FROM coollabsio/openclaw:latest

# Fix: Remove the "browser" upstream from nginx config that causes
# "host not found in upstream" when running without the browser sidecar.
USER root
RUN if [ -f /etc/nginx/conf.d/openclaw.conf ]; then \
      sed -i '/upstream browser/,/}/d' /etc/nginx/conf.d/openclaw.conf; \
      sed -i '/location.*browser/,/}/d' /etc/nginx/conf.d/openclaw.conf; \
    fi && \
    find /app/scripts -name '*.conf' -o -name '*.conf.template' 2>/dev/null | \
      xargs -r sed -i '/upstream browser/,/}/d' 2>/dev/null

# Add entrypoint wrapper that fixes volume permissions at runtime
# Railway volumes mount as root — this fixes ownership before starting as node
COPY entrypoint-wrapper.sh /entrypoint-wrapper.sh
RUN chmod +x /entrypoint-wrapper.sh

# Stay as root so the wrapper can chown the volume mount
# The wrapper drops to node before exec'ing the real entrypoint
ENTRYPOINT ["/entrypoint-wrapper.sh"]
