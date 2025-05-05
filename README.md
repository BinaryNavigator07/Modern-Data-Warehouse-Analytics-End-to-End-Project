# 📊 Project Title: Modern Data Warehouse & Analytics

## Overview

This project addresses the challenge of transforming raw business data from multiple sources (ERP and CRM systems) into actionable business insights through a modern data warehouse solution. It provides a scalable, efficient, and analytics-ready architecture, integrating robust ETL pipelines, data modeling (Star Schema), Exploratory Data Analysis (EDA), and comprehensive SQL-based reporting.

---

## 📁 Project Structure

```
Modern-Data-Warehouse-Analytics-End-to-End-Project/
│
├── automation/                         # [Automation scripts and setup](automation/README.md)
│
├── datasets/                           # [Datasets and details](datasets/README.md)
│
├── docs/                               # [Comprehensive documentation](docs/README.md)
│   ├── bronze/                         # [Bronze layer documentation](docs/bronze/README.md)
│   ├── silver/                         # [Silver layer documentation](docs/silver/README.md)
│   ├── gold/                           # [Gold layer documentation](docs/gold/README.md)
│   ├── warehouse/                      # [Warehouse overall documentation](docs/warehouse/README.md)
│   └── my_notes/                       # Additional project diagrams and notes
│
├── logs/                               # ETL execution logs
│
├── scripts/                            # [ETL and transformation scripts](scripts/README.md)
│   ├── bronze/
│   ├── silver/
│   ├── gold/
│   ├── config_paths.sql
│   ├── init_database.sql
│   └── setup_config.sql
│
├── tests/                              # [Quality control tests](tests/README.md)
│
├── report/                             # [Analysis and reporting scripts](report/README.md)
│   ├── 1_gold_layer_datasets/
│   ├── 2_eda_scripts/
│   └── 3_advanced_eda/
│
├── CONFIG_README.md                    # [Configuration system overview](CONFIG_README.md)
├── LICENSE                             # License information
├── README.md                           # Project overview and instructions (this file)
├── requirements.txt                    # Python dependencies
└── config.sql                          # SQL configuration settings
```

---

## 🔧 Setup and Installation Instructions


### 1. Install Prerequisites
(If you want to run on you local machine then you need to install the following or connect to the server)

