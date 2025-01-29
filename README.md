# How to use
```
git clone https://github.com/viggnah/wso2-apim-monetization-docker && cd wso2-apim-monetization-docker && chmod +x ./start.sh && ./start.sh
```

Make sure you have docker and docker compose installed. I tested this on Rancher 1.15.1 (Moby engine) on Mac OS Sonoma 14.4.1.

# Current Status
APIM comes up with a sample API (Pizzashack) and a script calls the sample API. The calls are picked up by fluentd, sent to logstash, and then on to elasticsearch, and finally displayed in Kibana dashboards.

1. Access API Manager: https://localhost:9500/publisher/apis  
username: admin  
password: admin

2. Kibana Dashboard: http://localhost:5601/app/dashboards#/view/f954a940-6ed4-11ec-9007-b93f9eb88870  
username: elastic  
password: changeme
