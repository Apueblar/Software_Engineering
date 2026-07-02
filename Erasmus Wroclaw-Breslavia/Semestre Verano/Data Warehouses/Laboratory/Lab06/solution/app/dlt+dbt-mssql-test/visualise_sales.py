"""
TASK 7 - Visualisation: USD vs PLN Sales & Exchange Rate Trend
Queries AWStaging.[Staging].fact_sales + dim_order_date, then produces:
  Chart 1 - Total sales (USD and PLN) over time.
  Chart 2 - Sales per day coloured by rate trend (Rising/Falling/Stable),
             overlaid with the USD/PLN rate.

Run (outside container, requires matplotlib & sqlalchemy):
    python visualise_sales.py
"""

import pandas as pd
import sqlalchemy
import matplotlib
matplotlib.use("Agg")          # non-interactive backend
import matplotlib.pyplot as plt
import matplotlib.dates as mdates

# -- Connection --------------------------------------------------------------
# Switched to pyodbc for local execution compatibility (Windows Auth)
ENGINE = sqlalchemy.create_engine(
    "mssql+pyodbc://localhost:1433/StarSchema?driver=ODBC+Driver+18+for+SQL+Server&TrustServerCertificate=yes&trusted_connection=yes"
)

QUERY = """
SELECT
    dd.full_date,
    SUM(f.line_total)       AS total_usd,
    SUM(f.line_total_pln)   AS total_pln,
    AVG(f.usd_to_pln)       AS avg_rate,
    -- A day is 'Rising' if any row says Rising (max over string)
    MAX(f.rate_trend)       AS rate_trend
FROM Staging.fact_sales f
JOIN Staging.dim_order_date dd ON f.date_key = dd.date_key
GROUP BY dd.full_date
ORDER BY dd.full_date
"""


def load_data() -> pd.DataFrame:
    with ENGINE.connect() as conn:
        df = pd.read_sql(QUERY, conn, parse_dates=["full_date"])
    return df


def chart1_usd_vs_pln(df: pd.DataFrame, out: str = "sales_usd_vs_pln.png") -> None:
    """Chart 1 - Total sales in USD and PLN over time."""
    fig, ax = plt.subplots(figsize=(14, 5))

    ax.plot(df["full_date"], df["total_usd"],
            label="Total Sales (USD)", color="#1f77b4", linewidth=1.5)
    ax.plot(df["full_date"], df["total_pln"],
            label="Total Sales (PLN)", color="#ff7f0e", linewidth=1.5)

    ax.set_title("Total Sales Over Time: USD vs PLN", fontsize=14, fontweight="bold")
    ax.set_xlabel("Order Date")
    ax.set_ylabel("Amount")
    ax.xaxis.set_major_formatter(mdates.DateFormatter("%Y-%m"))
    ax.xaxis.set_major_locator(mdates.MonthLocator(interval=3))
    plt.xticks(rotation=45)
    ax.legend()
    ax.grid(axis="y", alpha=0.3)
    plt.tight_layout()
    plt.savefig(out, dpi=150)
    plt.close()
    print(f"Saved: {out}")


def chart2_sales_vs_rate_trend(
    df: pd.DataFrame, out: str = "sales_vs_rate_trend.png"
) -> None:
    """Chart 2 - Daily USD sales coloured by rate trend, with rate on 2nd axis."""
    rising  = df[df["rate_trend"] == "Rising"]
    falling = df[df["rate_trend"] == "Falling"]
    stable  = df[df["rate_trend"] == "Stable"]

    fig, ax1 = plt.subplots(figsize=(14, 5))

    # Bars for each trend category
    ax1.bar(rising["full_date"],  rising["total_usd"],
            color="green", alpha=0.6, label="Rising rate day", width=1)
    ax1.bar(falling["full_date"], falling["total_usd"],
            color="red",   alpha=0.6, label="Falling rate day", width=1)
    ax1.bar(stable["full_date"],  stable["total_usd"],
            color="grey",  alpha=0.4, label="Stable rate day",  width=1)

    # Overlay: USD/PLN rate on secondary axis
    ax2 = ax1.twinx()
    ax2.plot(df["full_date"], df["avg_rate"],
             color="black", linewidth=1.2, linestyle="--", label="USD/PLN rate")

    ax1.set_title("Daily Sales (USD) vs Exchange Rate Trend",
                  fontsize=14, fontweight="bold")
    ax1.set_xlabel("Order Date")
    ax1.set_ylabel("Total Sales (USD)")
    ax2.set_ylabel("USD/PLN Rate")

    ax1.xaxis.set_major_formatter(mdates.DateFormatter("%Y-%m"))
    ax1.xaxis.set_major_locator(mdates.MonthLocator(interval=3))
    plt.xticks(rotation=45)

    # Merge legends from both axes
    lines1, labels1 = ax1.get_legend_handles_labels()
    lines2, labels2 = ax2.get_legend_handles_labels()
    ax1.legend(lines1 + lines2, labels1 + labels2, loc="upper left")
    ax1.grid(axis="y", alpha=0.3)

    plt.tight_layout()
    plt.savefig(out, dpi=150)
    plt.close()
    print(f"Saved: {out}")


if __name__ == "__main__":
    print("Loading data from StarSchema...")
    df = load_data()
    if df.empty:
        print("Error: No data found in Staging.fact_sales.")
    else:
        print(f"  Rows: {len(df)}  |  Date range: {df['full_date'].min()} to {df['full_date'].max()}")
        chart1_usd_vs_pln(df)
        chart2_sales_vs_rate_trend(df)
        print("Done.")
