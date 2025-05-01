-- Truncate the bronze tables
TRUNCATE TABLE bronze.crm_cust_info;
TRUNCATE TABLE bronze.crm_prd_info;
TRUNCATE TABLE bronze.crm_sales_details;
TRUNCATE TABLE bronze.erp_cust_az12;
TRUNCATE TABLE bronze.erp_loc_a101;
TRUNCATE TABLE bronze.erp_px_cat_g1v2;

-- Load data into bronze.crm_cust_info
COPY bronze.crm_cust_info
FROM '/Users/macbookpro/Documents/SQL-Data-Warehouse-Project/datasets/source_crm/cust_info.csv'
DELIMITER ','
CSV HEADER;

-- Load data into bronze.crm_prd_info
COPY bronze.crm_prd_info
FROM '/Users/macbookpro/Documents/SQL-Data-Warehouse-Project/datasets/source_crm/prd_info.csv'
DELIMITER ','
CSV HEADER;

-- Load data into bronze.crm_sales_details
COPY bronze.crm_sales_details
FROM '/Users/macbookpro/Documents/SQL-Data-Warehouse-Project/datasets/source_crm/sales_details.csv'
DELIMITER ','
CSV HEADER;

-- Load data into bronze.erp_cust_az12
COPY bronze.erp_cust_az12
FROM '/Users/macbookpro/Documents/SQL-Data-Warehouse-Project/datasets/source_erp/CUST_AZ12.csv'
DELIMITER ','
CSV HEADER;

-- Load data into bronze.erp_loc_a101
COPY bronze.erp_loc_a101
FROM '/Users/macbookpro/Documents/SQL-Data-Warehouse-Project/datasets/source_erp/LOC_A101.csv'
DELIMITER ','
CSV HEADER;

-- Load data into bronze.erp_px_cat_g1v2
COPY bronze.erp_px_cat_g1v2
FROM '/Users/macbookpro/Documents/SQL-Data-Warehouse-Project/datasets/source_erp/PX_CAT_G1V2.csv'
DELIMITER ','
CSV HEADER;
