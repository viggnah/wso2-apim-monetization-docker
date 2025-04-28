#!/bin/bash

KIBANA_URL="http://localhost:5601"
NDJSON_FILE="./elk/export.ndjson"
ELASTIC_USER="elastic"
ELASTIC_PASSWORD="changeme"

spin='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
i=0
seconds=0

until curl --output /dev/null --silent --head --fail -u "$ELASTIC_USER:$ELASTIC_PASSWORD" "$KIBANA_URL/api/status"; do
    i=$(( (i+1) % ${#spin} ))
    message="${spin:$i:1} Kibana with dashboards"
    timer=$(printf "%5.1fs" "$seconds")
    printf "\r%*s\r%s" $(tput cols) "$timer" "$message";

    sleep 0.1
    seconds=$(echo "$seconds + 0.1" | bc)
done
printf "\r✅ Kibana with dashboards\n"

# Delete index patterns
# for pattern in "apim_event*" "apim_event_faulty" "apim_event_response"; do
#     echo "Deleting index pattern: $pattern"
#     curl -X DELETE -u $ELASTIC_USER:$ELASTIC_PASSWORD "$KIBANA_URL/api/saved_objects/index-pattern/$pattern"
# done

# Import saved objects
curl -s -o /dev/null -X POST "$KIBANA_URL/api/saved_objects/_import?overwrite=true" \
    -u $ELASTIC_USER:$ELASTIC_PASSWORD \
    -H "kbn-xsrf: true" \
    --form file=@"$NDJSON_FILE"
