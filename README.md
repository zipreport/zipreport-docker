# Zipreport-server docker image

Ready-to-use docker image recipe that includes zipreport-server and zipreport-cli, based on Debian (buster).

Don't forget to checkout with "--recurse-submodules" to clone the related source repositories!


## Security warning

This dockerized zipreport-server uses zipreport-cli with sanboxing disabled (--no-sandbox), due to docker limitations. This is a pontential security risk,
specially if rendering external resources. Be sure to understand the implications of this for your own particular setup.

A more secure way of running zipreport-server and zipreport-cli would be to have a dedicated VM, where the
zipreport-cli process could be executed in sandbox mode.


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
