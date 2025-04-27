#!/bin/bash

# Load the secrets
if [ -f apim/secrets.env ]; then
  source apim/secrets.env
else
  echo "Secrets file not found!"
  exit 1
fi

# Step 1: Register DCR client
echo "Registering DCR client..."
DCR_RESPONSE=$(curl -sk -X POST https://localhost:9500/client-registration/v0.17/register \
-H "Authorization: Basic YWRtaW46YWRtaW4=" \
-H "Content-Type: application/json" \
-d '{
    "callbackUrl": "www.google.lk",
    "clientName": "rest_api_client",
    "owner": "admin",
    "grantType": "password refresh_token",
    "saasApp": true
}')
# Extract clientId and clientSecret using grep and awk
CLIENT_ID=$(echo $DCR_RESPONSE | grep -o '"clientId":"[^"]*' | awk -F'"' '{print $4}')
CLIENT_SECRET=$(echo $DCR_RESPONSE | grep -o '"clientSecret":"[^"]*' | awk -F'"' '{print $4}')

# Step 2: Base64 encode clientId:clientSecret
ENCODED_CREDENTIALS=$(echo -n "$CLIENT_ID:$CLIENT_SECRET" | base64)

# Step 3: Get access token
echo "Getting access token..."
ACCESS_TOKEN=$(curl -sk https://localhost:9500/oauth2/token \
-H "Authorization: Basic $ENCODED_CREDENTIALS" \
-d "grant_type=password&username=admin&password=admin&scope=apim:subscribe apim:app_manage apim:sub_manage apim:app_import_export apim:api_publish apim:api_manage" | grep -o '"access_token":"[^"]*' | awk -F'"' '{print $4}')

API_UUID=$(curl -sk "https://localhost:9500/api/am/devportal/v3/apis" | grep -o '"id":"[^"]*' | awk -F'"' '{print $4}')

echo "Enabling monetization for API..."
curl -sk -o /dev/null -X POST "https://localhost:9500/api/am/publisher/v4/apis/$API_UUID/monetize" \
-H "Authorization: Bearer $ACCESS_TOKEN" \
-H "Content-Type: application/json" \
-d "{
  \"enabled\": true,
  \"properties\": {
    \"ConnectedAccountKey\": \"$ConnectedAccountKey\"
  }
}"

echo "Creating App in Devportal..."
APPLICATION_UUID=$(curl -sk "https://localhost:9500/api/am/devportal/v3/applications?query=SampleMonetizationApp" \
  -H "Authorization: Bearer $ACCESS_TOKEN" | grep -o '"applicationId":"[^"]*' | awk -F'"' '{print $4}')
if [ ! -z "$APPLICATION_UUID" ]; then
  echo "Oops deleting an old app with the same name first..."
  curl -sk -H "Authorization: Bearer $ACCESS_TOKEN" \
    -X DELETE "https://localhost:9500/api/am/devportal/v3/applications/$APPLICATION_UUID"
fi

APPLICATION_UUID=$(curl -sk -X POST "https://localhost:9500/api/am/devportal/v3/applications" \
-H "Authorization: Bearer $ACCESS_TOKEN" \
-H "Content-Type: application/json" \
-d '{
  "name": "SampleMonetizationApp",
  "throttlingPolicy": "Unlimited",
  "description": "Sample App for Monetization",
  "tokenType": "JWT"
}' | grep -o '"applicationId":"[^"]*' | awk -F'"' '{print $4}')

echo "Subscribing to API..."
curl -sk -o /dev/null -X POST "https://localhost:9500/api/am/devportal/v3/subscriptions" \
-H "Authorization: Bearer $ACCESS_TOKEN" \
-H "Content-Type: application/json" \
-d "{
  \"applicationId\": \"$APPLICATION_UUID\",
  \"apiId\": \"$API_UUID\",
  \"throttlingPolicy\": \"SampleMonetizationPolicy\"
}"

echo "Generating Keys for App..."
RESPONSE=$(curl -sk -X POST "https://localhost:9500/api/am/devportal/v3/applications/$APPLICATION_UUID/generate-keys" \
-H "Authorization: Bearer $ACCESS_TOKEN" \
-H "Content-Type: application/json" \
-d '{
  "keyType": "PRODUCTION",
  "keyManager": "Resident Key Manager",
  "grantTypesToBeSupported": [
    "client_credentials"
  ],
  "validityTime": "3600"
}')
KEY_MAPPING_ID=$(echo "$RESPONSE" | grep -o '"keyMappingId":"[^"]*' | awk -F'"' '{print $4}')
CONSUMER_SECRET=$(echo "$RESPONSE" | grep -o '"consumerSecret":"[^"]*' | awk -F'"' '{print $4}')

echo "Generating Application Tokens..."
APP_ACCESS_TOKEN=$(curl -sk -X POST "https://localhost:9500/api/am/devportal/v3/applications/$APPLICATION_UUID/oauth-keys/$KEY_MAPPING_ID/generate-token" \
-H "Authorization: Bearer $ACCESS_TOKEN" \
-H "Content-Type: application/json" \
-d "{
  \"consumerSecret\": \"$CONSUMER_SECRET\",
  \"validityPeriod\": 3600,
  \"grantType\": \"CLIENT_CREDENTIALS\"
}" | grep -o '"accessToken":"[^"]*' | awk -F'"' '{print $4}')

echo "Making PizzaShackAPI calls..."
for i in {1..5}; do
  curl -sk -o /dev/null "https://localhost:8300/pizzashack/1.0.0/menu" \
    -H "accept: application/json" \
    -H "Authorization: Bearer $APP_ACCESS_TOKEN"
done
