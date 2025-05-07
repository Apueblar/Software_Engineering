select apuntame_bd from dual;
select estoy_apuntado_bd from dual;

-- 14
SELECT pub_id, AVG(price) as average_price
FROM titles
WHERE TO_NUMBER(pub_id,'9999') > 2
GROUP BY pub_id
HAVING AVG(price)>60
ORDER BY TO_NUMBER(pub_id,'9999');
-- ORDER BY CAST(pub_id as integer); -- The same as the TO_NUMBER when you dont know the maximum number

-- 21. Show the title and price of books having the same price as the cheapest book. (3 forms)
SELECT title, price
FROM titles
WHERE price = (SELECT MIN (price) FROM titles);

SELECT title, price
FROM titles
WHERE price <= ALL(SELECT price FROM titles);

SELECT title, price
FROM titles
ORDER by price ASC
FETCH FIRST 1 ROWS WITH TIES;

-- SQL 4

--2. Names of customers with an account but not a loan at Perryridge branch. Express the query in several different ways (using EXISTS/NOT EXITS, using IN/NOT IN or using MINUS/EXCEPT).
SELECT cus_name
    FROM customer
    WHERE EXISTS (
        SELECT *
            FROM account
            INNER JOIN accountholder ON account.acc_number = accountholder.acc_number
            WHERE accountholder.cus_name = customer.cus_name
            AND br_name = 'Perryridge'
        )
        AND NOT EXISTS (
            SELECT *
                FROM loan
                INNER JOIN borrower ON loan.lo_number = borrower.lo_number
                WHERE borrower.cus_name = customer.cus_name
                AND br_name = 'Perryridge');

SELECT DISTINCT cus_name
    FROM account
    INNER JOIN accountholder ON account.acc_number = accountholder.acc_number
    WHERE cus_name NOT IN (
        SELECT cus_name
            FROM loan INNER JOIN borrower ON loan.lo_number = borrower.lo_number
            WHERE br_name = 'Perryridge')
                AND br_name = 'Perryridge';

(SELECT cus_name
    FROM account
    INNER JOIN accountholder ON account.acc_number = accountholder.acc_number
    WHERE br_name = 'Perryridge')
MINUS -- EXCEPT in other languages
(SELECT cus_name
    FROM loan
    INNER JOIN borrower ON loan.lo_number = borrower.lo_number
    WHERE br_name = 'Perryridge'
);

--4. Namess of branches whose banking assets are greater than the assets of SOME branch in Brooklyn.
select distinct T.br_name
from branch T, branch S
where T.asset > S.asset and S.br_city = 'Brooklyn';

select br_name
from branch
where asset > ANY (select asset from branch where br_city='Brooklyn');

--5. Names of branches whose assets are greater than the assets of EVERY branch in Brooklyn.
select br_name
from branch
where asset > all (select asset from branch where br_city = 'Brooklyn');

select br_name
from branch
where asset > (select max(asset) from branch where br_city='Brooklyn');

--6. Names of customers at Perryridge branch, ordered by name.
(SELECT cus_name
    FROM borrower
    INNER JOIN loan ON borrower.lo_number = loan.lo_number
    WHERE loan.br_name = 'Perryridge')
UNION -- UNION ALL to have twice the duplicates of A u B
(SELECT cus_name
    FROM accountholder INNER JOIN account USING (acc_number)
    WHERE br_name = 'Perryridge')
ORDER BY cus_name;


------------- SQL 5 ---------------------------------
--2. Employees with last_name beginning with J, K, L or M.

SELECT last_name
FROM employees
WHERE last_name LIKE 'J%' OR  last_name LIKE 'K%' OR last_name LIKE 'L%' OR last_name LIKE 'M%';

