import pyodbc
conn=pyodbc.connect('Driver={ODBC Driver 17 for SQL Server};Server=LAPTOP-MKLCFCJJ;Database=BTC_Staging;Trusted_Connection=yes;')
conn.autocommit=True
conn.execute('ALTER TABLE dbo.STG_BLOCKS ADD pool_name VARCHAR(100) NULL, pool_slug VARCHAR(100) NULL')
print('done')
