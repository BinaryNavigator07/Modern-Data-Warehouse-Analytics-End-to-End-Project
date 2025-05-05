-- Connect to postgres to drop and recreate the target DB
\c postgres

DROP DATABASE IF EXISTS "DataWarehouseAnalytics";
CREATE DATABASE "DataWarehouseAnalytics";

\c "DataWarehouseAnalytics"

CREATE SCHEMA IF NOT EXISTS gold;

-- Create dimension and fact tables
CREATE TABLE gold.dim_customers (
    customer_key       INT PRIMARY KEY,  -- NOTE: Now this is loaded from CSV
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
    product_key       INT PRIMARY KEY,  -- Also coming from CSV
    product_id        INT,
    product_number    VARCHAR(255),
    product_name      VARCHAR(255),
    category_id       VARCHAR(50),
    category          VARCHAR(255),
    subcategory       VARCHAR(255),
    maintenance       VARCHAR(10),
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

-- Load data using client-side \copy — ensure the path is correct and psql is run from project root
\copy gold.dim_customers FROM 'report/1_gold_layer_datasets/dim_customers.csv' DELIMITER ',' CSV HEADER NULL 'NULL';

\copy gold.dim_products FROM 'report/1_gold_layer_datasets/dim_products.csv' DELIMITER ',' CSV HEADER NULL 'NULL';

\copy gold.fact_sales FROM 'report/1_gold_layer_datasets/fact_sales.csv' DELIMITER ',' CSV HEADER NULL 'NULL';

-- Validation
SELECT COUNT(*) AS customers_loaded FROM gold.dim_customers;
SELECT COUNT(*) AS products_loaded FROM gold.dim_products;
SELECT COUNT(*) AS sales_loaded FROM gold.fact_sales;
