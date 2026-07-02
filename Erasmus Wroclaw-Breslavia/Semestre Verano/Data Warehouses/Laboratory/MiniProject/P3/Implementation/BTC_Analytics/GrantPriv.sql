USE master;
GO

-- Create a login for the SSAS service account if it doesn't exist
IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'NT SERVICE\MSSQLServerOLAPService')
    CREATE LOGIN [NT SERVICE\MSSQLServerOLAPService] FROM WINDOWS;
GO

USE BTC_DW;
GO

-- Create a user in BTC_DW mapped to that login
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'NT SERVICE\MSSQLServerOLAPService')
    CREATE USER [NT SERVICE\MSSQLServerOLAPService] FOR LOGIN [NT SERVICE\MSSQLServerOLAPService];
GO

-- Grant read access
ALTER ROLE db_datareader ADD MEMBER [NT SERVICE\MSSQLServerOLAPService];
GO