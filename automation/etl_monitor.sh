#!/bin/bash
#===================================================================================
# ETL Monitoring Dashboard for Data Warehouse
#===================================================================================
#
# Script Purpose:
#   This script provides monitoring capabilities for the ETL process,
#   including job status, execution history, and performance metrics.
#
# Features:
#   - Real-time status monitoring
#   - Historical execution tracking
#   - Performance metrics visualization
#   - Error reporting and alerting
#
# Usage:
#   ./etl_monitor.sh [options]
#
# Options:
#   -h, --help              Show this help message
#   -s, --status            Show current ETL job status
#   -l, --logs [N]          Show last N log entries (default: 10)
#   -p, --performance       Show performance metrics
#   -e, --errors            Show recent errors
#
#===================================================================================

# Script location
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
LOG_DIR="$PROJECT_ROOT/logs"
METRICS_FILE="$SCRIPT_DIR/etl_metrics.csv"

# Default options
SHOW_STATUS=false
SHOW_LOGS=false
LOG_COUNT=10
SHOW_PERFORMANCE=false
SHOW_ERRORS=false

# Colors for terminal output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to display usage information
usage() {
    echo "Usage: $0 [options]"
    echo "Options:"
    echo "  -h, --help              Show this help message"
    echo "  -s, --status            Show current ETL job status"
    echo "  -l, --logs [N]          Show last N log entries (default: 10)"
    echo "  -p, --performance       Show performance metrics"
    echo "  -e, --errors            Show recent errors"
    exit 1
}

# Function to check if ETL job is running
check_etl_status() {
    if pgrep -f "run_etl.sh" > /dev/null; then
        echo -e "${GREEN}ETL job is currently running${NC}"
        ps -ef | grep "run_etl.sh" | grep -v grep
    else
        echo -e "${BLUE}No ETL job is currently running${NC}"
        
        # Check when the last job completed
        if [ -d "$LOG_DIR" ]; then
            LAST_LOG=$(ls -t "$LOG_DIR"/etl_*.log 2>/dev/null | head -1)
            if [ -n "$LAST_LOG" ]; then
                LAST_RUN=$(stat -f "%Sm" -t "%Y-%m-%d %H:%M:%S" "$LAST_LOG")
                echo -e "Last ETL job completed at: ${YELLOW}$LAST_RUN${NC}"
                
                # Check if it was successful
                if grep -q "ETL process completed successfully" "$LAST_LOG"; then
                    echo -e "${GREEN}Last run status: SUCCESS${NC}"
                else
                    echo -e "${RED}Last run status: FAILED${NC}"
                    echo "Last error:"
                    grep -A 3 "ERROR" "$LAST_LOG" | tail -4
                fi
            else
                echo "No previous ETL job logs found"
            fi
        else
            echo "Log directory not found"
        fi
    fi
}

# Function to show log entries
show_logs() {
    if [ -d "$LOG_DIR" ]; then
        echo -e "${BLUE}Showing last $LOG_COUNT log entries:${NC}"
        LAST_LOG=$(ls -t "$LOG_DIR"/etl_*.log 2>/dev/null | head -1)
        if [ -n "$LAST_LOG" ]; then
            echo -e "${YELLOW}Log file: $LAST_LOG${NC}"
            tail -n "$LOG_COUNT" "$LAST_LOG"
        else
            echo "No log files found"
        fi
    else
        echo "Log directory not found"
    fi
}