SELECT last_name
FROM employees
WHERE SUBSTR(last_name,1,1) IN ('J', 'K', 'L', 'M');
-- SUBSTR(variable,start,#ofChars)

--9. Job title (job_id) that was fulfilled (hire_date) in the first half of 1990, and also in the first half of 1991.
(SELECT job_id
FROM employees
WHERE hire_date BETWEEN to_date('1990-01-01','yyyy-mm-dd') AND to_date('1990-06-30','yyyy-mm-dd'))
INTERSECT -- INTERSECT ALL to have twice the duplicates
(SELECT job_id
FROM employees
WHERE hire_date BETWEEN to_date('1991-01-01','yyyy-mm-dd') AND to_date('1991-06-30','yyyy-mm-dd'));

--10. Show the top 3 employees that earn the most. 
SELECT last_name, salary
FROM employees e
WHERE 3 > (SELECT COUNT(*)
    FROM employees
    WHERE e.salary < salary);

SELECT last_name, salary
FROM employees
ORDER BY salary DESC
FETCH FIRST 3 ROWS WITH TIES;
--FETCH FIRST 3 ROWS ONLY;

--13. List employees whose salary is not in the appropriate range for their job (job_id). Show, in addition to the employee_id, its salary and the minimum and maximum salaries of the job.
SELECT employee_id, salary, min_salary,max_salary
  FROM employees e, jobs j
  WHERE e.job_id=j.job_id
    AND salary not between min_salary and max_salary;
	
--16. The salary of employees working in a job whose minimum wage (min_salary) is 4200 must be increased by 15%.
UPDATE employees
SET salary = salary*1.15
WHERE job_id IN (SELECT job_id
    FROM jobs
    WHERE min_salary = 4200);

/*
UPDATE table
SET attribute = new_value
WHERE condition
*/

------------- SQL 7 ---------------------------------
--2. Name of the companies starting with letter 'C' that have distribution networks that send energy to other networks, but they do not receive energy from any other network.
SELECT cname
    FROM belong b INNER JOIN distribution_network d ON b.networknumber = d.networknumber    
    WHERE SUBSTR(cname, 1, 1) IN ('C') 
        AND b.networknumber IN 
        (
        SELECT networknumber_send
        FROM send_energy
        )
        AND b.networknumber NOT IN 
        (
        SELECT networknumber_receive
        FROM send_energy
        )
    GROUP BY cname;

--7. Obtain the name and capital stock for the companies with more than 50 M of this capital, 
--  as well as the total number of shares these companies own on distribution networks that neither 
--  send nor receive energy from any other distribution network, 
--  and provided that such total number of shares is greater than 25000.
SELECT cname, capitalstock, sum(shares) TOTAL_NUM_SHARES
    FROM company INNER JOIN belong USING (cname)
    WHERE capitalstock > 50
        AND networknumber NOT IN 
        (
        SELECT networknumber_send
        FROM send_energy
        )
        AND networknumber NOT IN 
        (
        SELECT networknumber_receive
        FROM send_energy
        )
    GROUP BY cname, capitalstock
    HAVING sum(shares) > 25000;

SELECT b.cname, capitalstock, sum(shares) as totalshares
FROM belong b, company c
WHERE b.cname = c.cname AND capitalstock > 50 AND networknumber IN
	((SELECT networknumber FROM distribution_network WHERE networknumber NOT IN (SELECT networknumber_send FROM send_energy))
	MINUS
	(SELECT networknumber FROM distribution_network WHERE networknumber IN (SELECT networknumber_receive FROM send_energy)))
GROUP BY b.cname, capitalstock
HAVING SUM(shares) > 25000;

SELECT b.cname, capitalstock, SUM(shares) as totalshares
FROM belong b, company c
WHERE b.cname = c.cname AND capitalstock > 50 AND networknumber IN
	((SELECT networknumber FROM distribution_network WHERE networknumber NOT IN (SELECT networknumber_send FROM send_energy))
	INTERSECT
	(SELECT networknumber FROM distribution_network WHERE networknumber NOT IN (SELECT networknumber_receive FROM send_energy)))
GROUP BY b.cname, capitalstock
HAVING SUM(shares) > 25000;

--13.Increase by 10 the number of transformers of the stations in which some of the nuclear centrals 
--  that send energy to them generate a volume of waste greater than 30000.3

UPDATE station
    SET transformers = transformers + 10
    WHERE sname IN (
        SELECT sname
            FROM nuclear n INNER JOIN provide p USING (pname)
            WHERE n.waste > 30000.3
    );


-- PL / SQL --
-- TO CREATE IT
CREATE PROCEDURE hello_world_procedure IS
BEGIN
    DBMS_OUTPUT.PUT_LINE('Hello_World');
END;

-- MODIFIED
create or replace PROCEDURE hello_world_procedure(text IN VARCHAR) IS
BEGIN
    DBMS_OUTPUT.PUT_LINE('Hello_World');
    DBMS_OUTPUT.PUT_LINE(text);
END;