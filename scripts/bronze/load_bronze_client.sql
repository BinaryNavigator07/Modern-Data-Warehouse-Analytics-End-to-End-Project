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
\copy bronze.crm_cust_info FROM 'data/bronze/crm_cust_info.csv' DELIMITER ',' CSV HEADER

TRUNCATE TABLE bronze.crm_prd_info;
\echo '→ Loading crm_prd_info...'
\copy bronze.crm_prd_info FROM 'data/bronze/crm_prd_info.csv' DELIMITER ',' CSV HEADER

TRUNCATE TABLE bronze.crm_sales_details;
\echo '→ Loading crm_sales_details...'
\copy bronze.crm_sales_details FROM 'data/bronze/crm_sales_details.csv' DELIMITER ',' CSV HEADER

-- ERP TABLES
\echo '---------------------------------------------------'
\echo '------------- Loading ERP Tables ------------------'
\echo '---------------------------------------------------'

TRUNCATE TABLE bronze.erp_cust_az12;
\echo '→ Loading erp_cust_az12...'
\copy bronze.erp_cust_az12 FROM 'data/bronze/erp_cust_az12.csv' DELIMITER ',' CSV HEADER

TRUNCATE TABLE bronze.erp_loc_a101;
\echo '→ Loading erp_loc_a101...'
\copy bronze.erp_loc_a101 FROM 'data/bronze/erp_loc_a101.csv' DELIMITER ',' CSV HEADER

TRUNCATE TABLE bronze.erp_px_cat_g1v2;
\echo '→ Loading erp_px_cat_g1v2...'
\copy bronze.erp_px_cat_g1v2 FROM 'data/bronze/erp_px_cat_g1v2.csv' DELIMITER ',' CSV HEADER

-- Done
\echo '---------------------------------------------------'
\echo '✔ Bronze layer loading completed successfully.'
\echo '---------------------------------------------------'
