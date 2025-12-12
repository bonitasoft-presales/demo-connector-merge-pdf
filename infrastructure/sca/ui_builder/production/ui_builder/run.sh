#!/usr/bin/env sh

docker run \
-p 8086:80 \
-e BONITA_API_URL=http://host.docker.internal:8080/bonita/API \
lub-marine:1.0
