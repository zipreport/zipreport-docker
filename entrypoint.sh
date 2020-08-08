#!/usr/bin/env bash

ZPT_PATH="/opt/zptserver/"
CLI_PATH="/opt/zptcli/zpt-cli"
ZPT_OPTS="-addr=0.0.0.0 -storage=/tmp/zpt/ -cli=${CLI_PATH}"

# use ssl if not disabled
if [ -z "$NOSSL" ]; then
  echo "Enabling SSL"
  ZPT_OPTS+=" -certkey=${ZPT_PATH}/ssl/server.key -certificate=${ZPT_PATH}/ssl/server.crt"
fi

# use api key if available
if [ ! -z "$API_KEY" ]; then
  echo "Using API Key"
  ZPT_OPTS+=" -apikey=${API_KEY}"
fi

# enable debug
if [ ! -z "$DEBUG" ]; then
  echo "Enabling DEBUG mode"
  ZPT_OPTS+=" -debug"
fi

/opt/zptserver/zipreport-server $ZPT_OPTS
