#!/bin/bash

# alias docker=nerdctl

# Load the secrets
ENV_FILE="./apim/secrets.env"
if [ -f "$ENV_FILE" ]; then
  printf "✅ Stripe keys already provided; stored at $ENV_FILE\n"
  source $ENV_FILE
else
  echo "$ENV_FILE not found! This must be the first time you are running the script. Please enter the keys you obtained from Stripe, these will be stored and reused on subsequent runs."

  # Prompt securely for keys
  read -p "Enter BillingEnginePlatformAccountKey (similar to sk_test_...): " BILLING_KEY
  read -p "Enter ConnectedAccountKey (similar to acct_...): " CONNECTED_KEY

  # Validate keys 
  if [ -z "$BILLING_KEY" ] || [ -z "$CONNECTED_KEY" ]; then
      echo "ERROR: Both keys must be provided."
      exit 1
  fi

  # Create the .env file
  printf "= Creating $ENV_FILE..."
  {
    echo "BillingEnginePlatformAccountKey=$BILLING_KEY"
    echo "ConnectedAccountKey=$CONNECTED_KEY"
  } > "$ENV_FILE" || { echo "Error: Failed to write to $ENV_FILE. Check permissions."; exit 1; }

  # Set secure permissions
  chmod 600 "$ENV_FILE"
  source $ENV_FILE

  printf "\r✅ Created $ENV_FILE with secure permissions.\n"
fi

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

chmod +x ./apim/publish-monetization-data.sh
./apim/publish-monetization-data.sh

# --- Function to print a separator line ---
print_separator() {
  printf '=%.0s' {1..60} # Print 60 '=' characters
  printf '\n'
}

# --- Main Output ---
print_separator
printf '=== API Manager Access Information ===\n\n'

# Use printf for aligned output. Adjust "-18s" based on the longest label.
printf "  %-18s: %s\n" "Publisher Portal" "https://localhost:9500/publisher/apis"
printf "  %-18s: %s\n" "Developer Portal" "https://localhost:9500/devportal"
printf "  %-18s: %s\n" "Admin Portal"     "https://localhost:9500/admin/dashboard"
printf "\n"
printf "  %-18s: %s\n" "Username"         "admin"
printf "  %-18s: %s\n" "Password"         "admin"
printf "\n"

print_separator
printf "=== Kibana Dashboard Access ===\n\n"

printf "  %-18s: %s\n" "URL"              "http://localhost:5601/app/dashboards#/view/f954a940-6ed4-11ec-9007-b93f9eb88870"
printf "\n"
printf "  %-18s: %s\n" "Username"         "elastic"
printf "  %-18s: %s\n" "Password"         "changeme"
printf "\n"

print_separator
