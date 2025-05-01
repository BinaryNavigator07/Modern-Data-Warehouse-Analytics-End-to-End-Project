#!/bin/bash
#===================================================================================
# ETL Scheduling Script for Data Warehouse
#===================================================================================
#
# Script Purpose:
#   This script sets up scheduled execution of the ETL process using crontab.
#   It allows for easy configuration of the schedule and provides options
#   for different scheduling patterns.
#
# Features:
#   - Multiple scheduling options (daily, weekly, monthly)
#   - Custom cron expression support
#   - Validation of cron expressions
#   - Backup of existing crontab
#
# Usage:
#   ./schedule_etl.sh [options]
#
# Options:
#   -h, --help              Show this help message
#   -d, --daily [HH:MM]     Schedule daily at specified time (default: 01:00)
#   -w, --weekly [DOW,HH:MM] Schedule weekly on day of week at time (default: Sun,01:00)
#   -m, --monthly [DOM,HH:MM] Schedule monthly on day of month at time (default: 1,01:00)
#   -c, --cron "EXPRESSION" Use custom cron expression
#   -r, --remove            Remove existing scheduled jobs
#
#===================================================================================

# Script location
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ETL_SCRIPT="$SCRIPT_DIR/run_etl.sh"
CRONTAB_BACKUP="$SCRIPT_DIR/crontab_backup_$(date +%Y%m%d_%H%M%S)"

# Default options
SCHEDULE_TYPE=""
SCHEDULE_TIME="01:00"
SCHEDULE_DAY="Sun"
SCHEDULE_DOM="1"
CUSTOM_CRON=""
REMOVE_JOBS=false

# Function to display usage information
usage() {
    echo "Usage: $0 [options]"
    echo "Options:"
    echo "  -h, --help                  Show this help message"
    echo "  -d, --daily [HH:MM]         Schedule daily at specified time (default: 01:00)"
    echo "  -w, --weekly [DOW,HH:MM]    Schedule weekly on day of week at time (default: Sun,01:00)"
    echo "  -m, --monthly [DOM,HH:MM]   Schedule monthly on day of month at time (default: 1,01:00)"
    echo "  -c, --cron \"EXPRESSION\"     Use custom cron expression"
    echo "  -r, --remove                Remove existing scheduled jobs"
    exit 1
}

# Function to validate time format (HH:MM)
validate_time() {
    local time="$1"
    if ! [[ "$time" =~ ^([0-1][0-9]|2[0-3]):[0-5][0-9]$ ]]; then
        echo "Error: Invalid time format. Please use HH:MM (24-hour format)."
        exit 1
    fi
}

# Function to validate day of week
validate_dow() {
    local dow="$1"
    if ! [[ "$dow" =~ ^(Sun|Mon|Tue|Wed|Thu|Fri|Sat|0|1|2|3|4|5|6)$ ]]; then
        echo "Error: Invalid day of week. Use Sun, Mon, Tue, Wed, Thu, Fri, Sat or 0-6."
        exit 1
    fi
}

# Function to validate day of month
validate_dom() {
    local dom="$1"
    if ! [[ "$dom" =~ ^([1-9]|[12][0-9]|3[01])$ ]]; then
        echo "Error: Invalid day of month. Please use 1-31."
        exit 1
    fi
}

# Function to convert day of week to number
dow_to_number() {
    case "$1" in
        Sun) echo "0" ;;
        Mon) echo "1" ;;
        Tue) echo "2" ;;
        Wed) echo "3" ;;
        Thu) echo "4" ;;
        Fri) echo "5" ;;
        Sat) echo "6" ;;
        *) echo "$1" ;;
    esac
}

# Process command line arguments
while [ "$#" -gt 0 ]; do
    case "$1" in
        -h|--help)
            usage
            ;;
        -d|--daily)
            SCHEDULE_TYPE="daily"
            if [[ "$2" =~ ^[0-9]{1,2}:[0-9]{2}$ ]]; then
                SCHEDULE_TIME="$2"
                shift
            fi
            shift
            ;;
        -w|--weekly)
            SCHEDULE_TYPE="weekly"
            if [[ "$2" =~ ^[a-zA-Z0-9]+,[0-9]{1,2}:[0-9]{2}$ ]]; then
                IFS=',' read -r SCHEDULE_DAY SCHEDULE_TIME <<< "$2"
                shift
            fi
            shift
            ;;
        -m|--monthly)
            SCHEDULE_TYPE="monthly"
            if [[ "$2" =~ ^[0-9]{1,2},[0-9]{1,2}:[0-9]{2}$ ]]; then
                IFS=',' read -r SCHEDULE_DOM SCHEDULE_TIME <<< "$2"
                shift
            fi
            shift
            ;;
        -c|--cron)
            SCHEDULE_TYPE="custom"
            CUSTOM_CRON="$2"
            shift 2
            ;;
        -r|--remove)
            REMOVE_JOBS=true
            shift
            ;;
        *)
            echo "Error: Unknown option: $1"
            usage
            ;;
    esac
