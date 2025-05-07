select apuntame_bd from dual;
select estoy_apuntado_bd from dual;

-- CURSORS and Procedures

-- 10. Develop a stored procedure that takes a dealer id, and then returns the number of sales that were
--  made in that dealer.
SELECT COUNT(*)
    FROM sales s
    WHERE s.cifd= XXXXX;

CREATE OR REPLACE PROCEDURE procedure10B(p_dealer_id IN Varchar2, p_nsales OUT NUMBER) AS
-- DECLARE SOME VARIABLES
BEGIN 
    SELECT COUNT(*) INTO p_nsales
        FROM sales s
        WHERE s.cifd = p_dealer_id;
END procedure10B;

--  Develop a function with the same functionality.
CREATE OR REPLACE FUNCTION function10B(p_dealer_id IN Varchar2) RETURN NUMBER AS
-- DECLARE SOME VARIABLES
r_nsales NUMBER;
BEGIN 
    SELECT COUNT(*) INTO r_nsales
        FROM sales s
        WHERE s.cifd = p_dealer_id;
        RETURN r_nsales;
END function10B;

-- To run the function
SELECT function10B(1)
    FROM dual;


-- 11. Develop a PL/SQL function that takes a dni that is passed as a parameter, returns 2 values: 
--  a) the number of cars that customer has purchased and 
--  b) the number of dealers in which he has purchased them.
SELECT count(*) ncars, count(distinct cifd) ndealers
    FROM sales
    WHERE dni=1;

CREATE OR REPLACE FUNCTION function11(p_dni IN Varchar2, p_ndealers OUT NUMBER) RETURN NUMBER AS
v_ncars NUMBER;
BEGIN 
    SELECT count(*) ncars, count(distinct cifd) ndealers INTO v_ncars, p_ndealers
        FROM sales
        WHERE dni=p_dni;
        RETURN v_ncars;
END function11;

--  Develop a stored procedure with the same functionality
CREATE OR REPLACE PROCEDURE procedure11(p_dni IN Varchar2, p_ncars OUT NUMBER, p_ndealers OUT NUMBER) AS
BEGIN 
    SELECT count(*) ncars, count(distinct cifd) ndealers INTO p_ncars, p_ndealers
        FROM sales
        WHERE dni=p_dni;
END procedure11;

-- 12. Develop a stored procedure called ListCarsByCustomer. The procedure should generate a
--  report with the cars that have been bought by each customer with this template:
CREATE OR REPLACE PROCEDURE procedure12_ListCarsByCustomer AS
CURSOR customers IS
    SELECT DISTINCT dni, name, surname
        FROM sales s INNER JOIN customers cu USING (dni)
        ORDER BY name;
v_ncars NUMBER;
v_ndealers NUMBER;
CURSOR cars_by_customer(p_dni IN sales.dni%TYPE) IS
    SELECT codecar, namec, model, color
        FROM sales s INNER JOIN cars c USING (codecar)
        WHERE s.dni = p_dni
        ORDER BY codecar;
BEGIN
    FOR current_customer IN customers LOOP
        SELECT count(*) ncars, count(distinct cifd) ndealers INTO v_ncars,v_ndealers
            FROM sales
            WHERE dni = current_customer.dni;
        DBMS_OUTPUT.PUT_LINE('- Customer: '||current_customer.name||' '||current_customer.surname||' '||v_ncars||' ' || v_ndealers);
        
        FOR car IN cars_by_customer(current_customer.dni) LOOP
            DBMS_OUTPUT.PUT_LINE('---> Car: '||car.codecar ||' '||car.namec||' '||car.model||' ' || car.color);
        END LOOP;
        
    END LOOP;
END procedure12_ListCarsByCustomer;

-- 13. Same but for a given dni
CREATE OR REPLACE PROCEDURE procedure13_ListCarsOneCustomer(p_dni IN customers%TYPE) AS
v_ncars NUMBER;
v_ndealers NUMBER;
CURSOR cars_by_customer(p_dni IN sales.dni%TYPE) IS
    SELECT codecar, namec, model, color
        FROM sales s INNER JOIN cars c USING (codecar)
        WHERE s.dni = p_dni
        ORDER BY codecar;
BEGIN
    FOR current_customer IN customers LOOP
        SELECT count(*) ncars, count(distinct cifd) ndealers INTO v_ncars,v_ndealers
            FROM sales
            WHERE dni = current_customer.dni;
        DBMS_OUTPUT.PUT_LINE('- Customer: '||current_customer.name||' '||current_customer.surname||' '||v_ncars||' ' || v_ndealers);
        
        FOR car IN cars_by_customer(current_customer.dni) LOOP
            DBMS_OUTPUT.PUT_LINE('---> Car: '||car.codecar ||' '||car.namec||' '||car.model||' ' || car.color);
        END LOOP;
        
    END LOOP;
END procedure13_ListCarsOneCustomer;















