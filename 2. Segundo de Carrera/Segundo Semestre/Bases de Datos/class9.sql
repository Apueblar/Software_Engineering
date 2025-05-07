select apuntame_bd from dual;
select estoy_apuntado_bd from dual;

-- 13. Same but for a given dni
CREATE OR REPLACE PROCEDURE procedure13_ListCarsOneCustomer(p_dni IN customers.dni%TYPE) AS
v_ncars NUMBER;
v_ndealers NUMBER;
CURSOR cars_by_customer(p_dni IN sales.dni%TYPE) IS
    SELECT codecar, namec, model, color
        FROM sales s INNER JOIN cars c USING (codecar)
        WHERE s.dni = p_dni
        ORDER BY codecar;
BEGIN

    FOR car IN cars_by_customer(p_dni) LOOP
        DBMS_OUTPUT.PUT_LINE('---> Car: '||car.codecar ||' '||car.namec||' '||car.model||' ' || car.color);
    END LOOP;
        
END procedure13_ListCarsOneCustomer;

-- 1. Add a new attribute DataCaps to the PURCHASES table that stores the name and surname of customers in uppercase. 
--  Develop a trigger that keeps the value of that attribute updated.

SELECT UPPER('hello') FROM DUAL;

CREATE OR REPLACE TRIGGER PL2_TRIG_1 
BEFORE INSERT OR UPDATE OF NAME,SURNAME ON PURCHASES 
--REFERENCING OLD AS PACO NEW AS PEPE -- Not used 
FOR EACH ROW
--DECLARE
--UpperName PURCHASES.NAME%TYPE;
--UpperSurname PURCHASES.SURNAME%TYPE;
BEGIN
  :NEW.DATACAPS:=UPPER(:NEW.name||' '||:NEW.surname);
END;

--   := ASSIGNS

-- To update all the table
update purchases SET name=name;

-- 2. Create a trigger on table SALES (in own schema). Each time a sale is recorded, the trigger
--  should increment in 1 the number of cars (quantity) in table PURCHASES.

CREATE OR REPLACE TRIGGER PL2_TRIG_2 
AFTER INSERT ON SALES 
FOR EACH ROW
DECLARE
dniexists NUMBER;
customersName CUSTOMERS.name%TYPE;
customersSurname CUSTOMERS.surname%TYPE;
BEGIN
  SELECT COUNT(*) INTO dniexists
    FROM PURCHASES
    WHERE dni=:NEW.DNI;
  IF dniexists > 0 THEN
    UPDATE purchases
        SET NUM_CARSBOUGHT = NUM_CARSBOUGHT+1
        WHERE dni=:NEW.DNI;
  ELSE
    SELECT name, surname INTO customersName, customersSurname
        FROM customers
        WHERE dni = :NEW.DNI;
        
    INSERT INTO PURCHASES (dni, name, surname, num_carsbought)
        VALUES(:NEW.dni, customersName, customersSurname, 1);
  END IF;
END;

CREATE OR REPLACE TRIGGER PL2_TRIG_2B
AFTER INSERT ON SALES 
FOR EACH ROW
DECLARE
dniexists NUMBER;
customersName CUSTOMERS.name%TYPE;
customersSurname CUSTOMERS.surname%TYPE;
BEGIN
    SELECT name, surname INTO customersName, customersSurname
        FROM customers
        WHERE dni = :NEW.DNI;
        
    INSERT INTO PURCHASES (dni, name, surname, num_carsbought)
    SELECT :NEW.dni,name, surname,1
        FROM customers
        WHERE dni = :NEW.DNI;

EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
        UPDATE purchases
            SET NUM_CARSBOUGHT = NUM_CARSBOUGHT+1
            WHERE dni=:NEW.DNI;
END;


-- 3. Expand the above trigger so that when a customer deletes a sale, the number of cars in table
-- PURCHASESS is updated correspondingly

CREATE OR REPLACE TRIGGER PL2_TRIG_3
BEFORE INSERT OR DELETE ON SALES 
FOR EACH ROW
DECLARE
dniexists NUMBER;
numberOfCarsBought NUMBER;
customersName CUSTOMERS.name%TYPE;
customersSurname CUSTOMERS.surname%TYPE;
BEGIN
    IF INSERTING THEN
        SELECT COUNT(*) INTO dniexists
            FROM PURCHASES
            WHERE dni=:NEW.DNI;
        IF dniexists > 0 THEN -- If dni exists
            UPDATE purchases
                SET NUM_CARSBOUGHT = NUM_CARSBOUGHT+1
                WHERE dni=:NEW.DNI;
        ELSE -- If dni does not exist
            SELECT name, surname INTO customersName, customersSurname
                FROM customers
                WHERE dni = :NEW.DNI;
            
            INSERT INTO PURCHASES (dni, name, surname, num_carsbought)
                VALUES(:NEW.dni, customersName, customersSurname, 1);
        END IF;
    ELSIF DELETING THEN
        SELECT num_carsbought INTO numberOfCarsBought
                FROM PURCHASES
                WHERE dni=:OLD.DNI;
        IF numberOfCarsBought > 1 THEN -- As the user has more than 1 car, you remove one
            UPDATE purchases
                SET NUM_CARSBOUGHT = NUM_CARSBOUGHT-1
                WHERE dni=:OLD.DNI;
        ELSE -- As he removed the last car, the dni is eliminated
            DELETE FROM PURCHASES
                WHERE dni = :OLD.DNI;
        END IF;
    END IF;
END;

-- 4. Create a table CUSTOMERS_LOG with the following attributes: DniPrev, NamePrev,
--  SurnamePrev, CityPrev, DniCur, NameCur, SurnameCur, CityCur,
--  DateTime. Develop a trigger that manages this table logging every update done on the
--  CUSTOMERS table. DateTime stores the date and time in which the update was
--  performed.

CREATE TABLE CUSTOMERS_LOG (
DniPrev VARCHAR2(9), 
NamePrev VARCHAR2(40),
SurnamePrev VARCHAR2(40), 
CityPrev VARCHAR2(25), 
DniCur VARCHAR2(9), 
NameCur VARCHAR2(40), 
SurnameCur VARCHAR2(40), 
CityCur VARCHAR2(25),
DateTime DATE NOT NULL
);

CREATE OR REPLACE TRIGGER PL2_TRIG_4
BEFORE INSERT OR DELETE OR UPDATE ON SALES
FOR EACH ROW
BEGIN
	INSERT INTO CUSTOMERS_LOG VALUES (
		:OLD.Dni, :OLD.Name, :OLD.Surname, :OLD.City,
		:NEW.Dni, :NEW.Name, :NEW.Surname, :NEW.City,
		SYSTIMESTAMP
	);
END;