import pyodbc
import subprocess
import yaml
import time
from pathlib import Path

# Load config
config_path = Path(__file__).parent / "config.yaml"
with open(config_path, "r") as f:
    cfg = yaml.safe_load(f)

db = cfg["database"]
conn_str = (
    f"DRIVER={{{db['driver']}}};"
    f"SERVER={db['server']};"
    f"DATABASE={db['database']};"
    "Trusted_Connection=yes;"
)

print(f"Connecting to {db['database']} to truncate STG_PIPELINE_LOG...")
conn = pyodbc.connect(conn_str, autocommit=True)
cur = conn.cursor()

try:
    cur.execute("TRUNCATE TABLE dbo.STG_PIPELINE_LOG")
    print("STG_PIPELINE_LOG truncated.")
except Exception as e:
    print(f"Could not truncate: {e}")
    print("Trying DELETE FROM...")
    cur.execute("DELETE FROM dbo.STG_PIPELINE_LOG")
    print("STG_PIPELINE_LOG deleted.")

conn.close()

# Run the pipeline 3 times
pipeline_script = str(Path(__file__).parent / "btc_pipeline.py")

for i in range(1, 4):
    print(f"\n--- Running Batch {i}/3 ---")
    # Run the pipeline script
    result = subprocess.run(
        ["python", pipeline_script, "--run-now"],
        capture_output=True,
        text=True
    )
    if result.returncode != 0:
        print(f"Error in batch {i}: {result.stderr}")
    else:
        print(f"Batch {i} completed successfully.")
    
    if i < 3:
        # Wait a bit between batches just in case
        print("Waiting 10 seconds before next batch...")
        time.sleep(10)

print("\n--- Retrieving logs for the report ---")
conn = pyodbc.connect(conn_str, autocommit=True)
cur = conn.cursor()
cur.execute("""
SELECT source_name, status, records_fetched, records_inserted,
       last_block_height, run_ts
FROM   dbo.STG_PIPELINE_LOG
ORDER  BY run_ts;
""")

rows = cur.fetchall()
columns = [column[0] for column in cur.description]

# Format as markdown table
print("\n" + "|" + "|".join(columns) + "|")
print("|" + "|".join(["---" for _ in columns]) + "|")
for row in rows:
    print("|" + "|".join(str(item) for item in row) + "|")

conn.close()