done

# Check if ETL script exists
if [ ! -f "$ETL_SCRIPT" ]; then
    echo "Error: ETL script not found at $ETL_SCRIPT"
    exit 1
fi

# Make ETL script executable
chmod +x "$ETL_SCRIPT"

# Backup existing crontab
crontab -l > "$CRONTAB_BACKUP" 2>/dev/null || echo "# New crontab" > "$CRONTAB_BACKUP"

# Remove existing ETL jobs if requested
if [ "$REMOVE_JOBS" = true ]; then
    sed -i.bak '/run_etl\.sh/d' "$CRONTAB_BACKUP"
    echo "Removed existing ETL jobs from crontab."
    crontab "$CRONTAB_BACKUP"
    exit 0
fi

# Validate inputs based on schedule type
if [ "$SCHEDULE_TYPE" = "daily" ]; then
    validate_time "$SCHEDULE_TIME"
    HOUR=$(echo "$SCHEDULE_TIME" | cut -d':' -f1)
    MINUTE=$(echo "$SCHEDULE_TIME" | cut -d':' -f2)
    CRON_EXPRESSION="$MINUTE $HOUR * * * $ETL_SCRIPT > $SCRIPT_DIR/logs/etl_\$(date +\%Y\%m\%d_\%H\%M\%S).log 2>&1"
    echo "Setting up daily schedule at $SCHEDULE_TIME"

elif [ "$SCHEDULE_TYPE" = "weekly" ]; then
    validate_dow "$SCHEDULE_DAY"
    validate_time "$SCHEDULE_TIME"
    DOW=$(dow_to_number "$SCHEDULE_DAY")
    HOUR=$(echo "$SCHEDULE_TIME" | cut -d':' -f1)
    MINUTE=$(echo "$SCHEDULE_TIME" | cut -d':' -f2)
    CRON_EXPRESSION="$MINUTE $HOUR * * $DOW $ETL_SCRIPT > $SCRIPT_DIR/logs/etl_\$(date +\%Y\%m\%d_\%H\%M\%S).log 2>&1"
    echo "Setting up weekly schedule on $SCHEDULE_DAY at $SCHEDULE_TIME"

elif [ "$SCHEDULE_TYPE" = "monthly" ]; then
    validate_dom "$SCHEDULE_DOM"
    validate_time "$SCHEDULE_TIME"
    HOUR=$(echo "$SCHEDULE_TIME" | cut -d':' -f1)
    MINUTE=$(echo "$SCHEDULE_TIME" | cut -d':' -f2)
    CRON_EXPRESSION="$MINUTE $HOUR $SCHEDULE_DOM * * $ETL_SCRIPT > $SCRIPT_DIR/logs/etl_\$(date +\%Y\%m\%d_\%H\%M\%S).log 2>&1"
    echo "Setting up monthly schedule on day $SCHEDULE_DOM at $SCHEDULE_TIME"

elif [ "$SCHEDULE_TYPE" = "custom" ]; then
    if [ -z "$CUSTOM_CRON" ]; then
        echo "Error: Custom cron expression is required with --cron option."
        exit 1
    fi
    CRON_EXPRESSION="$CUSTOM_CRON $ETL_SCRIPT > $SCRIPT_DIR/logs/etl_\$(date +\%Y\%m\%d_\%H\%M\%S).log 2>&1"
    echo "Setting up custom schedule with cron expression: $CUSTOM_CRON"

else
    echo "Error: No schedule type specified. Use --daily, --weekly, --monthly, or --cron."
    usage
fi

# Add new cron job
echo "$CRON_EXPRESSION" >> "$CRONTAB_BACKUP"

# Install new crontab
if crontab "$CRONTAB_BACKUP"; then
    echo "Successfully scheduled ETL job."
    echo "Cron expression: $CRON_EXPRESSION"
else
    echo "Error: Failed to install crontab."
    exit 1
fi

exit 0
