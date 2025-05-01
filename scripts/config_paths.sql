/*
===================================================================================
Configuration Paths for Data Warehouse Project
===================================================================================

Script Purpose:
    This script creates a configuration table to store path variables for the ETL process.
    It provides a centralized location for managing file paths that can be easily updated.

How to use:
    1. Run this script to create and populate the configuration table
    2. ETL procedures will query this table to get the file paths

===================================================================================
*/

-- Create schema for configuration if it doesn't exist
CREATE SCHEMA IF NOT EXISTS config;

-- Drop the table if it exists
DROP TABLE IF EXISTS config.file_paths;

-- Create the configuration table
CREATE TABLE config.file_paths (
    path_key VARCHAR(100) PRIMARY KEY,
    path_value TEXT NOT NULL,
    description TEXT,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert the file paths
INSERT INTO config.file_paths (path_key, path_value, description) VALUES
('crm_cust_info_path', '/Users/macbookpro/Documents/SQL-Data-Warehouse-Project/datasets/source_crm/cust_info.csv', 'Path to CRM customer information CSV file'),
('crm_prd_info_path', '/Users/macbookpro/Documents/SQL-Data-Warehouse-Project/datasets/source_crm/prd_info.csv', 'Path to CRM product information CSV file'),
('crm_sales_details_path', '/Users/macbookpro/Documents/SQL-Data-Warehouse-Project/datasets/source_crm/sales_details.csv', 'Path to CRM sales details CSV file'),
('erp_cust_az12_path', '/Users/macbookpro/Documents/SQL-Data-Warehouse-Project/datasets/source_erp/CUST_AZ12.csv', 'Path to ERP customer AZ12 CSV file'),
('erp_loc_a101_path', '/Users/macbookpro/Documents/SQL-Data-Warehouse-Project/datasets/source_erp/LOC_A101.csv', 'Path to ERP location A101 CSV file'),
('erp_px_cat_g1v2_path', '/Users/macbookpro/Documents/SQL-Data-Warehouse-Project/datasets/source_erp/PX_CAT_G1V2.csv', 'Path to ERP PX category G1V2 CSV file');

-- Function to get a path value
CREATE OR REPLACE FUNCTION config.get_path(p_key VARCHAR)
RETURNS TEXT AS $$
DECLARE
    v_path TEXT;
BEGIN
    SELECT path_value INTO v_path
    FROM config.file_paths
    WHERE path_key = p_key;
    
    RETURN v_path;
END;
$$ LANGUAGE plpgsql;
