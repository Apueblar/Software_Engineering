import dlt
from dlt.sources.sql_database import sql_database

def run_staging_load():
    # 1. Sources used for extraction
    source = sql_database(schema="Sales").with_resources("SalesOrderHeader", "SalesTerritory", "SalesPerson")
    source2 = sql_database(schema="Person").with_resources("Person", "CountryRegion")

    # 2. Extraction
    pipeline = dlt.pipeline(
        pipeline_name="sql_to_staging",
        destination="mssql",
        dataset_name="raw" # Staging database schema
    )

    # 3. Using 'append' to do an incremental loads
    info = pipeline.run(source, write_disposition="append")
    print(info)
    info2 = pipeline.run(source2, write_disposition="append")
    print(info2)

def run_transformation_step():

    # 1. Creating a pipeline to handle dbt
    pipeline = dlt.pipeline(
        pipeline_name='dbt_test',
        destination='mssql',
        dataset_name='stg'
    )

    # 2. Connecting to the dbt project 
    dbt = dlt.dbt.package(
        pipeline,
        "dbt-mssql"
    )

    # 3. Running the model
    models = dbt.run_all()

    # 4. Get result info
    for m in models:
        print(
            f"Model {m.model_name} materialized" +
            f" in {m.time}" +
            f" with status {m.status}" +
            f" and message {m.message}"
        )


if __name__ == "__main__":
    run_staging_load()
    run_transformation_step()