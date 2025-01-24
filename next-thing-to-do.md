Do monetization!
- Stripe account creation, blah blah blah

Why is logstash concatenating the message for both events apim:faulty and apim:response?? 
Only apim:response, the last event is getting processed, apim:faulty is being sent to UNWANTED.
It's because the events are being batched and sent or picked up together - logstash not processing lines one by one!
But when I curl after sshing into fluentd, the message goes to logstash immediately! So something wrong with fluentd forwarding??
Yes, fluentd forward plugin is buffered by default, flushing every 60s, so I had to set flush_mode to immediate so it never buffers!!

Fluentd occassionally fails to start. 
