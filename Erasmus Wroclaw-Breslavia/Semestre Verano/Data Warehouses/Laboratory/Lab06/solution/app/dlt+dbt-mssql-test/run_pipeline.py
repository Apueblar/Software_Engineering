"""
Main ETL/ELT Orchestration Script (LOCAL WINDOWS VERSION)
Runs the full pipeline in order:
  1. dlt  → Extract AdventureWorks tables into AWStaging.[Extract]
  2. dlt  → Load product ratings from rating.csv
  3. dlt  → Load USD/PLN exchange rates from NBP API
  4. dbt  → Transform [Extract] → [Staging] (dimensions + fact table)

Run:
    python run_pipeline.py
"""

import subprocess
import sys
import os
from pathlib import Path

# Get the directory where this script is located
BASE = Path(__file__).resolve().parent
DBT_PROJECT = BASE / "dbt-mssql"

# Ensure we are in the correct working directory for dlt to find .dlt config
os.chdir(BASE)

STEPS = [
    # ── Step 1: Extract raw AW tables via dlt ────────────────────────────────
    {
        "label": "Step 1 - Extract AdventureWorks tables",
        "cmd": [sys.executable, str(BASE / "load_extract.py")],
    },
    # ── Step 2: Load rating.csv via dlt ──────────────────────────────────────
    {
        "label": "Step 2 - Load product ratings from CSV",
        "cmd": [sys.executable, str(BASE / "load_ratings.py")],
    },
    # ── Step 3: Load NBP currency rates via dlt ──────────────────────────────
    {
        "label": "Step 3 - Load USD/PLN exchange rates from NBP API",
        "cmd": [sys.executable, str(BASE / "load_currency.py")],
    },
    # ── Step 4: Transform with dbt ───────────────────────────────────────────
    {
        "label": "Step 4 - Run dbt transformations (all models)",
        "cmd": [
            "dbt", "run",
            "--project-dir", str(DBT_PROJECT),
            "--profiles-dir", str(DBT_PROJECT),
        ],
    },
]


def run_step(label: str, cmd: list) -> None:
    print(f"\n{'='*60}")
    print(f"  {label}")
    print(f"{'='*60}")
    # On Windows, shell=True is often needed for commands like 'dbt'
    result = subprocess.run(cmd, check=False, shell=(cmd[0] == "dbt"))
    if result.returncode != 0:
        print(f"\n[ERROR] Step failed with exit code {result.returncode}. Aborting.")
        sys.exit(result.returncode)
    print(f"[SUCCESS] {label} - DONE")


if __name__ == "__main__":
    for step in STEPS:
        run_step(step["label"], step["cmd"])

    print("\n" + "="*60)
    print("  Full pipeline completed successfully!")
    print("  Run dbt tests with:")
    print(f"    dbt test --project-dir {DBT_PROJECT} --profiles-dir {DBT_PROJECT}")
    print("="*60)
