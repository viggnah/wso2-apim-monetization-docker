#!/bin/bash

# alias docker=nerdctl

chmod +x ./apim/remove-subs.sh
./apim/remove-subs.sh

docker compose down --remove-orphans
