#!/bin/sh

# alias docker=nerdctl

chmod +x ./stop.sh
./stop.sh

docker compose up -d

chmod +x ./elk/kibana-setup.sh
./elk/kibana-setup.sh

spin='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
i=0
seconds=0

while [[ $(curl -sk -o /dev/null -w "%{http_code}" https://localhost:8300/pizzashack/1.0.0/menu) != 401 ]]; do
    i=$(( (i+1) % ${#spin} ))
    message="${spin:$i:1} WSO2 API Manager with sample PizzaShackAPI"
    timer=$(printf "%5.1fs" "$seconds")
    printf "\r%*s\r%s" $(tput cols) "$timer" "$message";

    sleep 0.1
    seconds=$(echo "$seconds + 0.1" | bc)
done
printf "\r✅ WSO2 API Manager with sample PizzaShackAPI\n"

chmod +x ./apim/make-requests.sh
./apim/make-requests.sh

echo "\n\n--- Service Access Information ---"
echo "API Manager"
echo "URL: https://localhost:9500/publisher/apis"
echo "Username: admin"
echo "Password: admin"

echo "\nKibana Dashboard"
echo "URL: http://localhost:5601/app/dashboards#/view/f954a940-6ed4-11ec-9007-b93f9eb88870"
echo "Username: elastic"
echo "Password: changeme"
echo "\n"
