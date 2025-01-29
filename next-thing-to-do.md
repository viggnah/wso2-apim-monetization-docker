https://apim.docs.wso2.com/en/4.3.0/design/api-monetization/monetizing-an-api/
Also, currently using my monetization jar (1.4.2), have to check if ELK works with the new default monetization jar (1.5.0).

When I add 'properties' into the monetization subscription plan API call, it fails, unable to get the Hash map or something. Asked chatgpt and it just told me to check the key, such an obvious thing, and it's currencyType, not just currency. Also, then had another error and figured that we are not converting MONTH to lower case like we do for currency so that was throwing an error on Stripe's end, luckily figured out how to see the Stripe logs on their end under the failed plan creation. 

kept getting 
com.stripe.net.RequestOptions$InvalidRequestOptionsException: Empty API key specified!
Then realized after looking at my working 4.2.0 monetization setup that the JSON strucuture has a the billing engine key nested!, how did I make this basic copy-paste error... 

Have done all prereqs (B). Have to verify step 5. Step 5 not working, getting unauthenticated request but manually doing seems to be working...
Oh gosh, missed the #!/bin/bash line on top and the encoding of credentials is totally different, may be using sh or zsh or whatever


Fluentd occassionally fails to start. 

Out of the blue, getting this error:
ERROR - GlobalThrowableMapper Error while importing API:  Failed to get API
wso2-apim      | Error importing API.
wso2-apim      | Status: 500
wso2-apim      | Response: {"code":900967,"message":"General Error","description":"Server Error Occurred","moreInfo":"","error":[]}
wso2-apim      | apictl: Error importing API Reason: 500
wso2-apim      | Exit status 1

That's because now I'm using mysql and the data is getting persisted! I can confirm the API is still in the database
Even when I comment out the api import commands in `custom-entrypoint.sh`, it still attempts to import, and also getting:
ERROR - APIUtil Failed to retrieve /internal/data/v1/apis from remote endpoint: Error while retrieving /internal/data/v1/apis. Received response with status code 500.

why persist?? I'm doing the API creation on every spin up anyway so just let it be, I think I persisted when I didn't have automation to create APIs set up...

It's ok now, but still doing the import even if it's commented out!
Tha's because it's using the cached docker image with the custom entrypoint which adds the API already in there. Make sure to do a `docker image rm`, then rerun `./start.sh`.

Why is logstash concatenating the message for both events apim:faulty and apim:response?? 
Only apim:response, the last event is getting processed, apim:faulty is being sent to UNWANTED.
It's because the events are being batched and sent or picked up together - logstash not processing lines one by one!
But when I curl after sshing into fluentd, the message goes to logstash immediately! So something wrong with fluentd forwarding??
Yes, fluentd forward plugin is buffered by default, flushing every 60s, so I had to set flush_mode to immediate so it never buffers!!
