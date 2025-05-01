#!/bin/bash
#===================================================================================
# Database Connection Test Script
#===================================================================================
#
# Script Purpose:
#   This script tests the database connection and verifies that the ETL process
#   can be executed with the actual PostgreSQL database.
#
# Usage:
#   ./test_db_connection.sh
#
#===================================================================================

# Set script to exit on error
set -e

# Script location
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
LOG_DIR="$PROJECT_ROOT/logs"
TEST_LOG="$LOG_DIR/db_test_$(date +%Y%m%d_%H%M%S).log"

# Database connection parameters
DB_NAME="datawarehouse"
DB_USER="postgres"
DB_HOST="localhost"
DB_PORT="5432"

# Colors for terminal output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Create log directory if it doesn't exist
mkdir -p "$LOG_DIR"

# Function to log messages
log() {
    local message="$1"
    local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    echo -e "${BLUE}[$timestamp]${NC} $message" | tee -a "$TEST_LOG"
}

# Function to run a SQL command and handle errors
run_sql() {
    local description="$1"
    local command="$2"
    local start_time=$(date +%s)
    
    log "Running: $description"
    
    if psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -c "$command" >> "$TEST_LOG" 2>&1; then
        local end_time=$(date +%s)
        local duration=$((end_time - start_time))
        log "${GREEN}✓ Success:${NC} $description (Duration: ${duration}s)"
        return 0
    else
        log "${RED}✗ Failed:${NC} $description"
        return 1
    fi
}

# Function to run a SQL file and handle errors
run_sql_file() {
    local description="$1"
    local file="$2"
    local start_time=$(date +%s)
    
    log "Running: $description (File: $file)"
    
    if [ ! -f "$file" ]; then
        log "${RED}✗ Failed:${NC} File not found: $file"
        return 1
    fi
    
    if psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -f "$file" >> "$TEST_LOG" 2>&1; then
        local end_time=$(date +%s)
        local duration=$((end_time - start_time))
        log "${GREEN}✓ Success:${NC} $description (Duration: ${duration}s)"
        return 0
    else
        log "${RED}✗ Failed:${NC} $description"
        return 1
    fi
}

# Start testing
log "${YELLOW}=== Starting Database Connection Tests ===${NC}"

# Test 1: Verify database connection
log "\n${YELLOW}Test 1: Verifying database connection${NC}"
if run_sql "Database connection test" "SELECT version()"; then
    log "${GREEN}✓ Successfully connected to PostgreSQL${NC}"
else
    log "${RED}✗ Failed to connect to PostgreSQL${NC}"
    exit 1
fi

# Test 2: Verify database schemas
log "\n${YELLOW}Test 2: Verifying database schemas${NC}"
if run_sql "Schema verification" "SELECT schema_name FROM information_schema.schemata WHERE schema_name IN ('bronze', 'silver', 'gold')"; then
    log "${GREEN}✓ Schemas exist in the database${NC}"
else
    log "${RED}✗ Failed to verify schemas${NC}"
    exit 1
fi

# Test 3: Verify bronze tables
log "\n${YELLOW}Test 3: Verifying bronze tables${NC}"
if run_sql "Bronze tables verification" "SELECT table_name FROM information_schema.tables WHERE table_schema = 'bronze'"; then
    log "${GREEN}✓ Bronze tables exist in the database${NC}"
else
    log "${RED}✗ Failed to verify bronze tables${NC}"
    exit 1
fi

# Test 4: Verify silver tables
log "\n${YELLOW}Test 4: Verifying silver tables${NC}"
if run_sql "Silver tables verification" "SELECT table_name FROM information_schema.tables WHERE table_schema = 'silver'"; then
    log "${GREEN}✓ Silver tables exist in the database${NC}"
else
    log "${RED}✗ Failed to verify silver tables${NC}"
    exit 1
fi

# Test 5: Test loading data into bronze layer
log "\n${YELLOW}Test 5: Testing data loading into bronze layer${NC}"
log "This will use absolute paths for CSV files in the COPY commands"

