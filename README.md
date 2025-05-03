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

### 1. Clone the Repository

```bash
git clone https://github.com/BinaryNavigator07/Modern-Data-Warehouse-Analytics-End-to-End-Project
```

### 2. Install Prerequisites

* Install [PostgreSQL](https://www.postgresql.org/download/)

### 3. Database Configuration

* Edit `scripts/config_paths.sql` to set paths
* Load datasets into the `/datasets/` folder

### 4. Initialize Database

```bash
psql -f scripts/init_database.sql -f scripts/config_paths.sql
```

### 5. Run ETL Processes

* Manually:

```bash
CALL bronze.load_bronze();
CALL silver.load_silver();
psql -f scripts/gold/ddl_gold.sql
```

* Using Automation:

```bash
./automation/run_etl.sh
./automation/schedule_etl.sh
./automation/etl_monitor.sh
```

---

## 🛠️ Step-by-Step Guide

### Step 1:

Run database initialization:

```bash
psql -f scripts/init_database.sql -f scripts/config_paths.sql
```

### Step 2:

Load Bronze layer data:

```bash
psql -c "CALL bronze.load_bronze();"
```

### Step 3:

Load Silver layer data:

```bash
psql -c "CALL silver.load_silver();"
```

### Step 4:

Setup Gold layer views:

```bash
psql -f scripts/gold/ddl_gold.sql
```

### Step 5:

Automate ETL pipeline:

```bash
./automation/run_etl.sh
./automation/schedule_etl.sh
```

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
