#!/bin/sh

alias docker=nerdctl

docker compose down --remove-orphans
docker compose up -d

# Wait for the WSO2 API Manager to be ready with the PizzaShackAPI
while [[ $(curl -sk -o /dev/null -w "%{http_code}" https://localhost:8300/pizzashack/1.0.0/menu) != 401 ]]; do
    echo "Waiting for WSO2 API Manager to be ready with the sample PizzaShackAPI..."
    sleep 5
done

chmod +x ./apim/make-requests.sh
./apim/make-requests.sh

docker compose logs -f
