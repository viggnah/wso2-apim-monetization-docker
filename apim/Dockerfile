FROM wso2/wso2am:4.3.0-rocky

RUN curl -LO https://github.com/wso2/product-apim-tooling/releases/download/v4.3.1/apictl-4.3.1-linux-amd64.tar.gz \
    && tar -xzf apictl-4.3.1-linux-amd64.tar.gz
ENV PATH="/home/wso2carbon/apictl:$PATH"

COPY PizzaShackAPI /home/wso2carbon/PizzaShackAPI/

COPY custom-entrypoint.sh /home/wso2carbon/custom-entrypoint.sh
USER root
RUN chmod +x /home/wso2carbon/custom-entrypoint.sh
USER wso2carbon
ENTRYPOINT ["/home/wso2carbon/custom-entrypoint.sh"]
