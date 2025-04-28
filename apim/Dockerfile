FROM wso2/wso2am:4.5.0-rocky

RUN curl -LO https://github.com/wso2/product-apim-tooling/releases/download/v4.3.1/apictl-4.3.1-linux-amd64.tar.gz \
    && tar -xzf apictl-4.3.1-linux-amd64.tar.gz
ENV PATH="/home/wso2carbon/apictl:$PATH"

COPY PizzaShackAPI /home/wso2carbon/PizzaShackAPI/
COPY secrets.env /home/wso2carbon/secrets.env
COPY update-tenant-admin-key.sh /home/wso2carbon/update-tenant-admin-key.sh
COPY create-commercial-sub-policy.sh /home/wso2carbon/create-commercial-sub-policy.sh
COPY custom-entrypoint.sh /home/wso2carbon/custom-entrypoint.sh

USER root
RUN chmod +x /home/wso2carbon/update-tenant-admin-key.sh
RUN chmod +x /home/wso2carbon/create-commercial-sub-policy.sh
RUN chmod +x /home/wso2carbon/custom-entrypoint.sh
USER wso2carbon
ENTRYPOINT ["/home/wso2carbon/custom-entrypoint.sh"]
