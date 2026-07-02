"""
DuckDB - ROLAP Extension (Optional)
Exports all star schema tables from AWStaging.[Staging] into a persistent
DuckDB file at /root/.duckdb/star_schema.duckdb.

Then demonstrates a sample analytical query.

Run:
    docker exec -it data_tools python /app/dlt+dbt-mssql-test/load_duckdb.py
"""

import duckdb
import pandas as pd
import sqlalchemy

# ── Source: StarSchema SQL Server ─────────────────────────────────────────────
MSSQL_ENGINE = sqlalchemy.create_engine(
    "mssql+pyodbc://localhost:1433/StarSchema?driver=ODBC+Driver+18+for+SQL+Server&TrustServerCertificate=yes&trusted_connection=yes"
)

DUCKDB_PATH = "star_schema.duckdb"

TABLES = [
    "dim_product",
    "dim_salesperson",
    "dim_sales_territory",
    "dim_order_date",
    "fact_sales",
]


def export_to_duckdb() -> None:
    """Copy every star schema table from MSSQL Staging into DuckDB."""
    con = duckdb.connect(DUCKDB_PATH)
    with MSSQL_ENGINE.connect() as mssql:
        for table in TABLES:
            df = pd.read_sql(f"SELECT * FROM Staging.{table}", mssql)
            con.execute(f"DROP TABLE IF EXISTS {table}")
            con.register("_tmp", df)
            con.execute(f"CREATE TABLE {table} AS SELECT * FROM _tmp")
            print(f"  Loaded {table}: {len(df):,} rows")
    con.close()
    print(f"\nDuckDB file: {DUCKDB_PATH}")


def sample_query() -> None:
    """Run a sample analytical query on DuckDB."""
    con = duckdb.connect(DUCKDB_PATH, read_only=True)
    result = con.execute("""
        SELECT
            p.category_name,
            t.territory_continent,
            d.year,
            SUM(f.line_total)     AS total_usd,
            SUM(f.line_total_pln) AS total_pln,
            COUNT(*)              AS order_lines
        FROM fact_sales f
        JOIN dim_product       p  ON f.product_key    = p.product_key
        JOIN dim_sales_territory t ON f.territory_key = t.territory_key
        JOIN dim_order_date    d  ON f.date_key        = d.date_key
        GROUP BY p.category_name, t.territory_continent, d.year
        ORDER BY total_usd DESC
    """).df()
    print("\nSample query result:")
    print(result.to_string(index=False))
    con.close()


if __name__ == "__main__":
    print("Exporting star schema to DuckDB …")
    export_to_duckdb()
    sample_query()
