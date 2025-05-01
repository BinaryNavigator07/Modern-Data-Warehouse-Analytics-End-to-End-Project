# Data Warehouse Automation and Orchestration

This directory contains scripts for automating, scheduling, and monitoring the ETL processes for the data warehouse project.

## Overview

The automation system provides the following capabilities:

1. **ETL Orchestration**: Run the entire ETL process or specific layers with error handling and logging
2. **Scheduling**: Schedule ETL jobs to run at specific times using cron
3. **Monitoring**: Track ETL job status, performance metrics, and errors

## Scripts

### 1. ETL Orchestration (`run_etl.sh`)

This script orchestrates the entire ETL process, handling the loading of data into bronze, silver, and gold layers.

#### Features:
- Configurable database connection parameters
- Error handling and logging
- Email notifications on completion/failure
- Performance tracking
- Option to run full or incremental loads
- Option to run specific layers only

#### Usage:
```bash
./run_etl.sh [options]
```

#### Options:
- `-h, --help`: Show help message
- `-f, --full`: Run full load (default is incremental if supported)
- `-l, --layer [LAYER]`: Run specific layer only (bronze, silver, gold)
- `-n, --no-email`: Disable email notifications
- `-v, --verbose`: Enable verbose output

### 2. Job Scheduling (`schedule_etl.sh`)

This script sets up scheduled execution of the ETL process using crontab.

#### Features:
- Multiple scheduling options (daily, weekly, monthly)
- Custom cron expression support
- Validation of cron expressions
- Backup of existing crontab

#### Usage:
```bash
./schedule_etl.sh [options]
```

#### Options:
- `-h, --help`: Show help message
- `-d, --daily [HH:MM]`: Schedule daily at specified time (default: 01:00)
- `-w, --weekly [DOW,HH:MM]`: Schedule weekly on day of week at time (default: Sun,01:00)
- `-m, --monthly [DOM,HH:MM]`: Schedule monthly on day of month at time (default: 1,01:00)
- `-c, --cron "EXPRESSION"`: Use custom cron expression
- `-r, --remove`: Remove existing scheduled jobs

### 3. ETL Monitoring (`etl_monitor.sh`)

This script provides monitoring capabilities for the ETL process, including job status, execution history, and performance metrics.

#### Features:
- Real-time status monitoring
- Historical execution tracking
- Performance metrics visualization
- Error reporting and alerting

#### Usage:
```bash
./etl_monitor.sh [options]
```

#### Options:
- `-h, --help`: Show help message
- `-s, --status`: Show current ETL job status
- `-l, --logs [N]`: Show last N log entries (default: 10)
- `-p, --performance`: Show performance metrics
- `-e, --errors`: Show recent errors

## Setup Instructions

1. Make the scripts executable:
   ```bash
   chmod +x run_etl.sh schedule_etl.sh etl_monitor.sh
   ```

2. Configure database connection parameters in `run_etl.sh`:
   ```bash
   # Edit these values to match your environment
   DB_NAME="datawarehouse"
   DB_USER="postgres"
   DB_HOST="localhost"
   DB_PORT="5432"
   ```

3. Set up email notifications (optional):
   ```bash
   # Edit these values to enable email notifications
   EMAIL_RECIPIENT="your.email@example.com"
   ```

## Example Workflows

### Daily ETL Process

1. Schedule a daily ETL job to run at 2:30 AM:
   ```bash
   ./schedule_etl.sh --daily 02:30
   ```

2. Check the status of the ETL job:
   ```bash
   ./etl_monitor.sh --status
   ```

3. View performance metrics after completion:
   ```bash
   ./etl_monitor.sh --performance
   ```

### Manual ETL Run

1. Run a full ETL process for all layers:
   ```bash
   ./run_etl.sh --full
   ```

2. Run ETL for a specific layer:
   ```bash
   ./run_etl.sh --layer silver
   ```

## Directory Structure

```
automation/
├── run_etl.sh              # ETL orchestration script
├── schedule_etl.sh         # ETL scheduling script
├── etl_monitor.sh          # ETL monitoring dashboard
├── etl_metrics.csv         # Historical performance metrics
└── logs/                   # ETL execution logs
```

## Troubleshooting

### Common Issues

1. **Permission Denied**:
   - Make sure the scripts are executable (`chmod +x *.sh`)
   - Ensure the user has appropriate database permissions

2. **Cron Job Not Running**:
   - Check crontab with `crontab -l`
   - Verify system cron service is running
   - Check for errors in the cron log

3. **Database Connection Failures**:
   - Verify database credentials in `run_etl.sh`
   - Ensure PostgreSQL is running
   - Check network connectivity to the database server

### Viewing Logs

ETL logs are stored in the `logs` directory. To view the most recent log:

```bash
./etl_monitor.sh --logs 20
```

## Best Practices

1. **Regular Monitoring**: Check ETL job status and performance regularly
2. **Error Alerts**: Set up email notifications for ETL failures
3. **Performance Tracking**: Monitor execution times to identify trends
4. **Incremental Loading**: Use incremental loading for large datasets when possible
5. **Backup Scheduling**: Schedule regular backups of the data warehouse

## Future Enhancements

1. **Web Dashboard**: Create a web-based monitoring dashboard
2. **Dependency Management**: Add support for managing dependencies between jobs
3. **Parallel Processing**: Implement parallel loading for improved performance
4. **Retry Mechanism**: Add automatic retry for failed jobs
5. **API Integration**: Provide REST API for triggering and monitoring jobs