* Install [PostgreSQL](https://www.postgresql.org/download/)

* If you are working on the server
(ask the admin to create a role for you)

``` bash
sudo -i -u postgres
psql
CREATE ROLE <your username here> WITH LOGIN CREATEDB;
\q
```


## 🛠️ Step-by-Step Guide

### 1. Initialize Database
* Script Purpose:
    This script creates a new database named 'datawarehouse' after checking if it already exists.
    First, it terminates active connections if the database is active, then it is dropped and recreated.
    Additionally, the script sets up three schemas within the database: 'bronze', 'silver', and 'gold'.


* WARNING:
    Running this script will drop the entire 'datawarehouse' database if it exists.
    All data in the database will be permanently deleted. Proceed with caution
    and ensure you have proper backups before running this script.

```bash
psql -f scripts/init_database.sql
```

### 2. Configure Paths

* Script Purpose:
    This script creates a configuration table to store path variables for the ETL process.
    It provides a centralized location for managing file paths that can be easily updated.

``` bash
psql datawarehouse -f scripts/config_paths.sql
```

### 3. Load Data into Bronze Layer
* Script Purpose:
    This script creates tables in the 'bronze' schema, dropping existing tables 
    if they already exist.
	  Run this script to re-define the DDL structure of 'bronze' Tables
``` bash
psql datawarehouse -f scripts/bronze/ddl_bronze.sql
```

* Script Purpose:
    This stored procedure loads data into the 'Bronze' schema from external CSV files.
    It performs the following actions:
    - Retrieves path configurations from the config.file_paths table
    - Truncates the bronze tables before loading data
    - Uses the 'COPY' command to load data from CSV files to bronze tables
    - Calculates and logs the time taken for each table load
    - Calculates and logs the total batch processing time

* Prerequisites:
    Before calling this procedure, you must:
    1. Run the config_paths.sql script to create and populate the config.file_paths table

```bash
psql datawarehouse -f scripts/bronze/proc_load_bronze.sql
```
* Call the procedure to load data into the bronze layer:
```bash
psql datawarehouse -c "CALL bronze.load_bronze();"
```
* Note: The procedure will need admin privileges to run successfully. If you encounter permission issues, please run this workaround file

This script automates the loading of raw source data from CSV files into the Bronze layer of the data warehouse. It performs the following actions:
Truncates existing records in Bronze tables to ensure clean reloading.
Load CRM-related datasets from datasets/source_crm/
Load ERP-related datasets from datasets/source_erp/
Ensures the Bronze layer reflects the most recent raw data extracts.
Is designed for non-superuser environments (e.g., local development) where COPY is not permitted.
This script serves as the entry point for the ETL pipeline, transforming raw CSVs into structured relational tables, ready for cleansing and transformation in the Silver layer.
```bash
psql datawarehouse -f scripts/bronze/load_bronze_client.sql
```

### 4. Transform Data into Silver Layer

* Script Purpose:
    This script creates tables in the 'silver' schema, dropping existing tables 
    if they already exist.
	  Run this script to re-define the DDL structure of 'silver' Tables
``` bash
psql datawarehouse -f scripts/silver/ddl_silver.sql
``` 

* Script Purpose:
    This stored procedure peroforms the ETL(Extract, Transform, Load) process to 
    Populate the  'silver' schema tables from the 'bronze' schema.

    It performs the following actions:
    - Truncates the silver tables before loading data.
    - Insert the clean and transformed date from Bronze into Silver Tables.

```bash
psql datawarehouse -f scripts/silver/proc_load_silver.sql
```
* Call the procedure to load data into the silver layer:
```bash
psql datawarehouse -c "CALL silver.load_silver();"
```

### 5. Transform Data into Gold Layer
* Script Purpose:
    This script creates views for the Gold layer in the data warehouse. 
    The Gold layer represents the final dimension and fact tables (Star Schema)

    Each view performs transformations and combines data from the Silver layer 
    to produce a clean, enriched, and business-ready dataset.
``` bash
psql datawarehouse -f scripts/gold/ddl_gold.sql
```

### 6. Run EDA Scripts

* Script Purpose:
    This script creates a new database named 'DataWarehouseAnalytics' if it doesn't already exist.
    It then creates three schemas within the database: 'bronze', 'silver', and 'gold'.

* WARNING:
    Running this script might require you to manually drop the database if it exists due to PostgreSQL's 
    handling of concurrent connections.  It's best practice to connect to a different database (e.g., 'postgres')
    to drop 'DataWarehouseAnalytics' if it exists.

``` bash
psql -f report/2_eda_scripts/00_init_database.sql
```

* Script Purpose:
    - To explore the structure of the database, including the list of tables and their schemas.
* Table Used:
    - INFORMATION_SCHEMA.TABLES
    - INFORMATION_SCHEMA.COLUMNS
    - To inspect the columns and metadata for specific tables.

``` bash 
psql DataWarehouseAnalytics -f report/2_eda_scripts/01_database_exploration.sql
```

* Script Purpose:
    - To explore the structure of dimension tables.

SQL Functions Used:
    - DISTINCT
    - ORDER BY

```bash
psql DataWarehouseAnalytics -f report/2_eda_scripts/02_dimensions_exploration.sql
```

* Script Purpose:
    - To determine the temporal boundaries of key data points.
    - To understand the range of historical data.

SQL Functions Used:
    - MIN(), MAX(), EXTRACT(), AGE()

```bash
psql DataWarehouseAnalytics -f report/2_eda_scripts/03_date_range_exploration.sql
```

*Script Purpose:
    - To calculate aggregated metrics (e.g., totals, averages) for quick insights.
    - To identify overall trends or spot anomalies.

SQL Functions Used:
    - COUNT(), SUM(), AVG(), DISTINCT()

```bash 
psql DataWarehouseAnalytics -f report/2_eda_scripts/04_measures_exploration.sql
```
Script Purpose:
    - To quantify data and group results by specific dimensions.
    - For understanding data distribution across categories.

SQL Functions Used:
    - Aggregate Functions: SUM(), COUNT(), AVG()
    - GROUP BY, ORDER BY
```bash
psql DataWarehouseAnalytics -f report/2_eda_scripts/05_magnitude_analysis.sql
```
* Script Purpose:
    - To rank items (e.g., products, customers) based on performance or other metrics.
    - To identify top performers or laggards.

SQL Functions Used:
    - Window Ranking Functions: RANK(), DENSE_RANK(), ROW_NUMBER()
    - Clauses: GROUP BY, ORDER BY, LIMIT
```bash
psql DataWarehouseAnalytics -f report/2_eda_scripts/06_ranking_analysis.sql
```


### 7 Run Advanced EDA Scripts
* Script Purpose:
    - To track trends, growth, and changes in key metrics over time.
    - For time-series analysis and identifying seasonality.
    - To measure growth or decline over specific periods.

SQL Functions Used:
    - Date/Time Functions: EXTRACT(), DATE_TRUNC(), TO_CHAR()
    - Aggregate Functions: SUM(), COUNT(), AVG()
```bash
psql DataWarehouseAnalytics -f report/3_advanced_eda/07_change_over_time_analysis.sql
```
* Script Purpose:
    - To calculate running totals or moving averages for key metrics.
    - To track performance over time cumulatively.
    - Useful for growth analysis or identifying long-term trends.

SQL Functions Used:
    - Window Functions: SUM() OVER(), AVG() OVER()
```bash
psql DataWarehouseAnalytics -f report/3_advanced_eda/08_cumulative_analysis.sql
```

* Script Purpose:
    - To analyze product sales performance year over year.
    - To compare current year sales to the product's average sales and the 
      previous year's sales.
    - To identify trends and growth patterns.

SQL Functions Used:
    - LAG(): Accesses data from previous rows.
    - AVG() OVER(): Computes average values within partitions.
    - CASE: Defines conditional logic for trend analysis.
```bash
psql DataWarehouseAnalytics -f report/3_advanced_eda/09_performance_analysis.sql
```
* Script Purpose:
    - To group data into meaningful categories for targeted insights.
    - For customer segmentation, product categorization, or regional analysis.

SQL Functions Used:
    - CASE: Defines custom segmentation logic.
    - GROUP BY: Groups data into segments.

```bash
psql DataWarehouseAnalytics -f report/3_advanced_eda/10_data_segmentation.sql
```
* Script Purpose:
    - To compare performance or metrics across dimensions or time periods.
    - To evaluate differences between categories.
    - Useful for A/B testing or regional comparisons.

SQL Functions Used:
    - SUM(), AVG(): Aggregates values for comparison.
    - Window Functions: SUM() OVER() for total calculations.
```bash
psql DataWarehouseAnalytics -f report/3_advanced_eda/11_part_to_whole_analysis.sql
```

### Report from the Gold layer

*Script Purpose:
    - This report consolidates key customer metrics and behaviors.

Highlights:
    1. Gathers essential fields such as names, ages, and transaction details.
    2. Segments customers into categories (VIP, Regular, New) and age groups.
    3. Aggregates customer-level metrics:
        - total orders
        - total sales
        - total quantity purchased
        - total products
        - lifespan (in months)
    4. Calculates valuable KPIs:
        - recency (months since last order)
        - average order value
        - average monthly spend
```bash
psql DataWarehouseAnalytics -f report/12_report_customers.sql
```
*Script Purpose:
    - This report consolidates key product metrics and behaviors.

Highlights:
    1. Gathers essential fields such as product name, category, subcategory, and cost.
    2. Segments products by revenue to identify High-Performers, Mid-Range, or Low-Performers.
    3. Aggregates product-level metrics:
        - total orders
        - total sales
        - total quantity sold
        - total customers (unique)
        - lifespan (in months)
    4. Calculates valuable KPIs:
        - recency (months since last sale)
        - average order revenue (AOR)
        - average monthly revenue
How to used:
	- SELECT * FROM gold.product_report; 
```bash 
psql DataWarehouseAnalytics -f report/13_report_products.sql
```

### Step 6: Database Configuration (for deployment)

If you need to deploy, set the path according to CWD:

* Edit `scripts/config_paths.sql` to set paths
* Load datasets into the `/datasets/` folder

---

## 📊 Results

Results are located within the `report/output` directory:

* **EDA Visualizations**: Provide insight into data distributions and trends.
* **Analytics Reports**: Key insights such as customer behavior, product performance, and sales trends.

---

## 🚀 Project Requirements

* **Data Engineering**: ETL pipeline consolidating ERP & CRM sales data
* **Data Quality**: Comprehensive data cleaning and validation
* **Data Modeling**: Implemented star schema
* **BI Analytics**: Actionable business insights and reporting

---

## 🗃️ Dataset Structure

* CRM Source: `cust_info.csv`, `prd_info.csv`, `sales_details.csv`
* ERP Source: `cust_az12.csv`, `erp_loc_a101.csv`, `erp_px_cat_g1v2.csv`

---

## 🗄️ Tables

* **Customer Info**: Core customer details
* **Product Info**: Product details and lifecycle
* **Sales Details**: Transaction records
* **Customer Extra Details**: Additional demographic data
* **Location**: Geographic details
* **Category**: Product categorization

---

## 🪴 Relationships

* **One-to-many**: Sales → Product/Customer
* **One-to-one**: Customer Extra/Location → Customer

---

## 🧰 Automation

* **ETL Orchestration**: `run_etl.sh`
* **Scheduling**: `schedule_etl.sh`
* **Monitoring**: `etl_monitor.sh`

---

## ⚙️ Configuration

Centralized path management using `config_paths.sql`. Adjust paths dynamically for different environments.

---

## 📖 Additional Documentation

* **[Naming conventions](docs/warehouse/naming_conventions.md)**
* **[Data catalog](docs/gold/data_catalog.md)**
* **[Testing procedures](tests/README.md)**

---

## 📟 Notes

* Utilize UUIDs for scalability
* Remove redundant columns
* Consistent data types for database efficiency
