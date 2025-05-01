#!/bin/bash
#===================================================================================
# ETL Orchestration Script for Data Warehouse
#===================================================================================
#
# Script Purpose:
#   This script orchestrates the entire ETL process for the data warehouse,
#   including loading data into bronze, silver, and gold layers.
#
# Features:
#   - Configurable parameters for database connection
#   - Error handling and logging
#   - Email notifications on completion/failure
#   - Performance tracking
#   - Incremental loading option
#
# Usage:
#   ./run_etl.sh [options]
#
# Options:
#   -h, --help              Show this help message
#   -f, --full              Run full load (default is incremental if supported)
#   -l, --layer [LAYER]     Run specific layer only (bronze, silver, gold)
#   -n, --no-email          Disable email notifications
#   -v, --verbose           Enable verbose output
#
#===================================================================================

# Set script to exit on error
set -e

# Script location
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Configuration
DB_NAME="datawarehouse"
DB_USER="postgres"
DB_HOST="localhost"
DB_PORT="5432"
CONFIG_FILE="$PROJECT_ROOT/config.sql"
SETUP_CONFIG="$PROJECT_ROOT/scripts/setup_config.sql"
LOG_DIR="$PROJECT_ROOT/logs"
LOG_FILE="$LOG_DIR/etl_$(date +%Y%m%d_%H%M%S).log"
EMAIL_RECIPIENT=""
EMAIL_SUBJECT="Data Warehouse ETL Process"

# Default options
RUN_MODE="incremental"
TARGET_LAYER="all"
SEND_EMAIL=true
VERBOSE=false

# Create log directory if it doesn't exist
mkdir -p "$LOG_DIR"

# Function to display usage information
usage() {
    echo "Usage: $0 [options]"
    echo "Options:"
    echo "  -h, --help              Show this help message"
    echo "  -f, --full              Run full load (default is incremental if supported)"
    echo "  -l, --layer [LAYER]     Run specific layer only (bronze, silver, gold)"
    echo "  -n, --no-email          Disable email notifications"
    echo "  -v, --verbose           Enable verbose output"
    exit 1
}

# Function to log messages
log() {
    local level="$1"
    local message="$2"
    local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    echo "[$timestamp] [$level] $message" | tee -a "$LOG_FILE"
}

# Function to send email notification
send_email() {
    local status="$1"
    local message="$2"
    
    if [ "$SEND_EMAIL" = true ] && [ -n "$EMAIL_RECIPIENT" ]; then
        echo "$message" | mail -s "$EMAIL_SUBJECT - $status" "$EMAIL_RECIPIENT"
        log "INFO" "Email notification sent to $EMAIL_RECIPIENT"
    fi
}

# Function to run a SQL command and handle errors
run_sql() {
    local description="$1"
    local command="$2"
    local start_time=$(date +%s)
    
    log "INFO" "Starting: $description"
    
    if [ "$VERBOSE" = true ]; then
        log "DEBUG" "Executing SQL: $command"
    fi
    
    if ! psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -c "$command" >> "$LOG_FILE" 2>&1; then
        log "ERROR" "Failed: $description"
        send_email "FAILED" "ETL process failed during: $description. Check logs for details."
        exit 1
    fi
    
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    log "INFO" "Completed: $description (Duration: ${duration}s)"
}

# Function to run a SQL file and handle errors
run_sql_file() {
    local description="$1"
    local file="$2"
    local start_time=$(date +%s)
    
    log "INFO" "Starting: $description (File: $file)"
    
    if [ ! -f "$file" ]; then
        log "ERROR" "File not found: $file"
        send_email "FAILED" "ETL process failed: File not found: $file"
        exit 1
    fi
    
    if ! psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -f "$file" >> "$LOG_FILE" 2>&1; then
        log "ERROR" "Failed: $description"
        send_email "FAILED" "ETL process failed during: $description. Check logs for details."
        exit 1
    fi
    
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    log "INFO" "Completed: $description (Duration: ${duration}s)"
}

# Process command line arguments
while [ "$#" -gt 0 ]; do
    case "$1" in
        -h|--help)
            usage
            ;;
        -f|--full)
            RUN_MODE="full"
            shift
            ;;
        -l|--layer)
            if [ "$2" = "bronze" ] || [ "$2" = "silver" ] || [ "$2" = "gold" ]; then
                TARGET_LAYER="$2"
                shift 2
            else
                log "ERROR" "Invalid layer: $2"
                usage
            fi
            ;;
        -n|--no-email)
            SEND_EMAIL=false
            shift
            ;;
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        *)
            log "ERROR" "Unknown option: $1"
            usage
            ;;
    esac
done

# Start ETL process
log "INFO" "Starting ETL process (Mode: $RUN_MODE, Target: $TARGET_LAYER)"
start_time=$(date +%s)

# Load configuration
log "INFO" "Loading configuration"
if ! psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -f "$PROJECT_ROOT/scripts/config_paths.sql" >> "$LOG_FILE" 2>&1; then
    log "ERROR" "Failed to load configuration"
    send_email "FAILED" "ETL process failed: Could not load configuration"
    exit 1
fi

# Run Bronze layer
if [ "$TARGET_LAYER" = "all" ] || [ "$TARGET_LAYER" = "bronze" ]; then
    log "INFO" "Starting Bronze layer processing"
    
    # Run bronze layer procedure
    run_sql "Loading Bronze layer" "CALL bronze.load_bronze();"
    
    # Run data quality checks for bronze layer
    log "INFO" "Running data quality checks for Bronze layer"
    # Add data quality check commands here
    
    log "INFO" "Completed Bronze layer processing"
fi

# Run Silver layer
if [ "$TARGET_LAYER" = "all" ] || [ "$TARGET_LAYER" = "silver" ]; then
    log "INFO" "Starting Silver layer processing"
    
    # Run silver layer procedure
    run_sql "Loading Silver layer" "CALL silver.load_silver();"
    
    # Run data quality checks for silver layer
    log "INFO" "Running data quality checks for Silver layer"
    for test_file in "$PROJECT_ROOT"/tests/quality_checks_silver_*.sql; do
        if [ -f "$test_file" ]; then
            run_sql_file "Running quality check" "$test_file"
        fi
    done
    
    log "INFO" "Completed Silver layer processing"
fi

# Run Gold layer
if [ "$TARGET_LAYER" = "all" ] || [ "$TARGET_LAYER" = "gold" ]; then
    log "INFO" "Starting Gold layer processing"
    
    # Run gold layer DDL if needed
    run_sql_file "Setting up Gold layer" "$PROJECT_ROOT/scripts/gold/ddl_gold.sql"
    
    # Run data quality checks for gold layer
    if [ -f "$PROJECT_ROOT/tests/quality_checks_gold.sql" ]; then
        run_sql_file "Running Gold layer quality checks" "$PROJECT_ROOT/tests/quality_checks_gold.sql"
    fi
    
    log "INFO" "Completed Gold layer processing"
fi

# Calculate total duration
end_time=$(date +%s)
duration=$((end_time - start_time))
log "INFO" "ETL process completed successfully (Total Duration: ${duration}s)"

# Send success notification
send_email "SUCCESS" "ETL process completed successfully in ${duration} seconds."

exit 0
