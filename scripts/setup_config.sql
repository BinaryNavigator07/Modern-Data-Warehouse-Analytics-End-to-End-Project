/*
===================================================================================
Setup Configuration Variables for PostgreSQL
===================================================================================

Script Purpose:
    This script sets up PostgreSQL configuration variables based on the values
    defined in config.sql. It converts the psql variables to PostgreSQL GUC
    (Grand Unified Configuration) variables that can be accessed from stored procedures.

Background:
    PostgreSQL has two separate variable systems:
    1. psql variables (\set) - These are client-side variables only accessible in psql scripts
    2. GUC variables - These are server-side variables accessible from stored procedures
    
    This script bridges the gap by transferring values from psql variables to GUC variables.

How to use:
    Run this script after loading config.sql and before executing any procedures:
    \i /path/to/config.sql
    \i /path/to/setup_config.sql
    CALL bronze.load_bronze();

Example workflow:
    -- In psql terminal:
    \i config.sql
    \i scripts/setup_config.sql
    -- Now the configuration is available to procedures
    CALL bronze.load_bronze();
    
    -- In a script file:
    \o output.log
    \i config.sql
    \i scripts/setup_config.sql
    CALL bronze.load_bronze();
    \o

Troubleshooting:
    If you encounter "unrecognized configuration parameter" errors:
    1. Verify that config.sql was loaded first
    2. Check that the variable names match between config.sql and this script
    3. Ensure the PostgreSQL user has permission to modify GUC parameters

===================================================================================
*/

-- Set GUC variables with absolute paths
SELECT set_config('crm_cust_info_path', './datasets/source_crm/cust_info.csv', false);
SELECT set_config('crm_prd_info_path', './datasets/source_crm/prd_info.csv', false);
SELECT set_config('crm_sales_details_path', './datasets/source_crm/sales_details.csv', false);
SELECT set_config('erp_cust_az12_path', './datasets/source_erp/CUST_AZ12.csv', false);
SELECT set_config('erp_loc_a101_path', './datasets/source_erp/LOC_A101.csv', false);
SELECT set_config('erp_px_cat_g1v2_path', './datasets/source_erp/PX_CAT_G1V2.csv', false);

-- Verify the variables were set correctly
SELECT name, setting FROM pg_settings 
WHERE name IN (
    'crm_cust_info_path',
    'crm_prd_info_path',
    'crm_sales_details_path',
    'erp_cust_az12_path',
    'erp_loc_a101_path',
    'erp_px_cat_g1v2_path'
);
