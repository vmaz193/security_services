import os
import logging
import pandas as pd
from sqlalchemy import create_engine
from sqlalchemy.exc import SQLAlchemyError
from dotenv import load_dotenv
from tqdm import tqdm

def load_env():
    """Load and validate environment variables from .env file."""
    env_path = os.path.join(os.path.dirname(__file__), '..', '.env')
    load_dotenv(dotenv_path=env_path)

    required_vars = ['POSTGRES_USER', 'POSTGRES_PASSWORD', 'POSTGRES_DB']
    for var in required_vars:
        if not os.getenv(var):
            raise EnvironmentError(f"Environment variable '{var}' is required but not set.")

    return {
        'user': os.getenv('POSTGRES_USER'),
        'password': os.getenv('POSTGRES_PASSWORD'),
        'host': os.getenv('POSTGRES_HOST', 'localhost'),
        'port': os.getenv('POSTGRES_PORT', '5432'),
        'db': os.getenv('POSTGRES_DB')
    }

def create_db_engine(db_config):
    """Create SQLAlchemy engine from config."""
    conn_str = (
        f"postgresql://{db_config['user']}:{db_config['password']}"
        f"@{db_config['host']}:{db_config['port']}/{db_config['db']}"
    )
    return create_engine(conn_str)

def ingest_csv_to_postgres(data_folder, engine):
    """Load all CSV files from data_folder into Postgres using pandas."""
    csv_files = [f for f in os.listdir(data_folder) if f.endswith('.csv')]

    if not csv_files:
        logging.warning("No CSV files found in the data folder.")
        return

    for filename in tqdm(csv_files, desc="Ingesting CSV files"):
        table_name = os.path.splitext(filename)[0].lower()
        file_path = os.path.join(data_folder, filename)

        logging.info(f"Ingesting '{filename}' into table '{table_name}'")

        try:
            df = pd.read_csv(file_path)
            df.columns = [col.lower() for col in df.columns]  # lowercase all columns
            df.to_sql(table_name, engine, if_exists='replace', index=False)
            logging.info(f"Successfully ingested '{filename}' into '{table_name}'.")
        except (pd.errors.EmptyDataError, pd.errors.ParserError) as e:
            logging.error(f"Skipping '{filename}': Invalid or empty CSV. Error: {e}")
        except SQLAlchemyError as e:
            logging.error(f"Failed to load '{filename}' into Postgres: {e}")
        except Exception as e:
            logging.exception(f"Unexpected error while processing '{filename}': {e}")

def main():
    # Set up logging
    logging.basicConfig(
        level=logging.INFO,
        format="%(asctime)s [%(levelname)s] %(message)s",
        handlers=[logging.StreamHandler()]
    )

    try:
        db_config = load_env()
        engine = create_db_engine(db_config)

        data_folder = os.path.join(os.path.dirname(__file__), '..', 'data')
        ingest_csv_to_postgres(data_folder, engine)

        logging.info("✅ All CSV files processed.")
    except Exception as e:
        logging.exception(f"🚨 Fatal error occurred: {e}")

if __name__ == '__main__':
    main()
