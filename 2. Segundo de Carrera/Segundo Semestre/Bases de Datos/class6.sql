select apuntame_bd from dual;
select estoy_apuntado_bd from dual;

-- 3. Code a stored procedure that takes a name as a parameter, and then prints “Hello” + name.
create or replace PROCEDURE HelloName ( name in Varchar) AS
BEGIN
	DBMS_OUTPUT.PUT_LINE('Hello ' || name);
END;

-- 4.Code a stored procedure that shows the maximum value for the stockage attribute in table distribution.
create or replace PROCEDURE maxStockageInDistribution AS
    maximumStockage distribution.stockage%TYPE;
BEGIN
    SELECT max(stockage) INTO maximumStockage
        FROM distribution;
    DBMS_OUTPUT.PUT_LINE('The maximum stockage is: ' || maximumStockage);
END;

-- 5. Code a stored procedure that, given a specific dealer, shows the total number of cars stocked.
create or replace PROCEDURE stockGivenDealer (dealercifd dealers.cifd%TYPE) AS
    dealerStockage distribution.stockage%TYPE;
BEGIN
    SELECT SUM(stockage) INTO dealerStockage
        FROM distribution
        WHERE cifd = dealercifd;
    DBMS_OUTPUT.PUT_LINE('Given the dealer: ' || dealercifd || ', its stockage is: ' || dealerStockage);
END;


-- 6. Create a table with these attributes: total number of sales, total number of cars, total number
--  of car makers, total number of customers, total number of dealers. 
CREATE TABLE totals (
    totalNumOfSales NUMBER,
    totalNumOfCars NUMBER,
    totalNumOfCarMakers NUMBER,
    totalNumOfCustomers NUMBER,
    totalNumOfDealers NUMBER
);

-- Create a stored procedure that queries the database to compute each of those values, stores them in variables, and then inserts them into the table. 
create or replace PROCEDURE insertTotals AS
    totalsRow totals%ROWTYPE;
BEGIN
    SELECT COUNT(*) INTO totalsRow.totalNumOfSales FROM sales;
    SELECT COUNT(*) INTO totalsRow.totalNumOfCars FROM cars;
    SELECT COUNT(*) INTO totalsRow.totalNumOfCarMakers FROM carmakers;
    SELECT COUNT(*) INTO totalsRow.totalNumOfCustomers FROM customers;
    SELECT COUNT(*) INTO totalsRow.totalNumOfDealers FROM dealers;
    
    INSERT INTO totals VALUES totalsRow;
END;
-- Check that the insertion has been performed correctly.
SELECT * FROM TOTALS;

-- 7. Create a new table CustomersLog using dni as primary key.
CREATE TABLE CustomersLog (
	DNI VARCHAR(9) NOT NULL,
	NAME VARCHAR(40),
	SURNAME VARCHAR(40),
	CITY VARCHAR(25),
	CONSTRAINT PK_CUSTOMERS PRIMARY KEY (DNI)
);
-- Develop a stored procedure that copies the contents from the Customers table into that table.
create or replace PROCEDURE copyCustomers AS
    customersRow customers%ROWTYPE;
    i PLS_INTEGER := 0;
BEGIN
    DELETE FROM CustomersLog;
    <<first_loop>>
    LOOP
        i := i + 1;
        

    END LOOP first_loop;
    SELECT COUNT(*) INTO totalsRow.totalNumOfSales FROM sales;
    SELECT COUNT(*) INTO totalsRow.totalNumOfCars FROM cars;
    SELECT COUNT(*) INTO totalsRow.totalNumOfCarMakers FROM carmakers;
    SELECT COUNT(*) INTO totalsRow.totalNumOfCustomers FROM customers;
    SELECT COUNT(*) INTO totalsRow.totalNumOfDealers FROM dealers;
    
    INSERT INTO totals VALUES totalsRow;
END;

















