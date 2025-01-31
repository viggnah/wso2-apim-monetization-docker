#!/bin/bash

# YWRtaW46YWRtaW4=  is admin:admin
# Using -k for self-signed cert
# 9500 is my port

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
# ENCODED_CREDENTIALS=$(echo -n "$CLIENT_ID:$CLIENT_SECRET" | base64)
ENCODED_CREDENTIALS=$(printf "%s" "$CLIENT_ID:$CLIENT_SECRET" | base64)

# Step 3: Obtain a token with the monetization usage scope
ACCESS_TOKEN=$(curl -sk -X POST https://localhost:9500/oauth2/token \
-H "Authorization: Basic $ENCODED_CREDENTIALS" \
-d "grant_type=password&username=admin&password=admin&scope=apim:monetization_usage_publish" | grep -o '"access_token":"[^"]*' | awk -F'"' '{print $4}')

# Step 4: Publish usage data to the Stripe billing engine & Monitor the status of publishing
curl -k -H "Authorization: Bearer $ACCESS_TOKEN" -X POST -H "Content-Type: application/json" https://localhost:9500/api/am/admin/v4/monetization/publish-usage
curl -k -H "Authorization: Bearer $ACCESS_TOKEN" -X GET -H "Content-Type: application/json" https://localhost:9500/api/am/admin/v4/monetization/publish-usage/status
