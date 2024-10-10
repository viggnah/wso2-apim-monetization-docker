#!/bin/sh

alias docker=nerdctl

docker compose down --remove-orphans
docker compose up -d

# Wait for the WSO2 API Manager to be ready with the PizzaShackAPI
# while [[ $(curl -sk -w ''%{http_code}'' https://localhost:9500/api/am/gateway/v2/server-startup-healthcheck) != "200" ]]; do
#     echo "Waiting for WSO2 API Manager to start..."
#     sleep 5
# done

# chmod +x ./apim/make_reqs.sh
# ./apim/make_reqs.sh

docker compose logs -f
