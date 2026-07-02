import dlt
from dlt.sources.sql_database import sql_database

def load_data():
    # 1. The source connection (extracting from AdventureWorks)
    # This still needs a connection string to know WHERE to extract from    
    source = sql_database("mssql+pymssql://sa:YourStrong!Pass123@sqlserver:1433/AdventureWorks", schema="Sales").with_resources("SalesOrderHeader","Customer")

    # 2. The pipeline definition
    # Because we set secrets.toml in .dlt, 
    # dlt automatically knows how to connect to 'mssql'
    pipeline = dlt.pipeline(
        pipeline_name="adventure_works_load",
        destination="local_mssql", 
        dataset_name="raw" # This creates/uses the raw schema
    )

    # 3. Execution
    load_info = pipeline.run(source)
    print(load_info)

if __name__ == "__main__":
    load_data()