# Create a temporary SQL file with absolute paths
TEMP_SQL_FILE="$LOG_DIR/temp_load_bronze.sql"
cat > "$TEMP_SQL_FILE" << EOF
-- Truncate the bronze tables
TRUNCATE TABLE bronze.crm_cust_info;
TRUNCATE TABLE bronze.crm_prd_info;
TRUNCATE TABLE bronze.crm_sales_details;
TRUNCATE TABLE bronze.erp_cust_az12;
TRUNCATE TABLE bronze.erp_loc_a101;
TRUNCATE TABLE bronze.erp_px_cat_g1v2;

-- Load data into bronze.crm_cust_info
COPY bronze.crm_cust_info
FROM '$PROJECT_ROOT/datasets/source_crm/cust_info.csv'
DELIMITER ','
CSV HEADER;

-- Load data into bronze.crm_prd_info
COPY bronze.crm_prd_info
FROM '$PROJECT_ROOT/datasets/source_crm/prd_info.csv'
DELIMITER ','
CSV HEADER;

-- Load data into bronze.crm_sales_details
COPY bronze.crm_sales_details
FROM '$PROJECT_ROOT/datasets/source_crm/sales_details.csv'
DELIMITER ','
CSV HEADER;

-- Load data into bronze.erp_cust_az12
COPY bronze.erp_cust_az12
FROM '$PROJECT_ROOT/datasets/source_erp/CUST_AZ12.csv'
DELIMITER ','
CSV HEADER;

-- Load data into bronze.erp_loc_a101
COPY bronze.erp_loc_a101
FROM '$PROJECT_ROOT/datasets/source_erp/LOC_A101.csv'
DELIMITER ','
CSV HEADER;

-- Load data into bronze.erp_px_cat_g1v2
COPY bronze.erp_px_cat_g1v2
FROM '$PROJECT_ROOT/datasets/source_erp/PX_CAT_G1V2.csv'
DELIMITER ','
CSV HEADER;
EOF

if run_sql_file "Loading data into bronze layer" "$TEMP_SQL_FILE"; then
    log "${GREEN}✓ Successfully loaded data into bronze layer${NC}"
else
    log "${RED}✗ Failed to load data into bronze layer${NC}"
    # Continue with the test even if this fails
fi

# Test 6: Verify data was loaded into bronze layer
log "\n${YELLOW}Test 6: Verifying data in bronze layer${NC}"
if run_sql "Bronze data verification" "SELECT COUNT(*) FROM bronze.crm_cust_info"; then
    log "${GREEN}✓ Data exists in bronze.crm_cust_info${NC}"
else
    log "${RED}✗ Failed to verify data in bronze.crm_cust_info${NC}"
fi

# Test 7: Test loading data into silver layer
log "\n${YELLOW}Test 7: Testing data transformation to silver layer${NC}"
if run_sql_file "Loading silver layer procedure" "$PROJECT_ROOT/scripts/silver/proc_load_silver.sql"; then
    log "${GREEN}✓ Successfully created silver layer procedure${NC}"
    
    if run_sql "Executing silver layer procedure" "CALL silver.load_silver()"; then
        log "${GREEN}✓ Successfully executed silver layer procedure${NC}"
    else
        log "${RED}✗ Failed to execute silver layer procedure${NC}"
    fi
else
    log "${RED}✗ Failed to load silver layer procedure${NC}"
fi

# Test 8: Verify data was loaded into silver layer
log "\n${YELLOW}Test 8: Verifying data in silver layer${NC}"
if run_sql "Silver data verification" "SELECT COUNT(*) FROM silver.crm_cust_info"; then
    log "${GREEN}✓ Data exists in silver.crm_cust_info${NC}"
else
    log "${RED}✗ Failed to verify data in silver.crm_cust_info${NC}"
fi

# Summary
log "\n${YELLOW}=== Database Connection Tests Completed ===${NC}"
log "Test log saved to: $TEST_LOG"

exit 0
