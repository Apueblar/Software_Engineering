select apuntame_bd from dual;
select estoy_apuntado_bd from dual;

--     SELECT COUNT(*) INTO totalsRow.totalNumOfSales FROM sales;

-- 7. Create a new table CustomersLog using dni as primary key.
CREATE TABLE CustomersLog (
	DNI VARCHAR(9) NOT NULL,
	NAME VARCHAR(40),
	SURNAME VARCHAR(40),
	CITY VARCHAR(25),
	CONSTRAINT PK_CUSTOMERSLOG PRIMARY KEY (DNI)
);
-- Develop a stored procedure that copies the contents from the Customers table into that table.
create or replace PROCEDURE copyCustomers AS
BEGIN
    -- DELETE FROM CustomersLog;
    INSERT INTO CustomersLog
    SELECT * FROM Customers;
    COMMIT;
    
    EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
            DBMS_OUTPUT.PUT_LINE('EXCEPTION CAUGHT');
END copyCustomers;

-- Print several params of a table
CREATE OR REPLACE PROCEDURE cursor_procedure AS
    CURSOR c1 IS 
        SELECT dni, name FROM customers;
BEGIN
    FOR i IN c1 LOOP
        DBMS_OUTPUT.PUT_LINE(i.dni || '  ' || i.name);
    END LOOP;
END; 


-- HANDLING NO CURSOR
create or replace PROCEDURE P7 AS
    CURSOR customerList IS SELECT * FROM customers;
    current_Customer customerList%ROWTYPE;
BEGIN
    OPEN customerList;
    
    LOOP
        BEGIN
            EXIT WHEN customerList%NOTFOUND;
            FETCH customerList INTO current_Customer;
            
            INSERT INTO CustomersLog VALUES current_Customer;
        EXCEPTION
              WHEN DUP_VAL_ON_INDEX THEN
                UPDATE CustomersLog SET name=current_Customer.name, surname=current_Customer.surname, city=current_Customer.city
                WHERE dni = current_customer.dni;
        END;
    END LOOP;
        
    CLOSE customerList;
    COMMIT;
    
EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
        DBMS_OUTPUT.PUT_LINE('EXCEPTION CAUGHT');
END P7;

-- 9. Create a new table Purchases with the following information: dni, name, surname, 
-- number of cars bought (per customer). 
CREATE TABLE Purchases (
    DNI VARCHAR(9) NOT NULL,
	NAME VARCHAR(40),
	SURNAME VARCHAR(40),
	NUM_CARSBOUGHT NUMBER,
	CONSTRAINT PK_PURCHASES PRIMARY KEY (DNI)
);

-- Develop a PL/SQL procedure that uses a read cursor to insert the information into the new table.
create or replace PROCEDURE FILL_PURCHASES AS
    CURSOR c1 IS 
        SELECT c.dni, c.name, c.surname, count(*) as numcars
            FROM sales s, customers c
            WHERE s.dni=c.dni
            GROUP BY c.dni, c.name, c.surname;
    current_Purchase Purchases%ROWTYPE;
BEGIN
    FOR i IN c1 LOOP
        BEGIN
            INSERT INTO Purchases VALUES i;
            DBMS_OUTPUT.PUT_LINE(i.dni || '  ' || i.name || '  ' || i.surname || '  ' || i.numcars);
        EXCEPTION
              WHEN DUP_VAL_ON_INDEX THEN
                DBMS_OUTPUT.PUT_LINE('REPEATED ROW WAS FOUND');
        END;
    END LOOP;
END;

-- 10. Develop a stored procedure that takes a dealer id, and then returns the number of sales that were
--  made in that dealer.

create or replace PROCEDURE NUM_SALES_IN_DEALER(DEALER_CIFD IN VARCHAR,SALES_BY_DEALER OUT NUMBER) AS
BEGIN
    SELECT COUNT(*) INTO SALES_BY_DEALER
        FROM sales
        WHERE cifd=DEALER_CIFD;
END NUM_SALES_IN_DEALER;

--  Develop a function with the same functionality.
CREATE OR REPLACE FUNCTION FUNC_NUM_SALES_IN_DEALER(DEALER_CIFD IN VARCHAR2, a OUT NUMBER)
RETURN NUMBER IS
BEGIN
    SELECT COUNT(*) INTO a
        FROM sales
        WHERE cifd=DEALER_CIFD;
        RETURN a;
END FUNC_NUM_SALES_IN_DEALER;