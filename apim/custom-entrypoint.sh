#!/bin/sh

# Call the original entrypoint script
./docker-entrypoint.sh &

# Wait for the WSO2 API Manager to be ready
until curl -sk https://localhost:9500/services/Version | grep -q "WSO2 API Manager"; do
    echo "Waiting for WSO2 API Manager to start..."
    sleep 5
done

./update-tenant-admin-key.sh
./create-commercial-sub-policy.sh

# Run apictl commands
apictl add env dev --apim https://localhost:9500
apictl login dev -u admin -p admin
apictl import api -f PizzaShackAPI -e dev

# Keep the container running
wait
