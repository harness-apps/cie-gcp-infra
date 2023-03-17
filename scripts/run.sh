#!/usr/bin/env bash

set -exo pipefail

# start the delegate

cd runner

# wait for the docker service to be ready

until sudo docker ps > /dev/null 2>&1; do sleep 10s; done

# start the delegate
sudo docker compose up -d 