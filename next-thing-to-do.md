Currently: APIM comes up with API and script calls PizzaShack API, event is picked up by fluentd, sent to logstash, then to elasticsearch.

Why is logstash concatenating the message for both events apim:faulty and apim:response?? 
Only apim:response, the last event is getting processed, apim:faulty is being sent to UNWANTED.

Right now the message format to elasticsearch has parsed_properties and some stuff, will that be correctly picked up by kibana dashboards we have?

Fluentd occassionally fails to start. 
