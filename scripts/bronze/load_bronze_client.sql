\echo '=================================================='
\echo '=========== LOADING BRONZE LAYER ================='
\echo '=================================================='

-- TIMING: Start full batch
\set start_time :'now'

-- CRM TABLES
\echo '---------------------------------------------------'
\echo '------------- Loading CRM Tables ------------------'
\echo '---------------------------------------------------'

TRUNCATE TABLE bronze.crm_cust_info;
\echo '→ Loading crm_cust_info...'
\copy bronze.crm_cust_info FROM 'datasets/source_crm/cust_info.csv' DELIMITER ',' CSV HEADER

TRUNCATE TABLE bronze.crm_prd_info;
\echo '→ Loading crm_prd_info...'
\copy bronze.crm_prd_info FROM 'datasets/source_crm/prd_info.csv' DELIMITER ',' CSV HEADER

TRUNCATE TABLE bronze.crm_sales_details;
\echo '→ Loading crm_sales_details...'
\copy bronze.crm_sales_details FROM 'datasets/source_crm/sales_details.csv' DELIMITER ',' CSV HEADER

-- ERP TABLES
\echo '---------------------------------------------------'
\echo '------------- Loading ERP Tables ------------------'
\echo '---------------------------------------------------'

TRUNCATE TABLE bronze.erp_cust_az12;
\echo '→ Loading erp_cust_az12...'
\copy bronze.erp_cust_az12 FROM 'datasets/source_erp/CUST_AZ12.csv' DELIMITER ',' CSV HEADER

TRUNCATE TABLE bronze.erp_loc_a101;
\echo '→ Loading erp_loc_a101...'
\copy bronze.erp_loc_a101 FROM 'datasets/source_erp/LOC_A101.csv' DELIMITER ',' CSV HEADER

TRUNCATE TABLE bronze.erp_px_cat_g1v2;
\echo '→ Loading erp_px_cat_g1v2...'
\copy bronze.erp_px_cat_g1v2 FROM 'datasets/source_erp/PX_CAT_G1V2.csv' DELIMITER ',' CSV HEADER

-- Done
\echo '---------------------------------------------------'
\echo '✔ Bronze layer loading completed successfully.'
\echo '---------------------------------------------------'
