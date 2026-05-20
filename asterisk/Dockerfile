FROM docker.io/library/alpine:3.19

# Install Asterisk and dependencies
RUN apk add --no-cache \
    asterisk \
    asterisk-sample-config \
    asterisk-sounds-en \
    asterisk-sounds-moh \
    curl \
    bash

# Create necessary directories
RUN mkdir -p /etc/asterisk \
    /var/lib/asterisk \
    /var/log/asterisk \
    /var/spool/asterisk \
    /var/run/asterisk

# Copy configuration files (if any exist)
COPY config/ /etc/asterisk/

# Create health check script
COPY health-check.sh /usr/local/bin/health-check.sh
RUN chmod +x /usr/local/bin/health-check.sh

# Expose SIP and RTP ports
# 5060: SIP signaling (UDP)
# 10000-10100: RTP media streams (UDP)
EXPOSE 5060/udp
EXPOSE 10000-10100/udp

# Expose ARI port for orchestrator
EXPOSE 8088/tcp

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD /usr/local/bin/health-check.sh

# Run Asterisk in foreground
CMD ["/usr/sbin/asterisk", "-f", "-vvv", "-g", "-c"]
