Currently: APIM comes up with API and script calls PizzaShack API, event is picked up by fluentd, sent to logstash, then to elasticsearch, then displayed in Kibana dashboards.

Why is logstash concatenating the message for both events apim:faulty and apim:response?? 
Only apim:response, the last event is getting processed, apim:faulty is being sent to UNWANTED.
It's because the events are being batched and sent or picked up together - logstash not processing lines one by one!
But when I curl after sshing into fluentd, the message goes to logstash immediately! So something wrong with fluentd forwarding??
Yes, fluentd forward plugin is buffered by default, flushing every 60s, so I had to set flush_mode to immediate so it never buffers!!

Right now the message format to elasticsearch has parsed_properties and some stuff, will that be correctly picked up by kibana dashboards we have?

Fluentd occassionally fails to start. 
