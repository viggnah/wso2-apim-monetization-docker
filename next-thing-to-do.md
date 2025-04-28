NO MORE ISSUES!!!

Note: The plugin only expects http connection to elasticsearch so if you have HTTPS you have to modify the plugin to accept it. Basically have to change to HTTPS connection and give the public self-signed elasticsearch cert as SSL context to the connection. 

https://apim.docs.wso2.com/en/4.3.0/design/api-monetization/monetizing-an-api/

CURRENT ISSUES IS THIS:
Says no such index on elastic search even though it exists
wso2-apim      | [2025-04-28 13:55:35,656] ERROR - MonetizationUsagePublishAgent Failed to publish monetization usage to billing Engine
wso2-apim      | co.elastic.clients.elasticsearch._types.ElasticsearchException: [es/search] failed: [index_not_found_exception] no such index [apim_event_response]
wso2-apim      |        at co.elastic.clients.transport.ElasticsearchTransportBase.getApiResponse(ElasticsearchTransportBase.java:345) ~[org.wso2.apim.monetization.impl-1.5.1-SNAPSHOT.jar:?]
wso2-apim      |        at co.elastic.clients.transport.ElasticsearchTransportBase.performRequest(ElasticsearchTransportBase.java:147) ~[org.wso2.apim.monetization.impl-1.5.1-SNAPSHOT.jar:?]
wso2-apim      |        at co.elastic.clients.elasticsearch.ElasticsearchClient.search(ElasticsearchClient.java:1923) ~[org.wso2.apim.monetization.impl-1.5.1-SNAPSHOT.jar:?]
wso2-apim      |        at org.wso2.apim.monetization.impl.StripeMonetizationImpl.getUsageDataFromElasticsearch(StripeMonetizationImpl.java:1105) ~[org.wso2.apim.monetization.impl-1.5.1-SNAPSHOT.jar:?]
wso2-apim      |        at org.wso2.apim.monetization.impl.StripeMonetizationImpl.publishMonetizationUsageRecords(StripeMonetizationImpl.java:718) ~[org.wso2.apim.monetization.impl-1.5.1-SNAPSHOT.jar:?]
wso2-apim      |        at org.wso2.carbon.apimgt.impl.monetization.MonetizationUsagePublishAgent.run_aroundBody0(MonetizationUsagePublishAgent.java:62) ~[org.wso2.carbon.apimgt.impl_9.29.120.jar:?]
wso2-apim      |        at org.wso2.carbon.apimgt.impl.monetization.MonetizationUsagePublishAgent.run(MonetizationUsagePublishAgent.java:1) ~[org.wso2.carbon.apimgt.impl_9.29.120.jar:?]
wso2-apim      |        at java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1136) ~[?:?]
wso2-apim      |        at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:635) ~[?:?]
wso2-apim      |        at java.lang.Thread.run(Thread.java:840) ~[?:?]

ACTUALLY it didn't exist because I had not sent successful requests so no index was presetn but after some successful requests the publishing worked like a charm!


Error connecting to elastic to fetch data and publish to stripe to account for the API calls. Some HTTP async missing library issue

wso2-apim      | Loaded from deployment toml configs - username, password, hostname, port, analyticsIndex: elastic, [B@77686b1e, http://localhost, 9200, apim_event_response
wso2-apim      | Exception in thread "pool-319-thread-1" java.lang.NoClassDefFoundError: org/apache/http/nio/client/HttpAsyncClient
wso2-apim      |        at org.wso2.apim.monetization.impl.StripeMonetizationImpl.getUsageDataFromElasticsearch(StripeMonetizationImpl.java:1077)
wso2-apim      |        at org.wso2.apim.monetization.impl.StripeMonetizationImpl.publishMonetizationUsageRecords(StripeMonetizationImpl.java:718)
wso2-apim      |        at org.wso2.carbon.apimgt.impl.monetization.MonetizationUsagePublishAgent.run_aroundBody0(MonetizationUsagePublishAgent.java:62)
wso2-apim      |        at org.wso2.carbon.apimgt.impl.monetization.MonetizationUsagePublishAgent.run(MonetizationUsagePublishAgent.java:1)
wso2-apim      |        at java.base/java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1136)
wso2-apim      |        at java.base/java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:635)
wso2-apim      |        at java.base/java.lang.Thread.run(Thread.java:840)
wso2-apim      | Caused by: java.lang.ClassNotFoundException: org.apache.http.nio.client.HttpAsyncClient cannot be found by org.wso2.apim.monetization.impl_1.5.1_SNAPSHOT_1.0.0
wso2-apim      |        at org.eclipse.osgi.internal.loader.BundleLoader.findClassInternal(BundleLoader.java:512)
wso2-apim      |        at org.eclipse.osgi.internal.loader.BundleLoader.findClass(BundleLoader.java:423)
wso2-apim      |        at org.eclipse.osgi.internal.loader.BundleLoader.findClass(BundleLoader.java:415)
wso2-apim      |        at org.eclipse.osgi.internal.loader.ModuleClassLoader.loadClass(ModuleClassLoader.java:155)
wso2-apim      |        at java.base/java.lang.ClassLoader.loadClass(ClassLoader.java:525)
wso2-apim      |        ... 7 more
kibana         | [2025-04-27T11:42:11.207+00:00][INFO ][plugins.fleet] Fleet Usage: {"agents_enabled":true,"agents":{"total_enrolled":0,"healthy":0,"unhealthy":0,"offline":0,"inactive":0,"unenrolled":0,"total_all_statuses":0,"updating":0},"fleet_server":{"total_all_statuses":0,"total_enrolled":0,"healthy":0,"unhealthy":0,"offline":0,"updating":0,"num_host_urls":0}}

Fixed it by self-containing the http.nio imports in the POM, early it was embedded plus imported (takes from the platform i.e. APIM distribution), but removing it from imported fixed it. 

```xml
 <Import-Package>
    !com.google.gson.internal,
    io.opentelemetry.api.common.*,
    <!-- org.apache.http.impl.nio.*,
    org.apache.http.nio.*, -->
</Import-Package>
<DynamicImport-Package>*</DynamicImport-Package>
<Embed-Dependency>
    opentelemetry-api;scope=compile|runtime;inline=false,
    httpasyncclient;scope=compile|runtime;inline=false,
</Embed-Dependency>
```

Also, currently using my monetization jar (1.4.2), have to check if ELK works with the new default monetization jar (1.5.0). - YES, this works, I'm using 1.5.0.


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
