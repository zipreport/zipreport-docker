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
COPY ./server ./
RUN make all
RUN make certificate

# =============================================================================
# Running container for the binaries
# =============================================================================
FROM node:14-buster AS final

RUN apt update
RUN apt install -yyq gnupg ca-certificates
RUN apt install -yyq libappindicator1 libasound2 libatk1.0-0 libc6 libcairo2 libcups2 \
libdbus-1-3 libexpat1 libfontconfig1 libgcc1 libgconf-2-4 libgdk-pixbuf2.0-0 \
libglib2.0-0 libgtk-3-0 libnspr4 libnss3 libpango-1.0-0 libpangocairo-1.0-0 libdrm2 \
xvfb libstdc++6 libx11-6 libx11-xcb1 libxcb1 libxcomposite1 libxcursor1 libgbm-dev \
libxdamage1 libxext6 libxfixes3 libxi6 libxrandr2 libxrender1 libxss1 libxtst6 \
fonts-freefont-ttf fonts-liberation
    
# Clean up APT when done.
RUN apt-get clean \
    && apt autoremove -y \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ENV USER=godaemon
ENV UID=64000
ENV GID=64000
USER root

RUN addgroup --gid "$GID" "$USER"
RUN useradd -r -u "$UID" -g "$USER" -G audio,video "$USER" 

RUN mkdir mkdir -p /home/$USER/Downloads
RUN chown -R $USER:$USER /home/$USER

# Build electron cli
WORKDIR /src
# Build main module
COPY ./cli ./
RUN npm install
RUN npm run build
RUN mkdir /opt/zptcli
RUN cp -r build/zpt-cli-linux-x64/* /opt/zptcli/
RUN chown -R "$USER" /opt/zptcli

# cleanup
RUN rm -rf /src/*

# Import server binaries
COPY --from=server /src/bin/ /opt/zptserver/
COPY --from=server /src/cert/ /opt/zptserver/ssl/
RUN chown -R "$USER" /opt/zptserver/ssl
RUN chmod 400 /opt/zptserver/ssl/*


COPY entrypoint.sh /usr/local/bin/

# Initialize stuff
USER "$USER":"$USER"
RUN mkdir /tmp/zpt

# Declare the port on which the service will be exposed, > 1024
EXPOSE 6543

# Run Service
USER "$USER":"$USER"

WORKDIR /opt/zptserver

ENTRYPOINT ["entrypoint.sh"]
