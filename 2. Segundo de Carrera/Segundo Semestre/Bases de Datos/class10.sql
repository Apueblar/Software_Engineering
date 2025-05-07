select apuntame_bd from dual;
select estoy_apuntado_bd from dual;

-- 3. Expand the above trigger so that when a customer deletes a sale, the number of cars in table
-- PURCHASESS is updated correspondingly

CREATE OR REPLACE TRIGGER PL2_TRIG_3
BEFORE INSERT OR DELETE OR UPDATE ON SALES 
FOR EACH ROW
DECLARE
dniexists NUMBER;
numberOfCarsBought NUMBER;
customersName CUSTOMERS.name%TYPE;
customersSurname CUSTOMERS.surname%TYPE;
BEGIN
    IF INSERTING OR UPDATING THEN
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
    END IF;
    IF DELETING OR UPDATING THEN
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
AFTER INSERT OR DELETE OR UPDATE ON CUSTOMERS
FOR EACH ROW
BEGIN
	INSERT INTO CUSTOMERS_LOG VALUES (
		:OLD.Dni, :OLD.Name, :OLD.Surname, :OLD.City,
		:NEW.Dni, :NEW.Name, :NEW.Surname, :NEW.City,
		SYSTIMESTAMP
	);
END;

--NVL(:NEW.DNI,'No value')
--SELECT SYSTIMESTAMP FROM dual;
--vCUSTOMERS_LOG;

-- 5. Develop a trigger that decrements the number of cars stocked in a dealer whenever a car is
--  sold, but only in the case that the number of cars stocked in the dealer is greater than 1.
CREATE OR REPLACE TRIGGER PL2_TRIG_5_CHECK
BEFORE INSERT OR UPDATE OF CIFD,CODECAR ON SALES
FOR EACH ROW
DECLARE
v_num_cars NUMBER;
BEGIN
	SELECT stockage INTO v_num_cars
        FROM distribution
        WHERE cifd=:NEW.cifd AND codecar=:NEW.codecar;
    
    IF v_num_cars < 1 THEN
        RAISE_APPLICATION_ERROR(-20000, 'NOT ENOUGH CARS in stockage');
    END IF;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20001, 'SOMETHING IS WRONG WITH YOUR DATA');
END;

CREATE OR REPLACE TRIGGER PL2_TRIG_5_UPDATE
AFTER INSERT OR DELETE OR UPDATE OF CIFD,CODECAR ON SALES
FOR EACH ROW
BEGIN
    IF INSERTING OR UPDATING THEN
        UPDATE DISTRIBUTION
            SET stockage = stockage-1
            WHERE cifd=:NEW.cifd AND codecar=:NEW.codecar;
    END IF;
    IF DELETING OR UPDATING THEN
        UPDATE DISTRIBUTION
                SET stockage = stockage-1
                WHERE cifd=:OLD.cifd AND codecar=:OLD.codecar;
    END IF;
END;

-- 6. Develop a trigger so that table PURCHASES can be deleted only by the owner of the schema
--  between 11:00 and 13:00.
-- HACEN LO MISMO, el usuario que ejecuta el insert, del, upd.
--USER
--sys_context('USERENV', 'CURRENT_USER');

SELECT TO_NUMBER(TO_CHAR(SYSDATE, 'hh24')) FROM dual;

SELECT OWNER FROM ALL_TABLES WHERE TABLE_NAME = 'PURCHASES';

CREATE OR REPLACE TRIGGER PL2_TRIG_6
BEFORE DELETE ON PURCHASES
DECLARE
V_USER VARCHAR2(100):=USER;
V_OWNER VARCHAR2(100);
V_HOUR NUMBER:=TO_NUMBER(TO_CHAR(SYSDATE, 'HH24'));
BEGIN
    SELECT OWNER INTO V_OWNER
        FROM ALL_TABLES
        WHERE TABLE_NAME = 'PURCHASES';
    IF V_USER <> V_OWNER THEN
        RAISE_APPLICATION_ERROR(-20002, 'YOU ARE NOT THE OWNER');
    END IF;
    IF v_hour <11 or v_hour>13 THEN 
        RAISE_APPLICATION_ERROR(-20003,'YOU ARE NOT IN TIME');
    END IF;
END;

