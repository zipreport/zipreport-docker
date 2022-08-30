# =============================================================================
# Docker recipe ZPT Server
# =============================================================================
FROM golang:1.14-buster AS server

# Dependencies
RUN apt update \
     && apt install ca-certificates git make

# Set the working directory outside $GOPATH to enable the support for modules.
WORKDIR /src

# Build main module
RUN git clone https://github.com/zipreport/zipreport-server.git /src

RUN make all
RUN make certificate

# =============================================================================
# Running container for the binaries
# =============================================================================
FROM node:14-buster-slim AS final

RUN apt update
RUN apt install -yyq gnupg ca-certificates
RUN apt install -yyq git
RUN apt install -yyq libappindicator1 libasound2 libatk1.0-0 libc6 libcairo2 libcups2 \
libdbus-1-3 libexpat1 libfontconfig1 libgcc1 libgconf-2-4 libgdk-pixbuf2.0-0 \
libglib2.0-0 libgtk-3-0 libnspr4 libnss3 libpango-1.0-0 libpangocairo-1.0-0 libdrm2 \
xvfb libstdc++6 libx11-6 libx11-xcb1 libxcb1 libxcomposite1 libxcursor1 libgbm-dev \
libxdamage1 libxext6 libxfixes3 libxi6 libxrandr2 libxrender1 libxss1 libxtst6 \
fonts-freefont-ttf fonts-liberation fonts-noto-color-emoji fonts-wqy-zenhei

# Clean up APT when done.
RUN apt-get clean \
    && apt autoremove -y \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

USER root

# Create installation directories
RUN mkdir /src
RUN mkdir /opt/zptcli
RUN mkdir /opt/zptserver

# startup file
COPY entrypoint.sh /usr/local/bin/

# Create user
ENV USER=godaemon

RUN useradd -ms /bin/false $USER
RUN usermod -a -G audio,video $USER

# Adjust folder permissions
RUN chown -R $USER /src
RUN chown -R $USER /opt/zptserver
RUN chown -R $USER /opt/zptcli

# Create user required folders
USER "$USER"
RUN mkdir -p /home/$USER/Downloads
RUN mkdir /tmp/zpt

# Import server binaries
COPY --from=server /src/bin/ /opt/zptserver/
COPY --from=server /src/cert/ /opt/zptserver/ssl/

# Build electron cli
WORKDIR /src
# Build main module
RUN git clone https://github.com/zipreport/zipreport-cli.git /src
RUN npm install
RUN npm run build
RUN mv build/zpt-cli-linux-x64/* /opt/zptcli/

# tidy up & cleanup
USER root
RUN chown $USER /opt/zptserver/ssl/*
RUN chmod 400 /opt/zptserver/ssl/*
RUN chmod 4755 /opt/zptcli/chrome-sandbox
RUN rm -rf /home/$USER/.node
RUN apt remove --purge -y git
RUN rm -rf /src/*

# Daemon user
USER "$USER"
# Declare the port on which the service will be exposed, > 1024
EXPOSE 6543

WORKDIR /opt/zptserver

ENTRYPOINT ["entrypoint.sh"]
