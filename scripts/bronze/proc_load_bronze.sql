/*
===================================================================================
Stored Procedure: Load Bronze Layer (Source -> Bronze)
===================================================================================

Script Purpose:
    This stored procedure loads data into the 'Bronze' schema from external CSV files.
    It performs the following actions:
    - Retrieves path configurations from the config.file_paths table
    - Truncates the bronze tables before loading data
    - Uses the 'COPY' command to load data from CSV files to bronze tables
    - Calculates and logs the time taken for each table load
    - Calculates and logs the total batch processing time

Parameters:
    None,
    This stored procedure does not accept any parameters but uses configuration
    values from the config.file_paths table.

Prerequisites:
    Before calling this procedure, you must:
    1. Run the config_paths.sql script to create and populate the config.file_paths table

How to use:
    -- Make sure config.file_paths table exists and is populated
    CALL bronze.load_bronze();

Error Handling:
    The procedure includes error handling with exception blocks to catch and report issues.

Performance Considerations:
    - The procedure uses full table truncation and reload (not incremental loading)
    - Consider adding indexes after loading for better query performance

===================================================================================

*/

CREATE OR REPLACE PROCEDURE bronze.load_bronze()
LANGUAGE plpgsql
AS $BODY$
DECLARE
    rows_count        INTEGER;
	start_time        TIMESTAMP;
    end_time          TIMESTAMP;
    interval_diff     INTERVAL;
	hours             INTEGER;
    minutes           INTEGER;
    seconds           INTEGER;
    milliseconds      INTEGER;
	batch_start_time  TIMESTAMP;
	batch_end_time    TIMESTAMP;
	
	-- File path variable
	file_path TEXT;
