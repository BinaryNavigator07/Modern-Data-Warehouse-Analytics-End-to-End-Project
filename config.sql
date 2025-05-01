/*
===================================================================================
Configuration File for Data Warehouse Project
===================================================================================

Script Purpose:
    This configuration file defines variables used throughout the project,
    including file paths and other settings. This centralizes configuration
    to avoid hardcoding paths in individual scripts.

Key Benefits:
    - Portability: Easily move the project between environments
    - Maintainability: Change paths in one place instead of many files
    - Consistency: All scripts use the same path definitions

How to use:
    1. Update the project_dir variable to match your environment
    2. Include this file at the beginning of your scripts using:
       \i /path/to/config.sql
    3. For stored procedures, also run setup_config.sql after this file

Usage examples:
    -- In a SQL script:
    \i config.sql
    \copy my_table FROM :crm_cust_info_path CSV HEADER;
    
    -- For stored procedures:
    \i config.sql
    \i scripts/setup_config.sql
    CALL bronze.load_bronze();

Variable Naming Convention:
    - All paths use snake_case
    - Source system is prefixed (crm_, erp_)
    - Paths end with _path suffix

===================================================================================
*/

-- Define the base project directory (adjust this to your environment)
\set project_dir '/Users/macbookpro/Documents/SQL-Data-Warehouse-Project'

-- Dataset paths
\set crm_cust_info_path :project_dir '/datasets/source_crm/cust_info.csv'
\set crm_prd_info_path :project_dir '/datasets/source_crm/prd_info.csv'
\set crm_sales_details_path :project_dir '/datasets/source_crm/sales_details.csv'
\set erp_cust_az12_path :project_dir '/datasets/source_erp/CUST_AZ12.csv'
\set erp_loc_a101_path :project_dir '/datasets/source_erp/LOC_A101.csv'
\set erp_px_cat_g1v2_path :project_dir '/datasets/source_erp/PX_CAT_G1V2.csv'

-- Database connection settings (if needed)
\set db_name 'datawarehouse'
