# Zipreport-server docker image


***NOTICE** This repository is deprecated; please use zipreport-server v2.0.0 or later.


Ready-to-use docker image recipe that includes zipreport-server and zipreport-cli, based on Debian (buster).
Both zipreport-server and zipreport-cli are built from their respective master branches.

## Available environment variables

|Name|Description|
|---|---|
|NOSSL| If not empty, disable SSL|
|API_KEY| API Key to use for authentication|
|DEBUG| If not empty, enable debug|

## Build & Run


This docker image uses seccomp to allow chromium to run sandboxed within docker. This is possible thanks to 
[Jessie Frazelle seccomp profile for Chrome](https://github.com/jessfraz/dotfiles/blob/master/etc/docker/seccomp/chrome.json),
under MIT license.


Build and start the container directly:

```shell
$ docker build . --tag zipreport:latest
$ docker container run --rm --security-opt seccomp=$(pwd)/seccomp/chrome.json zipreport:latest
```

Using docker-compose:
```yaml
version: "3.8"
services:
  zipreport:
    image: zipreport:latest
    environment:
      - API_KEY="VerySecretKey" 
    security_opt:
      - seccomp:seccomp/chrome.json
```

Please note, security_opt is currently ignored in swarm mode (docker stack deploy)

## License

This repository is licensed under MIT license.
The file seccomp/chome.json is licensed under MIT license by Jessie Frazelle, and was taken from
[Jessie Frazelle dotfiles repository](https://github.com/jessfraz/dotfiles)
