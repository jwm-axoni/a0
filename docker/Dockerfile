# Unified Agent Zero Dockerfile
FROM kalilinux/kali-rolling

# Build arguments
ARG BRANCH=main
ARG CACHE_DATE=none

# Set environment variables
ENV BRANCH=$BRANCH
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8
ENV TZ=UTC

# Set locale and timezone
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y locales tzdata && \
    sed -i -e 's/# \(en_US\.UTF-8 .*\)/\1/' /etc/locale.gen && \
    dpkg-reconfigure --frontend=noninteractive locales && \
    update-locale LANG=en_US.UTF-8 LANGUAGE=en_US:en LC_ALL=en_US.UTF-8 && \
    ln -sf /usr/share/zoneinfo/UTC /etc/localtime && \
    echo "UTC" > /etc/timezone && \
    dpkg-reconfigure -f noninteractive tzdata

# Copy base system files
COPY base_fs/ /
COPY run_fs/ /

# Install base packages (consolidated for better caching)
RUN bash /ins/install_base_packages1.sh && \
    bash /ins/install_base_packages2.sh && \
    bash /ins/install_base_packages3.sh && \
    bash /ins/install_base_packages4.sh

# Install Python
RUN bash /ins/install_python.sh

# Configure git for large repository clones before SearxNG installation
RUN git config --global http.postBuffer 524288000 && \
    git config --global http.lowSpeedLimit 0 && \
    git config --global http.lowSpeedTime 999999 && \
    git config --global core.preloadindex true && \
    git config --global core.fscache true

# Install SearxNG
RUN bash /ins/install_searxng.sh

# Configure SSH
RUN bash /ins/configure_ssh.sh

# Base system setup
RUN bash /ins/after_install.sh

# Agent Zero specific installation
RUN bash /ins/pre_install.sh $BRANCH

# Install Agent Zero
RUN bash /ins/install_A0.sh $BRANCH

# Install additional software
RUN bash /ins/install_additional.sh $BRANCH

# Final Agent Zero installation (cache busting)
RUN echo "cache buster $CACHE_DATE" && bash /ins/install_A02.sh $BRANCH

# Post installation
RUN bash /ins/post_install.sh $BRANCH

# Set executable permissions
RUN chmod +x /exe/initialize.sh /exe/run_A0.sh /exe/run_searxng.sh /exe/run_tunnel_api.sh

# Set environment variables (container uses port 80 internally)
ENV WEB_UI_PORT=80
ENV PORT=80
ENV WATCH=1

# Expose ports (container listens on 80, mapped to host 8080)
EXPOSE 22 80 9000-9009

# Health check (check internal port 80)
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:80/ || exit 1

# Initialize and start services
CMD /exe/initialize.sh "$BRANCH"
