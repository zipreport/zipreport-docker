# Zipreport-server docker image

Ready-to-use docker image recipe that includes zipreport-server and zipreport-cli, based on Debian (buster).

Don't forget to checkout with "--recurse-submodules" to clone the related source repositories!



## Available environment variables

|Name|Description|
|---|---|
|NOSSL| If not empty, disable SSL|
|API_KEY| API Key to use for authentication|
|DEBUG| If not empty, enable debug|

## Build & Run

```shell script
$ docker build -t zipreport .
$ docker run -d -p 6543:6543 zipreport
```