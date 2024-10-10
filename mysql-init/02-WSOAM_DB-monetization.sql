USE WSO2AM_DB;

CREATE TABLE IF NOT EXISTS AM_MONETIZATION (
    API_ID INTEGER NOT NULL,
    TIER_NAME VARCHAR(512),
    STRIPE_PRODUCT_ID VARCHAR(512),
    STRIPE_PLAN_ID VARCHAR(512),
    FOREIGN KEY (API_ID) REFERENCES AM_API (API_ID) ON DELETE CASCADE
) ENGINE=InnoDB;


CREATE TABLE IF NOT EXISTS AM_POLICY_PLAN_MAPPING (
        POLICY_UUID VARCHAR(256),
        PRODUCT_ID VARCHAR(512),
        PLAN_ID VARCHAR(512),
        FOREIGN KEY (POLICY_UUID) REFERENCES AM_POLICY_SUBSCRIPTION(UUID)
) ENGINE=InnoDB;


CREATE TABLE IF NOT EXISTS AM_MONETIZATION_PLATFORM_CUSTOMERS (
    ID INTEGER NOT NULL AUTO_INCREMENT,
    SUBSCRIBER_ID INTEGER NOT NULL,
    TENANT_ID INTEGER NOT NULL,
    CUSTOMER_ID VARCHAR(256) NOT NULL,    
    PRIMARY KEY (ID),
    FOREIGN KEY (SUBSCRIBER_ID) REFERENCES AM_SUBSCRIBER(SUBSCRIBER_ID) ON DELETE CASCADE
) ENGINE=InnoDB;


CREATE TABLE IF NOT EXISTS AM_MONETIZATION_SHARED_CUSTOMERS (
    ID INTEGER NOT NULL AUTO_INCREMENT,
    APPLICATION_ID INTEGER NOT NULL,
    API_PROVIDER VARCHAR(256) NOT NULL,
    TENANT_ID INTEGER NOT NULL,
    SHARED_CUSTOMER_ID VARCHAR(256) NOT NULL,
    PARENT_CUSTOMER_ID INTEGER NOT NULL,    
    PRIMARY KEY (ID),
    FOREIGN KEY (APPLICATION_ID) REFERENCES AM_APPLICATION(APPLICATION_ID) ON DELETE CASCADE,
    FOREIGN KEY (PARENT_CUSTOMER_ID) REFERENCES AM_MONETIZATION_PLATFORM_CUSTOMERS(ID) ON DELETE CASCADE
)ENGINE=INNODB;


CREATE TABLE IF NOT EXISTS AM_MONETIZATION_SUBSCRIPTIONS (
    ID INTEGER NOT NULL AUTO_INCREMENT,
    SUBSCRIBED_APPLICATION_ID INTEGER NOT NULL,
    SUBSCRIBED_API_ID INTEGER NOT NULL,
    TENANT_ID INTEGER NOT NULL,
    SUBSCRIPTION_ID VARCHAR(256) NOT NULL,
    SHARED_CUSTOMER_ID INTEGER NOT NULL,    
    PRIMARY KEY (ID),
    FOREIGN KEY (SUBSCRIBED_APPLICATION_ID) REFERENCES AM_APPLICATION(APPLICATION_ID) ON DELETE CASCADE,
    FOREIGN KEY (SUBSCRIBED_API_ID) REFERENCES AM_API(API_ID) ON DELETE CASCADE,
    FOREIGN KEY (SHARED_CUSTOMER_ID) REFERENCES AM_MONETIZATION_SHARED_CUSTOMERS(ID) ON DELETE CASCADE
)ENGINE INNODB;
