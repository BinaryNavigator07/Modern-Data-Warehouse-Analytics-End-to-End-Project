# Configuration System for SQL Data Warehouse Project

## Overview

This configuration system has been implemented to eliminate hardcoded paths in the project scripts. The system uses PostgreSQL's variable system to dynamically set file paths and other configuration values, making the project more portable and maintainable.

## Files Added

1. **config.sql**: Central configuration file that defines all path variables
2. **scripts/setup_config.sql**: Helper script to convert psql variables to PostgreSQL GUC variables

## How It Works

The configuration system works in three steps:

1. **Define Variables**: All paths and configuration values are defined in `config.sql` using psql's `\set` command
2. **Setup Configuration**: The `setup_config.sql` script converts psql variables to PostgreSQL GUC variables using `set_config()`
3. **Use Variables**: The procedures access these variables using `current_setting()`

### Technical Details

PostgreSQL has two separate variable systems:

- **psql variables**: Client-side variables set with `\set` and accessed with `:variable_name`
- **GUC variables**: Server-side variables that can be accessed from stored procedures using `current_setting('variable_name')`

Our configuration system bridges these two systems to provide a unified approach to configuration.

## Usage Instructions

### 1. Update the Configuration

First, edit the `config.sql` file to set the correct project directory for your environment:

```sql
-- Define the base project directory (adjust this to your environment)
\set project_dir ''/Users/macbookpro/Documents/SQL-Data-Warehouse-Project''
```

### 2. Running Scripts

When running scripts, include the configuration files in this order:

```bash
# For initialization
psql -f config.sql -f scripts/init_database.sql

# For loading data
psql -d datawarehouse -f config.sql -f scripts/setup_config.sql -c "CALL bronze.load_bronze();"
```

### 3. Using in psql Interactive Mode

```sql
\i config.sql
\i scripts/setup_config.sql
CALL bronze.load_bronze();
```

### 4. Using in Shell Scripts

For automation with shell scripts:

```bash
#!/bin/bash

# Set PostgreSQL connection parameters
PGUSER="postgres"
PGDB="datawarehouse"

# Initialize database
psql -U $PGUSER -f config.sql -f scripts/init_database.sql

# Load bronze layer
psql -U $PGUSER -d $PGDB -f config.sql -f scripts/setup_config.sql -c "CALL bronze.load_bronze();"

# Load silver layer
psql -U $PGUSER -d $PGDB -c "CALL silver.load_silver();"

echo "Data warehouse loading complete!"
```

## Modified Files

The following files have been modified to use the configuration system:

1. **scripts/init_database.sql**: Now loads the configuration file
2. **scripts/bronze/proc_load_bronze.sql**: Uses dynamic paths from configuration

## Troubleshooting

### Common Issues

1. **Variable not found errors**:
   - Ensure `config.sql` is loaded before any script that uses the variables
   - Check for typos in variable names

2. **Permission issues**:
   - Ensure the PostgreSQL user has permission to modify GUC parameters
   - Some environments restrict `set_config()` usage

3. **Path not found errors**:
   - Verify the paths in `config.sql` are correct for your environment
   - Check file permissions on the data files

## Best Practices

1. **Keep paths relative** to the project directory when possible
2. **Use consistent naming conventions** for variables
3. **Document any changes** to the configuration system
4. **Version control** your configuration files
5. **Consider environment-specific configs** for different environments (dev, test, prod)

## Benefits

- **Portability**: The project can be easily moved to different environments
- **Maintainability**: Path changes only need to be made in one place
- **Consistency**: All scripts use the same path definitions
- **Flexibility**: Configuration can be extended to include more variables as needed
- **Readability**: Scripts are cleaner without hardcoded paths

## Future Enhancements

Potential improvements to the configuration system:

1. **Environment-specific configs**: Add support for different environments
2. **Configuration validation**: Add checks to ensure paths exist
3. **Default values**: Provide fallbacks for missing configuration
4. **Configuration UI**: Create a simple interface for updating configuration