BEGIN

	 RAISE NOTICE '==================================================';
	 RAISE NOTICE '=========== LOADING BRONZE LAYER =================';
	 RAISE NOTICE '==================================================';
	 RAISE NOTICE '';
	 
     RAISE NOTICE 'Starting bronze.load_bronze procedure';
	 RAISE NOTICE '';

	 RAISE NOTICE '---------------------------------------------------';
	 RAISE NOTICE '------------- Loading CRM Tables ------------------';
	 RAISE NOTICE '---------------------------------------------------';
	 RAISE NOTICE '';

	--------------------------------------------------------------------------------------------------------
	batch_start_time := NOW();
	start_time := NOW();
	-- Truncate the Table & then Import the csv file
	TRUNCATE TABLE bronze.crm_cust_info;
	
	-- Get the file path from configuration table
	file_path := config.get_path('crm_cust_info_path');
	
	-- Use dynamic SQL to execute the COPY command
	EXECUTE 'COPY bronze.crm_cust_info FROM ''' || file_path || ''' DELIMITER '','' CSV HEADER';
	GET DIAGNOSTICS rows_count = ROW_COUNT;
    RAISE NOTICE 'crm_cust_info: % rows affected', rows_count;
	-- TIME
	end_time := NOW();
    interval_diff := end_time - start_time;
	hours := EXTRACT(HOUR FROM interval_diff);
    minutes := EXTRACT(MINUTE FROM interval_diff);
    seconds := EXTRACT(SECOND FROM interval_diff)::INTEGER;
    milliseconds := EXTRACT(MILLISECONDS FROM interval_diff)::INTEGER % 1000;
	RAISE NOTICE 'Load Duration: % hours, % minutes, % seconds, % milliseconds', hours, minutes, seconds, milliseconds;
    RAISE NOTICE '';
	--------------------------------------------------------------------------------------------------------
	
	--------------------------------------------------------------------------------------------------------
	start_time := NOW();
	-- Truncate the Table & then Import the csv file
	TRUNCATE TABLE bronze.crm_prd_info;
	
	-- Get the file path from configuration table
	file_path := config.get_path('crm_prd_info_path');
	
	-- Use dynamic SQL to execute the COPY command
	EXECUTE 'COPY bronze.crm_prd_info FROM ''' || file_path || ''' DELIMITER '','' CSV HEADER';
	GET DIAGNOSTICS rows_count = ROW_COUNT;
    RAISE NOTICE 'crm_prd_info: % rows affected', rows_count;

    -- TIME
	end_time := NOW();
    interval_diff := end_time - start_time;
	hours := EXTRACT(HOUR FROM interval_diff);
    minutes := EXTRACT(MINUTE FROM interval_diff);
    seconds := EXTRACT(SECOND FROM interval_diff)::INTEGER;
    milliseconds := EXTRACT(MILLISECONDS FROM interval_diff)::INTEGER % 1000;
	RAISE NOTICE 'Load Duration: % hours, % minutes, % seconds, % milliseconds', hours, minutes, seconds, milliseconds;
    RAISE NOTICE '';
	--------------------------------------------------------------------------------------------------------
	

	--------------------------------------------------------------------------------------------------------
	start_time := NOW();
	-- Truncate the Table & then Import the csv file
	TRUNCATE TABLE bronze.crm_sales_details;
	
	-- Get the file path from configuration table
	file_path := config.get_path('crm_sales_details_path');
	
	-- Use dynamic SQL to execute the COPY command
	EXECUTE 'COPY bronze.crm_sales_details FROM ''' || file_path || ''' DELIMITER '','' CSV HEADER';
	GET DIAGNOSTICS rows_count = ROW_COUNT;
    RAISE NOTICE 'crm_sales_details: % rows affected', rows_count;

	-- TIME
	end_time := NOW();
    interval_diff := end_time - start_time;
	hours := EXTRACT(HOUR FROM interval_diff);
    minutes := EXTRACT(MINUTE FROM interval_diff);
    seconds := EXTRACT(SECOND FROM interval_diff)::INTEGER;
    milliseconds := EXTRACT(MILLISECONDS FROM interval_diff)::INTEGER % 1000;
	RAISE NOTICE 'Load Duration: % hours, % minutes, % seconds, % milliseconds', hours, minutes, seconds, milliseconds;
    RAISE NOTICE '';
	--------------------------------------------------------------------------------------------------------
	 
	 RAISE NOTICE '---------------------------------------------------';
	 RAISE NOTICE '------------- Loading ERP Tables ------------------';
	 RAISE NOTICE '---------------------------------------------------';
	 RAISE NOTICE '';
	 
	--------------------------------------------------------------------------------------------------------
	start_time := NOW();
	-- Truncate the Table & then Import the csv file
	TRUNCATE TABLE bronze.erp_cust_az12;
	
	-- Get the file path from configuration table
	file_path := config.get_path('erp_cust_az12_path');
	
	-- Use dynamic SQL to execute the COPY command
	EXECUTE 'COPY bronze.erp_cust_az12 FROM ''' || file_path || ''' DELIMITER '','' CSV HEADER';
	GET DIAGNOSTICS rows_count = ROW_COUNT;
    RAISE NOTICE 'erp_cust_az12: % rows affected', rows_count;

	-- TIME
	end_time := NOW();
    interval_diff := end_time - start_time;
	hours := EXTRACT(HOUR FROM interval_diff);
    minutes := EXTRACT(MINUTE FROM interval_diff);
    seconds := EXTRACT(SECOND FROM interval_diff)::INTEGER;
    milliseconds := EXTRACT(MILLISECONDS FROM interval_diff)::INTEGER % 1000;
	RAISE NOTICE 'Load Duration: % hours, % minutes, % seconds, % milliseconds', hours, minutes, seconds, milliseconds;
    RAISE NOTICE '';
	--------------------------------------------------------------------------------------------------------
	
	--------------------------------------------------------------------------------------------------------
	start_time := NOW();
	-- Truncate the Table & then Import the csv file
	TRUNCATE TABLE bronze.erp_loc_a101;
	
	-- Get the file path from configuration table
	file_path := config.get_path('erp_loc_a101_path');
	
	-- Use dynamic SQL to execute the COPY command
	EXECUTE 'COPY bronze.erp_loc_a101 FROM ''' || file_path || ''' DELIMITER '','' CSV HEADER';
	GET DIAGNOSTICS rows_count = ROW_COUNT;
    RAISE NOTICE 'erp_loc_a101: % rows affected', rows_count;

	-- TIME
	end_time := NOW();
    interval_diff := end_time - start_time;
	hours := EXTRACT(HOUR FROM interval_diff);
    minutes := EXTRACT(MINUTE FROM interval_diff);
    seconds := EXTRACT(SECOND FROM interval_diff)::INTEGER;
    milliseconds := EXTRACT(MILLISECONDS FROM interval_diff)::INTEGER % 1000;
	RAISE NOTICE 'Load Duration: % hours, % minutes, % seconds, % milliseconds', hours, minutes, seconds, milliseconds;
    RAISE NOTICE '';
	--------------------------------------------------------------------------------------------------------
	
	--------------------------------------------------------------------------------------------------------
	start_time := NOW();
	-- Truncate the Table & then Import the csv file
	TRUNCATE TABLE bronze.erp_px_cat_g1v2;
	
	-- Get the file path from configuration table
	file_path := config.get_path('erp_px_cat_g1v2_path');
	
	-- Use dynamic SQL to execute the COPY command
	EXECUTE 'COPY bronze.erp_px_cat_g1v2 FROM ''' || file_path || ''' DELIMITER '','' CSV HEADER';
	GET DIAGNOSTICS rows_count = ROW_COUNT;
    RAISE NOTICE 'erp_px_cat_g1v2: % rows affected', rows_count;

	-- TIME
	end_time := NOW();
    interval_diff := end_time - start_time;
	hours := EXTRACT(HOUR FROM interval_diff);
    minutes := EXTRACT(MINUTE FROM interval_diff);
    seconds := EXTRACT(SECOND FROM interval_diff)::INTEGER;
    milliseconds := EXTRACT(MILLISECONDS FROM interval_diff)::INTEGER % 1000;
	RAISE NOTICE 'Load Duration: % hours, % minutes, % seconds, % milliseconds', hours, minutes, seconds, milliseconds;
    RAISE NOTICE '';
	--------------------------------------------------------------------------------------------------------

	RAISE NOTICE '---------------------------------------------------';
	RAISE NOTICE 'bronze.load_bronze procedure completed';
	batch_end_time := NOW();
	interval_diff := batch_end_time - batch_start_time;
	hours := EXTRACT(HOUR FROM interval_diff);
    minutes := EXTRACT(MINUTE FROM interval_diff);
    seconds := EXTRACT(SECOND FROM interval_diff)::INTEGER;
    milliseconds := EXTRACT(MILLISECONDS FROM interval_diff)::INTEGER % 1000;
	RAISE NOTICE 'Bronze Layer Loading Duration: % hours, % minutes, % seconds, % milliseconds', hours, minutes, seconds, milliseconds;
    RAISE NOTICE '---------------------------------------------------';
	RAISE NOTICE '';
	

	-- Error Handling Logic
	EXCEPTION
	    WHEN OTHERS THEN
	        RAISE NOTICE '----------------------------------------------------';
	        RAISE NOTICE '---- ERROR OCCURRED DURING LOADING BRONZE LAYER -----';
	        RAISE NOTICE 'Error Message: %', SQLERRM;
	        RAISE NOTICE 'Error Code: %', SQLSTATE;
	        RAISE NOTICE '----------------------------------------------------';
	        RAISE NOTICE '';

			-- Rollback the transaction
            ROLLBACK;
	
END;
$BODY$;
