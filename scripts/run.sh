#!/usr/bin/env bash

set -exo pipefail

cd runner

# wait for the docker service to be ready

until sudo docker ps > /dev/null 2>&1; do sleep 10s; done

if [ "$1" = "true" ];
then
  # stop the delegate
  sudo docker compose down
  # give some slack for the vm to be shutdown
  # allowing the terraform destroy to run w/o errors
  sleep 30s
else
  # start the delegate
  sudo docker compose up -d
fi