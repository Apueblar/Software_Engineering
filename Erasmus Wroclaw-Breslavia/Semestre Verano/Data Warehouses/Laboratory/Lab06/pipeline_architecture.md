# Architecture of the ELT Data Pipeline (Lab 6)

This document outlines the end-to-end flow of how data is extracted, transformed, and served within your application.

## High-Level Architecture Diagram

```mermaid
flowchart TD
    %% Define Styles
    classDef source fill:#f9d0c4,stroke:#333,stroke-width:2px;
    classDef dlt fill:#d4e157,stroke:#333,stroke-width:2px;
    classDef extract fill:#b3e5fc,stroke:#333,stroke-width:2px;
    classDef dbt fill:#ffcc80,stroke:#333,stroke-width:2px;
    classDef staging fill:#c8e6c9,stroke:#333,stroke-width:2px;
    classDef serve fill:#e1bee7,stroke:#333,stroke-width:2px;

    %% 1. Data Sources
    subgraph Sources ["1. Data Sources"]
        DB[(AdventureWorks DB)]:::source
        API(NBP Currency API):::source
        CSV(rating.csv):::source
    end

    %% 2. Extraction & Loading (dlt)
    subgraph DLT ["2. Extract & Load (Python / dlt)"]
        py_extract(load_extract.py):::dlt
        py_curr(load_currency.py):::dlt
        py_rat(load_ratings.py):::dlt
    end

    %% Mapping Sources to DLT
    DB --> py_extract
    API --> py_curr
    CSV --> py_rat

    %% 3. Raw Database Schema
    subgraph DB_Extract ["3. Raw Database (StarSchema.Extract)"]
        raw_aw[(Raw Tables)]:::extract
    end

    %% Mapping DLT to Extract Schema
    py_extract --> raw_aw
    py_curr --> raw_aw
    py_rat --> raw_aw

    %% 4. Transformations (dbt)
    subgraph DBT ["4. Transformation (dbt-core)"]
        stg(Staging Views\nCleaning & Formatting):::dbt
        marts(Mart Tables\nStar Schema Dimensions & Facts):::dbt
        stg --> marts
    end

    %% Mapping Extract to DBT
    raw_aw -->|Read| stg

    %% 5. Staging Database Schema
    subgraph DB_Staging ["5. Target Database (StarSchema.Staging)"]
        star[(Star Schema Tables\ndim_* and fact_sales)]:::staging
    end

    %% Mapping DBT to Staging Schema
    marts -->|Write| star

    %% 6. Serving Layer
    subgraph Serving ["6. Serving & Analytics"]
        DuckDB[(DuckDB ROLAP File)]:::serve
        PyViz([Matplotlib Visualizations]):::serve
        PowerBI([Power BI / BI Tools]):::serve
    end

    %% Mapping Staging to Serving
    star -->|load_duckdb.py| DuckDB
    star -->|visualise_sales.py| PyViz
    DuckDB -.->|ODBC| PowerBI
```

---

## 1. Import (Extract & Load)
The pipeline starts with the extraction layer managed by **`dlt` (data load tool)**. Instead of doing heavy processing in Python, we extract data "as-is" and load it into a dedicated raw schema.
* **`load_extract.py`**: Connects directly to the `AdventureWorks` database and pulls operational tables (like `Product`, `SalesOrderHeader`, `Person`, etc.).
* **`load_currency.py`**: Makes an HTTP request to the Polish National Bank (NBP) API to fetch historical USD-to-PLN exchange rates, and forward-fills weekends.
* **`load_ratings.py`**: Reads `rating.csv` from the local disk.

**Destination:** All of this raw data is dumped into the `Extract` schema inside your `StarSchema` SQL Server database.

## 2. Transformation
Once the raw data is physically inside the SQL Server, **`dbt` (data build tool)** takes over. Because it's an ELT (Extract-Load-Transform) pipeline, dbt never moves data out of the database; it just compiles SQL `SELECT` statements and sends them to the SQL Server to execute.
* **Staging Models (`models/staging/stg_*.sql`)**: Built as lightweight SQL Views. This step handles renaming columns, standardising units (grams to kilograms), handling NULLs, and joining simple parent-child tables.
* **Mart Models (`models/marts/*.sql`)**: Built as physical SQL Tables. This forms your final Star Schema. It generates surrogate keys (like `sales_fact_key`), the contiguous calendar spine (`dim_order_date`), and calculates final business logic like currency conversion (`line_total_pln`) and trend flags (`Rising`/`Falling`).

**Destination:** The finalized, clean star schema tables are materialized into the `Staging` schema of your `StarSchema` database.

## 3. Serve (Analytics & Visualisation)
With the Star Schema fully processed, the data is ready for fast analytical querying and visualization.
* **DuckDB (`load_duckdb.py`)**: For ultra-fast analytical (ROLAP) workloads, the tables in the `Staging` schema are exported into an embedded columnar DuckDB file (`star_schema.duckdb`). This file can be queried locally or connected directly to Power BI.
* **Python Visuals (`visualise_sales.py`)**: Uses `pandas` to query the `Staging` schema and `matplotlib` to render local PNG images (`sales_usd_vs_pln.png`, `sales_vs_rate_trend.png`) displaying the exchange rate trends.
