#!/bin/bash

KIBANA_URL="http://localhost:5601"
NDJSON_FILE="./elk/export.ndjson"
ELASTIC_USER="elastic"
ELASTIC_PASSWORD="changeme"

# Wait for Kibana to be up
until $(curl --output /dev/null --silent --head --fail -u $ELASTIC_USER:$ELASTIC_PASSWORD "$KIBANA_URL/api/status"); do
    echo "Waiting for Kibana to start..."
    sleep 10
done

# Delete index patterns
# for pattern in "apim_event*" "apim_event_faulty" "apim_event_response"; do
#     echo "Deleting index pattern: $pattern"
#     curl -X DELETE -u $ELASTIC_USER:$ELASTIC_PASSWORD "$KIBANA_URL/api/saved_objects/index-pattern/$pattern"
# done

# Import saved objects
echo "Importing saved objects from ndjson file..."
curl -s -o /dev/null -X POST "$KIBANA_URL/api/saved_objects/_import?overwrite=true" \
    -u $ELASTIC_USER:$ELASTIC_PASSWORD \
    -H "kbn-xsrf: true" \
    --form file=@"$NDJSON_FILE"
