# Spin up API Manager with ELK Stack and Try Monetization with One Command

![API Manager](./repo-images/monetized-api.png)
![ELK](./repo-images/elk-kibana-dashboard.png)
![Stripe](./repo-images/dynamic-billing-usage.png)

## Before you start
1. Install Rancher (I have only tested on Rancher, others like Docker Desktop may also work). I used Moby engine for testing, not containerd.
2. Install docker compose. 
3. Create a Stripe account at https://dashboard.stripe.com/ if you don't have one. You need a couple of keys to connect WSO2 API Manager to Stripe. It's not a big deal, I'll explain:
    - Create a sandbox for testing, Stripe used to call this Test mode until recently.
    - Go to `Developers` on the bottom of the sidebar (or wherever they change it to next) and copy the `Secret key` under API Keys. It should start with sk_test_... This is your **`BillingEnginePlatformKey`**, keep it handy. 
    - Next, go to *Connected accounts* and create one, go for a Standard account type but I think Stripe these account types very soon.
    - Put the URL you get into a browser and just put in random data, it's easy. At payouts, choose the Stripe test option (it was somewhere near the bottom I think).
    - Once you are done, if you go back to the *Connected accounts* page, you'll see an account showing. 
    - Go into that account and copy the `Account ID`. This is your **`ConnectedAccountKey`**, keep this handy as well. 
    - That's it. 

![BillingEnginePlatformKey](./repo-images/BillingEnginePlatformAccountKey.png)
![ConnectedAccountKey](./repo-images/Connected-account-key.png)

> Just to give you an idea about how API Manager maps to Stripe - you are the Tenant Admin who runs the API Manager platform, you are responsible for creating the various monetization plans your organization requires. Different API publishers (departments, partners etc.) onboard on to the platform with their details (the random data we input earlier) and get a connected account. They then attach different monetization plans you created to their APIs. When consumers subscribe to their APIs, the consumer info along with the consumer's subscription is created in the API publisher's connected account. Depending on the consumer's usage, the publisher will invoice them. 

## How to use
```
git clone https://github.com/viggnah/wso2-apim-monetization-docker && cd wso2-apim-monetization-docker && chmod +x ./start.sh && ./start.sh
```

## What this does
1. Spins up an all-in-one API Manager and an ELK (Elasticsearch, Logstash, Kibana) setup. Note that we are using fluentd to forward the logs to Logstash, I just couldn't get filebeat working. 
2. Puts a simple sample API on the API Manager (PizzaShackAPI)
3. Creates a sample monetization plan ($1.10 per API call or something) and attaches it to the API
4. Creates an app on the devportal (SampleMonetizationApp) and subscribes to this API
5. Simulates a bit of traffic by making a few sample calls
6. Pushes out the usage data out to Stripe so that the subscription in the Connected account shows the due amount (eg: 5 calls at $1.10 per call - $5.50 is due)

## Tested on
Rancher 1.15.1 (Moby engine) on Mac OS Sonoma 14.4.1
