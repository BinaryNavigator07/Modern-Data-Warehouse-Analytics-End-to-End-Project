import psycopg2
import pandas as pd
from dotenv import load_dotenv
import os

# Load environment variables
load_dotenv()

# DB connection parameters
db_params = {
    "dbname": os.getenv("DB_NAME"),
    "user": os.getenv("DB_USER"),
    "password": os.getenv("DB_PASSWORD"),
    "host": os.getenv("DB_HOST", "localhost"),
    "port": int(os.getenv("DB_PORT", 5432))
}

# Connect and load data
try:
    conn = psycopg2.connect(**db_params)
    print("Database connection successful!")

    query = "SELECT * FROM gold.dim_customers;"
    df = pd.read_sql_query(query, conn)

    print("Data loaded successfully!")
    print(df.head())

    conn.close()

except Exception as e:
    print(f"Error: {e}")
