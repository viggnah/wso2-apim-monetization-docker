#!/bin/bash

# Load the secrets
if [ -f secrets.env ]; then
  source secrets.env
else
  echo "Secrets file not found! This should have been created when you provided the secrets on the first run."
  exit 1
fi

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
-d "grant_type=password&username=admin&password=admin&scope=apim:admin" | grep -o '"access_token":"[^"]*' | awk -F'"' '{print $4}')

echo "Inserting BillingEnginePlatformAccountKey..."
curl -sk -o /dev/null -X PUT https://localhost:9500/api/am/admin/v4/tenant-config \
-H "Authorization: Bearer $ACCESS_TOKEN" \
-H "Content-Type: application/json" \
-d "{
  \"EnableMonetization\": true,
  \"MonetizationInfo\": {
    \"BillingEnginePlatformAccountKey\": \"$BillingEnginePlatformAccountKey\"
  },
  \"EnableRecommendation\": false,
  \"IsUnlimitedTierPaid\": false,
  \"ExtensionHandlerPosition\": \"bottom\",
  \"RESTAPIScopes\": {
    \"Scope\": [
      {
        \"Name\": \"apim:api_publish\",
        \"Roles\": \"admin,Internal/publisher\"
      },
      {
        \"Name\": \"apim:api_create\",
        \"Roles\": \"admin,Internal/creator\"
      },
      {
        \"Name\": \"apim:api_generate_key\",
        \"Roles\": \"admin,Internal/creator,Internal/publisher\"
      },
      {
        \"Name\": \"apim:api_view\",
        \"Roles\": \"admin,Internal/publisher,Internal/creator,Internal/analytics,Internal/observer\"
      },
      {
        \"Name\": \"apim:api_delete\",
        \"Roles\": \"admin,Internal/creator\"
      },
      {
        \"Name\": \"apim:api_manage\",
        \"Roles\": \"admin\"
      },
      {
        \"Name\": \"apim:subscribe\",
        \"Roles\": \"admin,Internal/subscriber,Internal/devops\"
      },
      {
        \"Name\": \"apim:tier_view\",
        \"Roles\": \"admin,Internal/publisher,Internal/creator\"
      },
      {
        \"Name\": \"apim:tier_manage\",
        \"Roles\": \"admin\"
      },
      {
        \"Name\": \"apim:bl_view\",
        \"Roles\": \"admin\"
      },
      {
        \"Name\": \"apim:bl_manage\",
        \"Roles\": \"admin\"
      },
      {
        \"Name\": \"apim:subscription_view\",
        \"Roles\": \"admin,Internal/creator,Internal/publisher\"
      },
      {
        \"Name\": \"apim:subscription_block\",
        \"Roles\": \"admin,Internal/publisher\"
      },
      {
        \"Name\": \"apim:subscription_manage\",
        \"Roles\": \"admin,Internal/publisher\"
      },
      {
        \"Name\": \"apim:mediation_policy_view\",
        \"Roles\": \"admin,Internal/creator\"
      },
      {
        \"Name\": \"apim:mediation_policy_create\",
        \"Roles\": \"admin,Internal/creator\"
      },
      {
        \"Name\": \"apim:api_mediation_policy_manage\",
        \"Roles\": \"admin,Internal/creator\"
      },
      {
        \"Name\": \"apim:api_workflow_view\",
        \"Roles\": \"admin\"
      },
      {
        \"Name\": \"apim:api_workflow_approve\",
        \"Roles\": \"admin\"
      },
      {
        \"Name\": \"apim:admin\",
        \"Roles\": \"admin\"
      },
      {
        \"Name\": \"apim:app_owner_change\",
        \"Roles\": \"admin\"
      },
      {
        \"Name\": \"apim:app_import_export\",
        \"Roles\": \"admin,Internal/devops\"
      },
      {
        \"Name\": \"apim:api_import_export\",
        \"Roles\": \"admin,Internal/devops\"
      },
      {
        \"Name\": \"apim:api_product_import_export\",
        \"Roles\": \"admin,Internal/devops\"
      },
      {
        \"Name\": \"apim:label_manage\",
        \"Roles\": \"admin\"
      },
      {
        \"Name\": \"apim:label_read\",
        \"Roles\": \"admin\"
      },
      {
        \"Name\": \"apim:app_update\",
        \"Roles\": \"admin,Internal/subscriber\"
      },
      {
        \"Name\": \"apim:app_manage\",
        \"Roles\": \"admin,Internal/subscriber,Internal/devops\"
      },
      {
        \"Name\": \"apim:sub_manage\",
        \"Roles\": \"admin,Internal/subscriber,Internal/devops\"
      },
      {
        \"Name\": \"apim:monetization_usage_publish\",
        \"Roles\": \"admin, Internal/publisher\"
      },
      {
        \"Name\": \"apim:document_create\",
        \"Roles\": \"admin, Internal/creator,Internal/publisher\"
      },
      {
        \"Name\": \"apim:ep_certificates_update\",
        \"Roles\": \"admin,Internal/creator\"
      },
      {
        \"Name\": \"apim:client_certificates_update\",
        \"Roles\": \"admin,Internal/creator\"
      },
      {
        \"Name\": \"apim:client_certificates_manage\",
        \"Roles\": \"admin,Internal/creator\"
      },
      {
        \"Name\": \"apim:threat_protection_policy_manage\",
        \"Roles\": \"admin,Internal/creator\"
      },
      {
        \"Name\": \"apim:document_manage\",
        \"Roles\": \"admin, Internal/creator,Internal/publisher\"
      },
      {
        \"Name\": \"apim:client_certificates_add\",
        \"Roles\": \"admin,Internal/creator\"
      },
      {
        \"Name\": \"apim:publisher_settings\",
        \"Roles\": \"admin,Internal/creator,Internal/publisher,Internal/observer\"
      },
      {
        \"Name\": \"apim:store_settings\",
        \"Roles\": \"admin,Internal/subscriber\"
      },
      {
        \"Name\": \"apim:admin_settings\",
        \"Roles\": \"admin\"
      },
      {
        \"Name\": \"apim:client_certificates_view\",
        \"Roles\": \"admin,Internal/creator\"
      },
      {
        \"Name\": \"apim:mediation_policy_manage\",
        \"Roles\": \"admin,Internal/creator\"
      },
      {
        \"Name\": \"apim:threat_protection_policy_create\",
        \"Roles\": \"admin,Internal/creator\"
      },
      {
        \"Name\": \"apim:ep_certificates_add\",
        \"Roles\": \"admin,Internal/creator\"
      },
      {
        \"Name\": \"apim:ep_certificates_view\",
        \"Roles\": \"admin,Internal/creator\"
      },
      {
        \"Name\": \"apim:ep_certificates_manage\",
        \"Roles\": \"admin,Internal/creator\"
      },
      {
        \"Name\": \"apim:api_key\",
        \"Roles\": \"admin,Internal/subscriber\"
      },
      {
        \"Name\": \"apim_analytics:admin\",
        \"Roles\": \"admin\"
      },
      {
        \"Name\": \"apim_analytics:monitoring_dashboard:own\",
        \"Roles\": \"admin\"
      },
      {
        \"Name\": \"apim_analytics:monitoring_dashboard:edit\",
        \"Roles\": \"admin\"
      },
      {
        \"Name\": \"apim_analytics:monitoring_dashboard:view\",
        \"Roles\": \"admin,Internal/analytics\"
      },
      {
        \"Name\": \"apim_analytics:business_analytics:own\",
        \"Roles\": \"admin\"
      },
      {
        \"Name\": \"apim_analytics:business_analytics:edit\",
        \"Roles\": \"admin\"
      },
      {
        \"Name\": \"apim_analytics:business_analytics:view\",
        \"Roles\": \"admin,Internal/analytics\"
      },
      {
        \"Name\": \"apim_analytics:api_analytics:own\",
        \"Roles\": \"admin\"
      },
      {
        \"Name\": \"apim_analytics:api_analytics:edit\",
        \"Roles\": \"admin\"
      },
      {
        \"Name\": \"apim_analytics:api_analytics:view\",
        \"Roles\": \"admin,Internal/creator,Internal/publisher\"
      },
      {
        \"Name\": \"apim_analytics:application_analytics:own\",
        \"Roles\": \"admin\"
      },
      {
        \"Name\": \"apim_analytics:application_analytics:edit\",
        \"Roles\": \"admin\"
      },
      {
        \"Name\": \"apim_analytics:application_analytics:view\",
        \"Roles\": \"admin,Internal/subscriber\"
      },
      {
        \"Name\": \"apim:pub_alert_manage\",
        \"Roles\": \"admin,Internal/creator\"
      },
      {
        \"Name\": \"apim:sub_alert_manage\",
        \"Roles\": \"admin,Internal/subscriber\"
      },
      {
        \"Name\": \"apim:tenantInfo\",
        \"Roles\": \"admin\"
      },
      {
        \"Name\": \"apim:tenant_theme_manage\",
        \"Roles\": \"admin\"
      },
      {
        \"Name\": \"apim:admin_operations\",
        \"Roles\": \"admin\"
      },
      {
        \"Name\": \"apim:keymanagers_manage\",
        \"Roles\": \"admin\"
      },
      {
        \"Name\": \"apim:api_category\",
        \"Roles\": \"admin\"
      },
      {
        \"Name\": \"apim:shared_scope_manage\",
        \"Roles\": \"admin\"
      },
      {
        \"Name\": \"apim:admin_alert_manage\",
        \"Roles\": \"admin\"
      },
      {
        \"Name\": \"apim:bot_data\",
        \"Roles\": \"admin\"
      },
      {
        \"Name\": \"apim:scope_manage\",
        \"Roles\": \"admin\"
      },
      {
        \"Name\": \"apim:role_manage\",
        \"Roles\": \"admin\"
      },
      {
        \"Name\": \"apim:environment_manage\",
        \"Roles\": \"admin\"
      },
      {
        \"Name\": \"apim:environment_read\",
        \"Roles\": \"admin\"
      },
      {
        \"Name\": \"service_catalog:service_view\",
        \"Roles\": \"admin,Internal/creator,Internal/publisher\"
      },
      {
        \"Name\": \"service_catalog:service_write\",
        \"Roles\": \"admin,Internal/creator\"
      },
      {
        \"Name\": \"apim:comment_view\",
        \"Roles\": \"admin,Internal/creator,Internal/publisher\"
      },
      {
        \"Name\": \"apim:comment_write\",
        \"Roles\": \"admin,Internal/creator,Internal/publisher\"
      },
      {
        \"Name\": \"apim:comment_manage\",
        \"Roles\": \"admin,Internal/creator,Internal/publisher\"
      },
      {
        \"Name\": \"apim:throttling_policy_manage\",
        \"Roles\": \"admin,Internal/publisher,Internal/creator,Internal/analytics\"
      },
      {
        \"Name\": \"apim:admin_application_view\",
        \"Roles\": \"admin\"
      },
      {
        \"Name\": \"apim:api_list_view\",
        \"Roles\": \"Internal/integration_dev\"
      },
      {
        \"Name\": \"apim:api_definition_view\",
        \"Roles\": \"Internal/integration_dev\"
      },
      {
        \"Name\": \"apim:common_operation_policy_view\",
        \"Roles\": \"admin,Internal/creator,Internal/publisher,Internal/observer\"
      },
      {
        \"Name\": \"apim:common_operation_policy_manage\",
        \"Roles\": \"admin,Internal/creator\"
      },
      {
        \"Name\": \"apim:policies_import_export\",
        \"Roles\": \"admin,Internal/devops\"
      },
      {
        \"Name\": \"apim:admin_tier_manage\",
        \"Roles\": \"admin\"
      },
      {
        \"Name\": \"apim:admin_tier_view\",
        \"Roles\": \"admin\"
      },
      {
        \"Name\": \"apim:api_provider_change\",
        \"Roles\": \"admin\"
      },
      {
        \"Name\": \"apim:gateway_policy_manage\",
        \"Roles\": \"admin\"
      },
      {
        \"Name\": \"apim:gateway_policy_view\",
        \"Roles\": \"admin,Internal/creator,Internal/publisher,Internal/observer\"
      }
    ]
  },
  \"Meta\": {
    \"Migration\": {
      \"3.0.0\": true
    }
  },
  \"NotificationsEnabled\": \"false\",
  \"Notifications\": [
    {
      \"Type\": \"new_api_version\",
      \"Notifiers\": [
        {
          \"Class\": \"org.wso2.carbon.apimgt.impl.notification.NewAPIVersionEmailNotifier\",
          \"ClaimsRetrieverImplClass\": \"org.wso2.carbon.apimgt.impl.token.DefaultClaimsRetriever\",
          \"Title\": \"Version $2 of $1 Released\",
          \"Template\": \" \u003chtml\u003e \u003cbody\u003e \u003ch3 style\u003d color:Black;\u003eWe're happy to announce the arrival of the next major version $2 of $1 API which is now available in Our API Store.\u003c/h3\u003e\u003ca href\u003d https://localhost:9443/store \u003eClick here to Visit WSO2 API Store\u003c/a\u003e\u003c/body\u003e\u003c/html\u003e\"
        }
      ]
    }
  ],
  \"DefaultRoles\": {
    \"PublisherRole\": {
      \"CreateOnTenantLoad\": true,
      \"RoleName\": \"Internal/publisher\"
    },
    \"CreatorRole\": {
      \"CreateOnTenantLoad\": true,
      \"RoleName\": \"Internal/creator\"
    },
    \"SubscriberRole\": {
      \"CreateOnTenantLoad\": true
    },
    \"DevOpsRole\": {
      \"CreateOnTenantLoad\": true,
      \"RoleName\": \"Internal/devops\"
    },
    \"ObserverRole\": {
      \"CreateOnTenantLoad\": true,
      \"RoleName\": \"Internal/observer\"
    },
    \"IntegrationDeveloperRole\": {
      \"CreateOnTenantLoad\": true,
      \"RoleName\": \"Internal/integration_dev\"
    }
  },
  \"SelfSignUp\": {
    \"SignUpRoles\": [
      \"Internal/subscriber\"
    ]
  }
}"
