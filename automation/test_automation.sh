#!/bin/bash
#===================================================================================
# Test Script for Data Warehouse Automation
#===================================================================================
#
# Script Purpose:
#   This script tests all components of the automation system without requiring
#   a full database connection. It verifies script functionality, logging,
#   and monitoring capabilities.
#
# Usage:
#   ./test_automation.sh
#
#===================================================================================

# Set script to exit on error
set -e

# Script location
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
LOG_DIR="$PROJECT_ROOT/logs"
TEST_LOG="$LOG_DIR/test_automation_$(date +%Y%m%d_%H%M%S).log"

# Colors for terminal output
RED='\033[0;31m'
GREEN='\033[0;32m'
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

# Function to simulate ETL process
simulate_etl() {
    local layer="$1"
    local duration="$2"
    
    log "Simulating $layer layer processing..."
    echo "[$(date +"%Y-%m-%d %H:%M:%S")] [INFO] Starting $layer layer processing" >> "$LOG_DIR/etl_$(date +%Y%m%d_%H%M%S).log"
    
    # Simulate processing time
    sleep "$duration"
    
    echo "[$(date +"%Y-%m-%d %H:%M:%S")] [INFO] Completed $layer layer processing (Duration: ${duration}s)" >> "$LOG_DIR/etl_$(date +%Y%m%d_%H%M%S).log"
    log "Completed $layer layer processing (Duration: ${duration}s)"
}

# Function to test a component
test_component() {
    local component="$1"
    local command="$2"
    
    log "${YELLOW}Testing: $component${NC}"
    log "Command: $command"
    
    if eval "$command"; then
        log "${GREEN}✓ Test passed: $component${NC}"
        return 0
    else
        log "${RED}✗ Test failed: $component${NC}"
        return 1
    fi
}

# Start testing
log "${BLUE}=== Starting Automation System Tests ===${NC}"

# Test 1: Create a simulated ETL log
log "\n${YELLOW}Test 1: Creating simulated ETL logs${NC}"
ETL_LOG="$LOG_DIR/etl_$(date +%Y%m%d_%H%M%S).log"
echo "[$(date +"%Y-%m-%d %H:%M:%S")] [INFO] Starting ETL process (Mode: test, Target: all)" > "$ETL_LOG"
echo "[$(date +"%Y-%m-%d %H:%M:%S")] [INFO] Loading configuration" >> "$ETL_LOG"

# Simulate the ETL process for each layer
simulate_etl "Bronze" 2
simulate_etl "Silver" 3
simulate_etl "Gold" 1

# Add completion message
echo "[$(date +"%Y-%m-%d %H:%M:%S")] [INFO] ETL process completed successfully (Total Duration: 6s)" >> "$ETL_LOG"
log "${GREEN}✓ Created simulated ETL logs${NC}"

# Test 2: Test ETL Monitor Status
log "\n${YELLOW}Test 2: Testing ETL Monitor Status${NC}"
test_component "ETL Monitor Status" "$SCRIPT_DIR/etl_monitor.sh --status"

# Test 3: Test ETL Monitor Logs
log "\n${YELLOW}Test 3: Testing ETL Monitor Logs${NC}"
test_component "ETL Monitor Logs" "$SCRIPT_DIR/etl_monitor.sh --logs 5"

# Test 4: Test ETL Monitor Performance
log "\n${YELLOW}Test 4: Testing ETL Monitor Performance${NC}"
test_component "ETL Monitor Performance" "$SCRIPT_DIR/etl_monitor.sh --performance"

# Test 5: Test Schedule ETL (with --remove to avoid actually scheduling)
log "\n${YELLOW}Test 5: Testing Schedule ETL${NC}"
test_component "Schedule ETL" "$SCRIPT_DIR/schedule_etl.sh --daily 03:30 && $SCRIPT_DIR/schedule_etl.sh --remove"

# Test 6: Simulate an error in ETL
log "\n${YELLOW}Test 6: Simulating ETL Error${NC}"
ERROR_LOG="$LOG_DIR/etl_error_$(date +%Y%m%d_%H%M%S).log"
echo "[$(date +"%Y-%m-%d %H:%M:%S")] [INFO] Starting ETL process (Mode: test, Target: all)" > "$ERROR_LOG"
echo "[$(date +"%Y-%m-%d %H:%M:%S")] [INFO] Loading configuration" >> "$ERROR_LOG"
echo "[$(date +"%Y-%m-%d %H:%M:%S")] [ERROR] Failed to connect to database: Connection refused" >> "$ERROR_LOG"
echo "[$(date +"%Y-%m-%d %H:%M:%S")] [INFO] ETL process failed" >> "$ERROR_LOG"
log "${GREEN}✓ Created simulated ETL error log${NC}"

# Test 7: Test ETL Monitor Errors
log "\n${YELLOW}Test 7: Testing ETL Monitor Errors${NC}"
test_component "ETL Monitor Errors" "$SCRIPT_DIR/etl_monitor.sh --errors"

# Summary
log "\n${BLUE}=== Automation System Tests Completed ===${NC}"
log "Test log saved to: $TEST_LOG"
log "You can review the simulated ETL logs in: $LOG_DIR"

exit 0
