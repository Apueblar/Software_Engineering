"""
TASK 2.1 - Data Extraction with dlt
Extracts raw tables from AdventureWorks (Sales, Production, Person schemas)
and loads them into StarSchema.[extract] schema.

Run:
    python load_extract.py
"""

import dlt
from dlt.sources.sql_database import sql_database


def load_adventureworks_tables() -> None:
    """Extract raw tables from AdventureWorks into StarSchema.[extract] schema."""

    # -- Sales schema ---------------------------------------------------------
    source_sales = sql_database(schema="Sales").with_resources(
        "SalesOrderHeader",
        "SalesOrderDetail",
        "SalesPerson",
        "SalesTerritory",
        "Customer",
    )

    # -- Production schema ----------------------------------------------------
    source_production = sql_database(schema="Production").with_resources(
        "Product",
        "ProductSubcategory",
        "ProductCategory",
    )

    # -- Person schema ---------------------------------------------------------
    source_person = sql_database(schema="Person").with_resources(
        "Person",
        "CountryRegion",
    )

    pipeline = dlt.pipeline(
        pipeline_name="aw_extract",
        destination="mssql",
        dataset_name="Extract",  # -> StarSchema.[extract] schema
    )

    for source in [source_sales, source_production, source_person]:
        info = pipeline.run(source, write_disposition="replace")
        print(info)


if __name__ == "__main__":
    load_adventureworks_tables()