# Function to parse and display performance metrics
show_performance() {
    echo -e "${BLUE}ETL Performance Metrics:${NC}"
    
    if [ -d "$LOG_DIR" ]; then
        # Find the most recent log file
        LAST_LOG=$(ls -t "$LOG_DIR"/etl_*.log 2>/dev/null | head -1)
        if [ -n "$LAST_LOG" ]; then
            echo -e "${YELLOW}Analyzing log file: $LAST_LOG${NC}"
            
            # Extract total duration
            TOTAL_DURATION=$(grep "Total Duration:" "$LAST_LOG" | tail -1 | sed -E 's/.*Total Duration: ([0-9]+)s.*/\1/')
            if [ -n "$TOTAL_DURATION" ]; then
                echo -e "Total ETL Duration: ${GREEN}${TOTAL_DURATION}s${NC}"
            fi
            
            # Extract layer durations
            echo -e "\n${YELLOW}Layer Processing Times:${NC}"
            echo -e "Layer\t\tDuration"
            echo -e "------------------------"
            
            # Bronze layer
            BRONZE_TIME=$(grep -A 10 "Starting Bronze layer processing" "$LAST_LOG" | grep "Completed Bronze layer processing" | sed -E 's/.*\(([0-9]+)s\).*/\1/')
            if [ -n "$BRONZE_TIME" ]; then
                echo -e "Bronze\t\t${BRONZE_TIME}s"
            else
                echo -e "Bronze\t\tN/A"
            fi
            
            # Silver layer
            SILVER_TIME=$(grep -A 10 "Starting Silver layer processing" "$LAST_LOG" | grep "Completed Silver layer processing" | sed -E 's/.*\(([0-9]+)s\).*/\1/')
            if [ -n "$SILVER_TIME" ]; then
                echo -e "Silver\t\t${SILVER_TIME}s"
            else
                echo -e "Silver\t\tN/A"
            fi
            
            # Gold layer
            GOLD_TIME=$(grep -A 10 "Starting Gold layer processing" "$LAST_LOG" | grep "Completed Gold layer processing" | sed -E 's/.*\(([0-9]+)s\).*/\1/')
            if [ -n "$GOLD_TIME" ]; then
                echo -e "Gold\t\t${GOLD_TIME}s"
            else
                echo -e "Gold\t\tN/A"
            fi
            
            # Record metrics for historical tracking
            if [ -n "$TOTAL_DURATION" ]; then
                TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")
                if [ ! -f "$METRICS_FILE" ]; then
                    echo "Timestamp,Total,Bronze,Silver,Gold" > "$METRICS_FILE"
                fi
                echo "$TIMESTAMP,$TOTAL_DURATION,$BRONZE_TIME,$SILVER_TIME,$GOLD_TIME" >> "$METRICS_FILE"
            fi
            
            # Show historical trend if we have enough data
            if [ -f "$METRICS_FILE" ] && [ $(wc -l < "$METRICS_FILE") -gt 2 ]; then
                echo -e "\n${YELLOW}Historical Performance Trend:${NC}"
                echo "Last 5 runs (most recent first):"
                echo -e "Timestamp\t\tTotal\tBronze\tSilver\tGold"
                echo -e "------------------------------------------------------"
                tail -5 "$METRICS_FILE" | sort -r | while IFS=',' read -r ts total bronze silver gold; do
                    echo -e "$ts\t$total\t$bronze\t$silver\t$gold"
                done
            fi
        else
            echo "No log files found"
        fi
    else
        echo "Log directory not found"
    fi
}

# Function to show recent errors
show_errors() {
    echo -e "${BLUE}Recent ETL Errors:${NC}"
    
    if [ -d "$LOG_DIR" ]; then
        # Find all log files from the last 7 days
        find "$LOG_DIR" -name "etl_*.log" -mtime -7 | while read -r log_file; do
            if grep -q "ERROR" "$log_file"; then
                LOG_DATE=$(basename "$log_file" | sed -E 's/etl_([0-9]{8})_.*/\1/')
                LOG_DATE_FORMATTED=$(date -j -f "%Y%m%d" "$LOG_DATE" "+%Y-%m-%d" 2>/dev/null)
                echo -e "\n${YELLOW}Errors from $LOG_DATE_FORMATTED:${NC}"
                grep -n "ERROR" "$log_file" | while read -r line; do
                    LINE_NUM=$(echo "$line" | cut -d':' -f1)
                    ERROR_MSG=$(echo "$line" | cut -d']' -f2-)
                    echo -e "${RED}Line $LINE_NUM:${NC} $ERROR_MSG"
                    # Show context (2 lines after the error)
                    CONTEXT_START=$((LINE_NUM + 1))
                    CONTEXT_END=$((LINE_NUM + 2))
                    sed -n "${CONTEXT_START},${CONTEXT_END}p" "$log_file" | sed 's/^/  /'
                done
            fi
        done
        
        # If no errors found
        if ! find "$LOG_DIR" -name "etl_*.log" -mtime -7 -exec grep -l "ERROR" {} \; | grep -q .; then
            echo -e "${GREEN}No errors found in the last 7 days${NC}"
        fi
    else
        echo "Log directory not found"
    fi
}

# Process command line arguments
while [ "$#" -gt 0 ]; do
    case "$1" in
        -h|--help)
            usage
            ;;
        -s|--status)
            SHOW_STATUS=true
            shift
            ;;
        -l|--logs)
            SHOW_LOGS=true
            if [[ "$2" =~ ^[0-9]+$ ]]; then
                LOG_COUNT="$2"
                shift
            fi
            shift
            ;;
        -p|--performance)
            SHOW_PERFORMANCE=true
            shift
            ;;
        -e|--errors)
            SHOW_ERRORS=true
            shift
            ;;
        *)
            echo "Error: Unknown option: $1"
            usage
            ;;
    esac
done

# Create log directory if it doesn't exist
mkdir -p "$LOG_DIR"

# If no options specified, show status by default
if [ "$SHOW_STATUS" = false ] && [ "$SHOW_LOGS" = false ] && [ "$SHOW_PERFORMANCE" = false ] && [ "$SHOW_ERRORS" = false ]; then
    SHOW_STATUS=true
fi

# Display requested information
if [ "$SHOW_STATUS" = true ]; then
    check_etl_status
    echo ""
fi

if [ "$SHOW_LOGS" = true ]; then
    show_logs
    echo ""
fi

if [ "$SHOW_PERFORMANCE" = true ]; then
    show_performance
    echo ""
fi

if [ "$SHOW_ERRORS" = true ]; then
    show_errors
    echo ""
fi

exit 0
