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
# Docker recipe ZPT Cli
# =============================================================================
FROM node:14-buster AS cli

WORKDIR /src
# Build main module
COPY ./cli ./
RUN npm install
RUN npm run build

# =============================================================================
# Running container for the binaries
# =============================================================================
FROM debian:buster as final

RUN apt update \
    && apt install -y gnupg

# Clean up APT when done.
RUN apt-get clean \
    && apt autoremove -y \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ENV USER=godaemon
ENV UID=64000
ENV GID=64000
USER root

RUN addgroup --gid "$GID" "$USER" \
    && adduser \
    --disabled-password \
    --gecos "" \
    --ingroup "$USER" \
    --uid "$UID" \
    "$USER"

# Import server binaries
COPY --from=server /src/bin/ /opt/zptserver/
COPY --from=server /src/cert/ /opt/zptserver/ssl/
RUN chown -R "$USER" /opt/zptserver/ssl
RUN chmod 400 /opt/zptserver/ssl/*

# Import electron cli
COPY --from=cli /src/build/zpt-cli-linux-x64/ /opt/zptcli/
RUN chown -R "$USER" /opt/zptcli

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