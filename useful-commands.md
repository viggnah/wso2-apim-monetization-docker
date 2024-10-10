# Starting container
docker run -it -p 8337:8337 -p 8300:8300 -p 9500:9500 --name api-manager wso2/wso2am:4.3.0-rocky

# SSHing into the container
docker exec -it docker-monetization_mysql_1 bash
mysql -u wso2carbon -p

# Fix Rancher Desktop startup issue
sudo mkdir -m 775 /private/var/run/rancher-desktop-lima

# Copy files to and from a container and local file system
docker cp docker-monetization_wso2-apim_1:/home/wso2carbon/wso2am-4.3.0/repository/conf/log4j2.properties ./log4j2.properties
docker cp ./mysql-init/01-WSO2AM_DB-mysql.sql docker-monetization_mysql_1:/home/01-WSO2AM_DB-mysql.sql

# Run MySQL script in the MySQL command line
source /home/01-WSO2AM_DB-mysql.sql;
# See collation and charset of database
USE WSO2AM_DB;
show variables like "character_set_database";

# Check on elasticsearch
curl -u elastic:changeme http://elasticsearch:9200
curl http://elasticsearch:9200/index_name?apim_event_response

# Running fluentd locally
docker run -d --name fluentd -p 24224:24224 -p 24224:24224/udp fluent/fluentd:v1.17.1-debian-1.0

# Stuff
Rancher desktop doesn't run natively on MacOS. It runs a Lima VM and runs on top of that. To access the Lima VM use - `rdctl shell`

nerdctl only supports the following logging drivers as of now - **fluetnd, journald, json-file and syslog**. NO support for gelf and others which are supported by docker. 

The unsolvable error - `FATA[0000] no log viewer type registered for logging driver "fluentd"`

# Volumes vs Bind Mounts in Docker Compose
So confusing, read - https://maximorlov.com/docker-compose-syntax-volume-or-bind-mount/

# Install apictl tool on APIM image
curl -LO https://github.com/wso2/product-apim-tooling/releases/download/v4.3.1/apictl-4.3.1-darwin-arm64.tar.gz
tar -xzf apictl-4.3.1-darwin-arm64.tar.gz -C /usr/local/bin

curl -LO https://github.com/wso2/product-apim-tooling/releases/download/v4.3.1/apictl-4.3.1-linux-amd64.tar.gz
tar -xzf apictl-4.3.1-linux-amd64.tar.gz -C /usr/local/bin


# API readiness
API Manager is ready by checking /Services/Version, then you import the API but it takes a further 10 seconds to be pulled to the GW. In the interim the GW healthcheck says it's successfult because it has 0 APIs to start with (??)
