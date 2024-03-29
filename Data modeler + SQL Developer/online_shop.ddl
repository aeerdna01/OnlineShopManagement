-- Generated by Oracle SQL Developer Data Modeler 22.2.0.165.1149
--   at:        2022-12-03 20:51:45 EET
--   site:      Oracle Database 12c
--   type:      Oracle Database 12c



-- predefined type, no DDL - MDSYS.SDO_GEOMETRY

-- predefined type, no DDL - XMLTYPE

CREATE TABLE accounts (
    id_customer  NUMBER(2)
        GENERATED BY DEFAULT AS IDENTITY ( START WITH 1 NOCACHE ORDER )
    NOT NULL,
    username     VARCHAR2(30) NOT NULL,
    password     VARCHAR2(31) NOT NULL,
    account_type VARCHAR2(10) NOT NULL,
    total_orders NUMBER(2)
)
LOGGING;

ALTER TABLE accounts
    ADD CONSTRAINT accounts_username_ck CHECK ( length(username) >= 3
                                                AND REGEXP_LIKE ( username,
                                                                  '^[A-Za-z0-9_-]*$' ) );

ALTER TABLE accounts
    ADD CONSTRAINT accounts_password_ck CHECK ( REGEXP_LIKE ( password,
                                                              '/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[#$@!%&*?])[A-Za-z\d#$@!%&*?]{8,30}$/'
                                                              ) );

ALTER TABLE accounts
    ADD CONSTRAINT accounts_type_ck CHECK ( account_type IN ( 'admin', 'customer' ) );

ALTER TABLE accounts ADD CONSTRAINT accounts_total_orders_ck CHECK ( total_orders >= 0 );

ALTER TABLE accounts ADD CONSTRAINT accounts_pk PRIMARY KEY ( id_customer );

CREATE TABLE categories (
    id_category NUMBER(1) NOT NULL,
    name        VARCHAR2(20) NOT NULL
)
LOGGING;

ALTER TABLE categories
    ADD CONSTRAINT categories_name_ck CHECK ( length(name) >= 3
                                              AND REGEXP_LIKE ( name,
                                                                '^[A-Za-z]+$' ) );

ALTER TABLE categories ADD CONSTRAINT categories_pk PRIMARY KEY ( id_category );

CREATE TABLE details (
    accounts_id_customer NUMBER(2) NOT NULL,
    first_name           VARCHAR2(20) NOT NULL,
    last_name            VARCHAR2(20) NOT NULL,
    address              VARCHAR2(30) NOT NULL,
    email                VARCHAR2(30) NOT NULL,
    phone                VARCHAR2(10) NOT NULL
)
LOGGING;

ALTER TABLE details
    ADD CONSTRAINT details_first_name_ck CHECK ( length(first_name) >= 3
                                                 AND REGEXP_LIKE ( first_name,
                                                                   '^[A-Za-z]+$' ) );

ALTER TABLE details
    ADD CONSTRAINT details_last_name_ck CHECK ( length(last_name) >= 3
                                                AND REGEXP_LIKE ( last_name,
                                                                  '^[A-Za-z]+$' ) );

ALTER TABLE details
    ADD CONSTRAINT details_address_ck CHECK ( length(address) >= 3
                                              AND REGEXP_LIKE ( address,
                                                                '^[A-Za-z0-9_-]*$' ) );

ALTER TABLE details
    ADD CONSTRAINT details_email_ck CHECK ( REGEXP_LIKE ( email,
                                                          '[a-z0-9._%-]+@[a-z0-9._%-]+\.[a-z]{2,4}' ) );

ALTER TABLE details
    ADD CONSTRAINT details_phone_ck CHECK ( REGEXP_LIKE ( phone,
                                                          '^[0-9]{10}$' ) );

ALTER TABLE details ADD CONSTRAINT details_pk PRIMARY KEY ( accounts_id_customer );

ALTER TABLE details ADD CONSTRAINT details_email_un UNIQUE ( email );

