"""
TASK 2.3 / TASK 6 - Load USD -> PLN Exchange Rates from NBP API
Fetches daily USD/PLN rates from the Polish National Bank (NBP) public API,
forward-fills weekends/holidays, and loads the result into
AWStaging.[Extract].CurrencyRateData via dlt.

NBP API documentation: https://api.nbp.pl/
Limit: max 367 days per request -- the script chunks into yearly batches.

Run:
    python load_currency.py
"""

import dlt
import requests
import pandas as pd
from datetime import date, timedelta


# -- Configurable date range ------------
START_DATE = date(2022, 5, 1)   # earliest SalesOrderHeader.OrderDate
END_DATE   = date(2025, 5, 1)   # latest  SalesOrderHeader.OrderDate


def fetch_usd_to_pln(start: str, end: str) -> pd.DataFrame:
    """Fetch daily USD/PLN mid rates from NBP API for the given date range."""
    url = (
        f"https://api.nbp.pl/api/exchangerates/rates/a/usd/"
        f"{start}/{end}/?format=json"
    )
    resp = requests.get(url, timeout=30)
    resp.raise_for_status()
    rates = resp.json()["rates"]
    df = pd.DataFrame(rates)[["effectiveDate", "mid"]]
    df.columns = ["rate_date", "usd_to_pln"]
    df["rate_date"] = pd.to_datetime(df["rate_date"]).dt.date
    return df


def fill_missing_days(df: pd.DataFrame, start: date, end: date) -> pd.DataFrame:
    """
    Create a continuous daily series from start to end.
    Missing days (weekends, holidays) are forward-filled from the
    last available value -- as required by Task 6.
    """
    all_dates = pd.date_range(start=start, end=end, freq="D")
    df_full = pd.DataFrame({"rate_date": all_dates.date})
    df_merged = df_full.merge(df, on="rate_date", how="left")
    df_merged["usd_to_pln"] = df_merged["usd_to_pln"].ffill()
    return df_merged


def load_currency() -> None:
    """Main entry point: fetch, fill, and load currency rates."""
    chunks = []
    current = START_DATE

    # NBP API max 367 days per call -> split into yearly slices
    while current <= END_DATE:
        chunk_end = min(current + timedelta(days=364), END_DATE)
        try:
            chunk = fetch_usd_to_pln(current.isoformat(), chunk_end.isoformat())
            chunks.append(chunk)
            print(f"  Fetched {len(chunk)} rows: {current} to {chunk_end}")
        except Exception as exc:
            print(f"  Warning fetching {current} to {chunk_end}: {exc}")
        current = chunk_end + timedelta(days=1)

    if not chunks:
        raise RuntimeError("No exchange rate data fetched -- check date range or API.")

    df = pd.concat(chunks).drop_duplicates("rate_date").reset_index(drop=True)
    df = fill_missing_days(df, START_DATE, END_DATE)

    null_count = df["usd_to_pln"].isna().sum()
    print(f"  Total rows after fill: {len(df)}  |  Nulls remaining: {null_count}")

    pipeline = dlt.pipeline(
        pipeline_name="currency_load",
        destination="mssql",
        dataset_name="Extract",
    )

    info = pipeline.run(
        dlt.resource(df.to_dict("records"), name="currency_rate_data"),
        write_disposition="replace",
    )
    print(info)


if __name__ == "__main__":
    load_currency()
