FROM debian:bookworm-slim

LABEL author="you" maintainer="you@example.com"
LABEL org.opencontainers.image.description="Pterodactyl egg image for Java Minecraft servers"

# --- Base packages -----------------------------------------------------
RUN apt-get update && apt-get install -y --no-install-recommends \
        curl \
        ca-certificates \
        gnupg \
        tar \
        git \
        tzdata \
        iproute2 \
        openssl \
        sqlite3 \
        libfreetype6 \
        fontconfig \
    && rm -rf /var/lib/apt/lists/*

# --- Java runtimes -------------------------------------------------------
# Modern Minecraft (1.20.5+) needs Java 21; older versions need Java 17/8.
# Installing Temurin 21 as the primary JDK. Add more versions below if you
# need to support older Minecraft releases in the same image.
RUN curl -fsSL https://packages.adoptium.net/artifactory/api/gpg/key/public | gpg --dearmor -o /usr/share/keyrings/adoptium.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/adoptium.gpg] https://packages.adoptium.net/artifactory/deb bookworm main" > /etc/apt/sources.list.d/adoptium.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends temurin-21-jdk \
    && rm -rf /var/lib/apt/lists/*

# --- Pterodactyl conventions ---------------------------------------------
# Wings always runs the container as this user/group and expects the
# server files to live in /home/container.
RUN useradd -m -d /home/container -s /bin/bash container

USER container
ENV USER=container HOME=/home/container
WORKDIR /home/container

COPY --chown=container:container entrypoint.sh /entrypoint.sh

CMD ["/bin/bash", "/entrypoint.sh"]