ALTER TABLE details ADD CONSTRAINT details_phone_email_un UNIQUE ( phone,
                                                                   email );

CREATE TABLE orders (
    id_order             NUMBER(2)
        GENERATED BY DEFAULT AS IDENTITY ( START WITH 1 NOCACHE ORDER )
    NOT NULL,
    order_date           DATE NOT NULL,
    accounts_id_customer NUMBER(2) NOT NULL
)
LOGGING;

ALTER TABLE orders ADD CONSTRAINT orders_pk PRIMARY KEY ( id_order );

CREATE TABLE orders_details (
    orders_id_order     NUMBER(2) NOT NULL,
    products_id_product NUMBER(2) NOT NULL,
    products_id_size    NUMBER(1) NOT NULL,
    quantity            NUMBER(3) NOT NULL,
    total_payment       NUMBER(4) NOT NULL
)
LOGGING;

ALTER TABLE orders_details
    ADD CONSTRAINT ord_details_quantity_ck CHECK ( quantity BETWEEN 1 AND 999 );

ALTER TABLE orders_details ADD CONSTRAINT ord_details_payment_ck CHECK ( total_payment > 0 );

ALTER TABLE orders_details
    ADD CONSTRAINT orders_details_pk PRIMARY KEY ( orders_id_order,
                                                   products_id_product,
                                                   products_id_size );

CREATE TABLE products (
    id_product             NUMBER(2)
        GENERATED BY DEFAULT AS IDENTITY ( START WITH 1 NOCACHE ORDER )
    NOT NULL,
    stock_quantity         NUMBER(3) NOT NULL,
    price                  NUMBER(3) NOT NULL,
    color                  VARCHAR2(15) NOT NULL,
    description            VARCHAR2(40),
    categories_id_category NUMBER(1) NOT NULL,
    sizes_id_size          NUMBER(1) NOT NULL
)
LOGGING;

ALTER TABLE products
    ADD CONSTRAINT products_stock_quantity CHECK ( stock_quantity BETWEEN 0 AND 999 );

ALTER TABLE products
    ADD CONSTRAINT products_price_ck CHECK ( price BETWEEN 10 AND 999 );

ALTER TABLE products
    ADD CONSTRAINT products_color_ck CHECK ( color IN ( 'Black', 'Blue', 'Gray', 'Green', 'Orange',
                                                        'Pink', 'Red', 'White', 'Yellow' ) );

ALTER TABLE products ADD CONSTRAINT products_pk PRIMARY KEY ( id_product,
                                                              sizes_id_size );

CREATE TABLE sizes (
    id_size NUMBER(1) NOT NULL,
    type    VARCHAR2(1) NOT NULL
)
LOGGING;

ALTER TABLE sizes
    ADD CONSTRAINT sizes_type_ck CHECK ( type IN ( 'L', 'M', 'S' ) );

ALTER TABLE sizes ADD CONSTRAINT sizes_pk PRIMARY KEY ( id_size );

CREATE TABLE supplies (
    supply_quantity     NUMBER(3) NOT NULL,
    supply_date         DATE NOT NULL,
    products_id_product NUMBER(2) NOT NULL,
    products_id_size    NUMBER(1) NOT NULL,
    supply_price        NUMBER(4) NOT NULL
)
LOGGING;

ALTER TABLE supplies
    ADD CONSTRAINT supplies_quantity_ck CHECK ( supply_quantity BETWEEN 0 AND 999 );

ALTER TABLE supplies ADD CONSTRAINT supplies_price_ck CHECK ( supply_price > 0 );

ALTER TABLE details
    ADD CONSTRAINT details_accounts_fk FOREIGN KEY ( accounts_id_customer )
        REFERENCES accounts ( id_customer )
    NOT DEFERRABLE;

ALTER TABLE orders
    ADD CONSTRAINT orders_accounts_fk FOREIGN KEY ( accounts_id_customer )
        REFERENCES accounts ( id_customer )
    NOT DEFERRABLE;

