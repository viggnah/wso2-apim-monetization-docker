#!/bin/sh

# alias docker=nerdctl

# Step 1: Register DCR client
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
ACCESS_TOKEN=$(curl -sk https://localhost:9500/oauth2/token \
-H "Authorization: Basic $ENCODED_CREDENTIALS" \
-d "grant_type=password&username=admin&password=admin&scope=apim:subscribe apim:sub_manage apim:admin apim:tier_view apim:admin_tier_view apim:tier_manage apim:admin_tier_manage apim:policies_import_export apim:app_manage apim:app_import_export" | grep -o '"access_token":"[^"]*' | awk -F'"' '{print $4}')

API_UUID=$(curl -sk "https://localhost:9500/api/am/devportal/v3/apis" | grep -o '"id":"[^"]*' | awk -F'"' '{print $4}')

APPLICATION_UUID=$(curl -sk "https://localhost:9500/api/am/devportal/v3/applications?query=SampleMonetizationApp" -H "Authorization: Bearer $ACCESS_TOKEN" | grep -o '"applicationId":"[^"]*' | awk -F'"' '{print $4}')

# echo "Unsubscribing from API..."
# SUBSCRIPTION_UUID=$(curl -sk "https://localhost:9500/api/am/devportal/v3/subscriptions?apiId=$API_UUID&applicationId=$APPLICATION_UUID" \
# -H "Authorization: Bearer $ACCESS_TOKEN" | grep -o '"subscriptionId":"[^"]*' | awk -F'"' '{print $4}')

# curl -sk -X DELETE "https://localhost:9500/api/am/devportal/v3/subscriptions/$SUBSCRIPTION_UUID" \
# -H "Authorization: Bearer $ACCESS_TOKEN" \
# -H "Content-Type: application/json"

echo "Deleting commercial subscription policy - \$1.10 per API call..."
POLICY_UUID=$(curl -sk "https://localhost:9500/api/am/admin/v4/throttling/policies/subscription" \
-H "Authorization: Bearer $ACCESS_TOKEN" | grep -o '"policyId":"[^"]*"\|"policyName":"SampleMonetizationPolicy"' | grep -B1 'SampleMonetizationPolicy' | head -1 | awk -F'"' '{print $4}')

curl -sk -X DELETE https://localhost:9500/api/am/admin/v4/throttling/policies/subscription/$POLICY_UUID \
-H "Authorization: Bearer $ACCESS_TOKEN"

# -o /dev/null
# -o /dev/null