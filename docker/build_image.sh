#!/bin/bash

cd ..

export DOCKER_BUILDKIT=1
docker build -t registry.gitlab.com/comquestventures/typhon-cloud:px4 .

# --rm: remove container after exit
# --network host: use the same network as the host (https://docs.docker.com/network/host/)
docker run -i --rm --network host registry.gitlab.com/comquestventures/typhon-cloud:px4