ALTER TABLE orders_details
    ADD CONSTRAINT orders_details_orders_fk FOREIGN KEY ( orders_id_order )
        REFERENCES orders ( id_order )
    NOT DEFERRABLE;

ALTER TABLE orders_details
    ADD CONSTRAINT orders_details_products_fk FOREIGN KEY ( products_id_product,
                                                            products_id_size )
        REFERENCES products ( id_product,
                              sizes_id_size )
    NOT DEFERRABLE;

ALTER TABLE products
    ADD CONSTRAINT products_categories_fk FOREIGN KEY ( categories_id_category )
        REFERENCES categories ( id_category )
    NOT DEFERRABLE;

ALTER TABLE products
    ADD CONSTRAINT products_sizes_fk FOREIGN KEY ( sizes_id_size )
        REFERENCES sizes ( id_size )
    NOT DEFERRABLE;

ALTER TABLE supplies
    ADD CONSTRAINT supplies_products_fk FOREIGN KEY ( products_id_product,
                                                      products_id_size )
        REFERENCES products ( id_product,
                              sizes_id_size )
    NOT DEFERRABLE;

CREATE OR REPLACE TRIGGER trg_orders_BRIU 
    BEFORE INSERT OR UPDATE ON ORDERS 
    FOR EACH ROW 
BEGIN
IF( :new.ORDER_DATE <= SYSDATE )
THEN
RAISE_APPLICATION_ERROR( -20001,
'Invalid date: ' || TO_CHAR( :new.ORDER_DATE, 'DD.MM.YYYY HH24:MI:SS' ) || ' must be grater than the current date.' );
END IF;
END; 
/

CREATE OR REPLACE TRIGGER trg_supplies_BRIU 
    BEFORE INSERT OR UPDATE ON SUPPLIES 
    FOR EACH ROW 
BEGIN
IF( :new.SUPPLY_DATE <= SYSDATE )
THEN
RAISE_APPLICATION_ERROR( -20001,
'Invalid date: ' || TO_CHAR( :new.SUPPLY_DATE, 'DD.MM.YYYY HH24:MI:SS' ) || ' must be grater than the current date.' );
END IF;
END; 
/



-- Oracle SQL Developer Data Modeler Summary Report: 
-- 
-- CREATE TABLE                             8
-- CREATE INDEX                             0
-- ALTER TABLE                             34
-- CREATE VIEW                              0
-- ALTER VIEW                               0
-- CREATE PACKAGE                           0
-- CREATE PACKAGE BODY                      0
-- CREATE PROCEDURE                         0
-- CREATE FUNCTION                          0
-- CREATE TRIGGER                           2
-- ALTER TRIGGER                            0
-- CREATE COLLECTION TYPE                   0
-- CREATE STRUCTURED TYPE                   0
-- CREATE STRUCTURED TYPE BODY              0
-- CREATE CLUSTER                           0
-- CREATE CONTEXT                           0
-- CREATE DATABASE                          0
-- CREATE DIMENSION                         0
-- CREATE DIRECTORY                         0
-- CREATE DISK GROUP                        0
-- CREATE ROLE                              0
-- CREATE ROLLBACK SEGMENT                  0
-- CREATE SEQUENCE                          0
-- CREATE MATERIALIZED VIEW                 0
-- CREATE MATERIALIZED VIEW LOG             0
-- CREATE SYNONYM                           0
-- CREATE TABLESPACE                        0
-- CREATE USER                              0
-- 
-- DROP TABLESPACE                          0
-- DROP DATABASE                            0
-- 
-- REDACTION POLICY                         0
-- TSDP POLICY                              0
-- 
-- ORDS DROP SCHEMA                         0
-- ORDS ENABLE SCHEMA                       0
-- ORDS ENABLE OBJECT                       0
-- 
-- ERRORS                                   0
-- WARNINGS                                 0
