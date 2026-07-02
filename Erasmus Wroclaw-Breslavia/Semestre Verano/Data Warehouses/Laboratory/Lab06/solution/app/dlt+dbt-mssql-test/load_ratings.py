"""
TASK 2.2 - Load Product Ratings from CSV
Reads rating.csv and loads it into AWStaging.[Extract].ProductRating via dlt.

Place the file at: /app/data/rating.csv  (inside the container)

Run:
    docker exec -it data_tools python /app/dlt+dbt-mssql-test/load_ratings.py
"""

import dlt
import pandas as pd
from pathlib import Path


def load_ratings() -> None:
    """Read rating.csv and load records into Extract.ProductRating."""

    # Path adjusted for local execution
    csv_path = Path(__file__).resolve().parent.parent / "data" / "rating.csv"
    df = pd.read_csv(csv_path)

    # Normalise column names to lowercase and standard snake_case
    df.columns = [c.lower().strip().replace(" ", "_") for c in df.columns]

    # Explicitly rename columns to match stg_product.sql expectations:
    # productid -> product_id
    # ratingoverall -> rating
    rename_map = {
        "productid": "product_id",
        "ratingoverall": "rating"
    }
    df = df.rename(columns=rename_map)

    # Check if necessary columns exist after renaming
    if "product_id" not in df.columns or "rating" not in df.columns:
        print(f"Error: Required columns not found. Found: {list(df.columns)}")
        return

    print(f"Loaded {len(df)} rating rows. Target columns: product_id, rating.")

    pipeline = dlt.pipeline(
        pipeline_name="ratings_load",
        destination="mssql",
        dataset_name="Extract",
    )

    info = pipeline.run(
        dlt.resource(df.to_dict("records"), name="product_rating"),
        write_disposition="replace",
    )
    print(info)


if __name__ == "__main__":
    load_ratings()
