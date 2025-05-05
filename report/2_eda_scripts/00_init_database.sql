-- Connect to postgres to drop and recreate the target DB
\c postgres

DROP DATABASE IF EXISTS "DataWarehouseAnalytics";
CREATE DATABASE "DataWarehouseAnalytics";

\c "DataWarehouseAnalytics"

CREATE SCHEMA IF NOT EXISTS gold;

-- Create tables
CREATE TABLE gold.dim_customers (
    customer_key       SERIAL PRIMARY KEY,
    customer_id        INT,
    customer_number    VARCHAR(255),
    first_name         VARCHAR(255),
    last_name          VARCHAR(255),
    country            VARCHAR(255),
    marital_status     VARCHAR(255),
    gender             VARCHAR(255),
    birth_date         DATE,
    create_date        TIMESTAMP WITH TIME ZONE
);

CREATE TABLE gold.dim_products (
    product_key       SERIAL PRIMARY KEY,
    product_id        INT,
    product_number    VARCHAR(255),
    product_name      VARCHAR(255),
    category_id       INT,
    category          VARCHAR(255),
    subcategory       VARCHAR(255),
    maintenance       INT,
    product_cost      NUMERIC,
    product_line      VARCHAR(255),
    start_dt          DATE
);

CREATE TABLE gold.fact_sales (
    order_number    VARCHAR(255),
    product_key     INT REFERENCES gold.dim_products(product_key),
    customer_key    INT REFERENCES gold.dim_customers(customer_key),
    customer_id     INT,
    order_date      DATE,
    shipping_date   DATE,
    due_date        DATE,
    sales_amount    NUMERIC,
    quantity        INT,
    price           NUMERIC
);

-- Truncate all in correct order to avoid FK issues
TRUNCATE TABLE gold.fact_sales, gold.dim_products, gold.dim_customers RESTART IDENTITY CASCADE;

-- Load data using client-side \copy — make sure you're in `psql`
\copy gold.dim_customers(customer_id, customer_number, first_name, last_name, country, marital_status, gender, birth_date, create_date) FROM 'report/1_gold_layer_datasets/dim_customers.csv' DELIMITER ',' CSV HEADER;

\copy gold.dim_products(product_id, product_number, product_name, category_id, category, subcategory, maintenance, product_cost, product_line, start_dt) FROM 'report/1_gold_layer_datasets/dim_products.csv' DELIMITER ',' CSV HEADER;

\copy gold.fact_sales(order_number, product_key, customer_key, customer_id, order_date, shipping_date, due_date, sales_amount, quantity, price) FROM 'report/1_gold_layer_datasets/fact_sales.csv' DELIMITER ',' CSV HEADER;

-- Validation
SELECT COUNT(*) AS customers_loaded FROM gold.dim_customers;
SELECT COUNT(*) AS products_loaded FROM gold.dim_products;
SELECT COUNT(*) AS sales_loaded FROM gold.fact_sales;
