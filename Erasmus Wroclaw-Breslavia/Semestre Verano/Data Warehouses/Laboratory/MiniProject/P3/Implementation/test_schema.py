import pyodbc
conn=pyodbc.connect('Driver={ODBC Driver 17 for SQL Server};Server=LAPTOP-MKLCFCJJ;Database=BTC_Staging;Trusted_Connection=yes;')
cur=conn.cursor()
cur.execute("SELECT c.name, t.name FROM sys.columns c JOIN sys.types t ON c.user_type_id = t.user_type_id WHERE c.object_id = OBJECT_ID('dbo.STG_BLOCKS')")
for r in cur.fetchall(): print(r)