-- 7. Develop a trigger that stores in a PURCHASES_LOG table the operation performed (insert,
--  delete, update), the date of the operation, and the user initiating the operation.
CREATE TABLE purchases_log (
    operation VARCHAR2(20),
    date_op DATE,
    user_op VARCHAR2(20)
);

CREATE OR REPLACE TRIGGER PL2_TRIG_7
AFTER INSERT OR DELETE OR UPDATE ON PURCHASES
DECLARE
V_OP VARCHAR2(20);
BEGIN
    IF INSERTING THEN
        V_OP:= 'INSERT';
    ELSIF DELETING THEN
        V_OP:= 'DELETE';
    ELSE
        V_OP:= 'UPDATE';
    END IF;
    INSERT INTO PURCHASES_LOG VALUES(v_op,SYSDATE,USER);
END;


CREATE TABLE purchases_log (
    operation VARCHAR2(20),
    date_op DATE,
    user_op VARCHAR2(20)
);

-- 8. Yellow color has been discontinued, so yellow cars cannot be sold anymore
CREATE OR REPLACE TRIGGER PL2_TRIG_8
BEFORE INSERT OR UPDATE OF COLOR ON SALES
FOR EACH ROW
WHEN (NEW.Color='YELLOW')
BEGIN
    RAISE_APPLICATION_ERROR(-20005, 'YELLOW COLOR IS DISCONTINUED.');
END;

-- 9. No dealer can stock more than 40 cars
CREATE OR REPLACE TRIGGER PL2_TRIG_9
BEFORE INSERT OR UPDATE ON DISTRIBUTION
FOR EACH ROW
DECLARE
v_stock NUMBER;
BEGIN
    SELECT SUM(stockage) INTO v_stock
        FROM distribution
        WHERE cifd = :NEW.cifd;
    IF v_stock + :NEW.stockage > 40 THEN
        RAISE_APPLICATION_ERROR(-20007, 'A CARDEALER CANNOT HAVE MORE THAN 40 CARS IN STOCKAGE.');
    END IF;
END;

-- 10. Dealer 1 closed its doors yesterday. Therefore, this dealer cannot sell from now on.
CREATE OR REPLACE TRIGGER PL2_TRIG_10
BEFORE INSERT OR UPDATE OF CIFD ON SALES
FOR EACH ROW
WHEN (NEW.CIFD=1)
BEGIN
    RAISE_APPLICATION_ERROR(-20006, 'CIFD ClOSED YESTERDAY.');
END;

-- 11. We have detected a possible toxic substance in the paint used to paint red cars. Fortunately, no
--  cars were sold with that toxic before, but from now on, we want to log information about the
--  cars that are sold. The log should record the cif and name of the dealer, the dni and name of
--  the customer, the code, name and model of the car, and the date and time of the sale.
CREATE TABLE SALES_LOG (
CifdDealer VARCHAR2(255),
NameDealer VARCHAR2(255), 
DniCustomer VARCHAR2(9), 
NameCustomer VARCHAR2(40),
CodeCar NUMBER(38),
NameCar VARCHAR2(255),
ModelCar VARCHAR2(255),
DateTime DATE NOT NULL
);

CREATE OR REPLACE TRIGGER PL2_TRIG_11
AFTER INSERT OR UPDATE ON SALES
FOR EACH ROW
BEGIN
    INSERT INTO SALES_LOG (CifdDealer, NameDealer, DniCustomer, NameCustomer, CodeCar, NameCar, ModelCar, DateTime)
        SELECT cifd, named, dni, name, codecar, namec, model, SYSTIMESTAMP
            FROM cars INNER JOIN customers ON customers.dni = :NEW.dni
                INNER JOIN dealers   ON dealers.cifd = :NEW.cifd
            WHERE codecar = :NEW.codecar;
END;

-- 12. Circulation of gray cars has been banned by the government. Therefore, gray cars that are sold
--  must be painted in another color: white if the car model is ‘gtd’, and black if not.
CREATE OR REPLACE TRIGGER PL2_TRIG_12
BEFORE INSERT OR UPDATE ON SALES
FOR EACH ROW
WHEN (NEW.color = 'gray')
DECLARE
v_model Cars.codecar%TYPE;
BEGIN
    SELECT model INTO v_model
        FROM cars
        WHERE codecar = :NEW.codecar;
    IF v_model = 'gtd' THEN
        :NEW.color := 'white';
    ELSE
        :NEW.color := 'black';
    END IF;
END;



