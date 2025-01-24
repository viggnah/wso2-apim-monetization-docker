#!/bin/sh

# alias docker=nerdctl

docker compose down --remove-orphans
docker compose up -d

chmod +x ./elk/kibana-setup.sh
./elk/kibana-setup.sh

while [[ $(curl -sk -o /dev/null -w "%{http_code}" https://localhost:8300/pizzashack/1.0.0/menu) != 401 ]]; do
    echo "Hold on... waiting for WSO2 API Manager to be ready with the sample PizzaShackAPI"
    sleep 10
done

chmod +x ./apim/make-requests.sh
./apim/make-requests.sh

echo -e "\n\n--- Service Access Information ---"
echo "API Manager"
echo "URL: https://localhost:9500/publisher/apis"
echo "Username: admin"
echo "Password: admin"

echo -e "\nKibana Dashboard"
echo "URL: http://localhost:5601/app/dashboards#/view/f954a940-6ed4-11ec-9007-b93f9eb88870"
echo "Username: elastic"
echo "Password: changeme"

docker compose logs -f
