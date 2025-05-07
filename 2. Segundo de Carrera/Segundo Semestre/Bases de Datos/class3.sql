SELECT apuntame_bd FROM dual;

SELECT *
	FROM carmakers
	WHERE citycm = 'barcelona';

SELECT *
	FROM customers
	WHERE city = 'madrid' AND surname = 'garcia';

SELECT *
	FROM customers
	WHERE city = 'madrid' OR surname = 'garcia';

SELECT city, surname
	FROM customers
	WHERE city = 'madrid';

SELECT DISTINCT namecm nombre_de_la_marca
	FROM carmakers cm, cars c, cmcars cmc
	WHERE model = 'gtd' 
		AND cmc.cifcm = cm.cifcm -- Joins the tables
		AND cmc.codecar = c.codecar;
-- Now the same, with oracle code (Right click - Refactoring - Oracle joins)
SELECT DISTINCT cm.namecm nombre_de_la_marca
	FROM carmakers cm INNER JOIN cmcars  cmc ON cmc.cifcm = cm.cifcm
		INNER JOIN cars    c ON c.codecar = cmc.codecar
WHERE c.model = 'gtd';
-- SELECT distinct <> -- for removing equal values

-- 6: Names of car makers that have sold red cars.
SELECT cm.namecm
	FROM carmakers cm INNER JOIN cmcars  cmc ON cm.cifcm = cmc.cifcm
		INNER JOIN sales   s ON cmc.codecar = s.codecar
	WHERE s.color = 'red';
        
-- 7: Names of cars having the same models as the car named ‘cordoba’
SELECT namec
	FROM cars
	WHERE model IN (
        SELECT model
			FROM cars
			WHERE namec = 'cordoba'
		);

SELECT c2.namec
	FROM cars  c1, cars  c2
	WHERE c1.namec = 'cordoba'
		AND c1.model = c2.model;

-- 8: Names of cars NOT having a ‘gtd’ model.
SELECT DISTINCT namec
	FROM cars
	WHERE namec NOT IN (
        SELECT namec
        FROM cars
        WHERE model = 'gtd'
		);

SELECT namec
	FROM cars
	MINUS
	SELECT namec
		FROM cars
		WHERE model = 'gtd';

/*
UNION
INTERSECT
MINUS/EXCEPT
*/

-- 9: Pairs of values: CIFC from the CARMAKERS relation, and DNI from the CUSTOMERS relation belonging to the same city. The same for the ones not belonging to the same city. 
SELECT cm.cifcm cifc, cus.dni dni
	FROM carmakers cm INNER JOIN customers cus ON cm.citycm = cus.city;

SELECT cm.cifcm cifc, cus.dni dni
	FROM carmakers cm INNER JOIN customers cus ON cm.citycm != cus.city;

-- 10: Codecar values for the cars stocked in any dealer in ‘barcelona’
SELECT c.codecar
	FROM cars c INNER JOIN distribution  d ON c.codecar = d.codecar
		INNER JOIN dealers       de ON d.cifd = de.cifd
	WHERE de.cityd = 'barcelona';

-- 11: Codecar values for cars bought by a ‘madrid’ customer in a ‘madrid’ dealer.
SELECT s.codecar
    FROM customers cu INNER JOIN sales s ON s.dni = cu.dni
        INNER JOIN dealers d ON s.cifd = d.cifd
    WHERE cu.city = 'madrid' AND d.cityd = 'madrid';

-- 12: Codecar values for cars sold in a dealer in the same city as the buying customer.
SELECT s.codecar
    FROM customers cu INNER JOIN sales s ON s.dni = cu.dni
        INNER JOIN dealers d ON s.cifd = d.cifd
    WHERE cu.city = d.cityd;

-- 13: Pairs of CARMAKERS (names) from the same city.
SELECT cm1.namecm, cm2.namecm
    FROM carmakers cm1 INNER JOIN carmakers cm2 ON cm2.citycm = cm1.citycm
    WHERE cm1.cifcm != cm2.cifcm;

-- 14: DNI of the customers that have bought a car in a ‘madrid’ dealer.
SELECT distinct s.dni
    FROM sales s INNER JOIN dealers d ON s.cifd = d.cifd
    WHERE d.cityd = 'madrid';

-- 15: Colors of cars sold by the ‘acar’ dealer.
SELECT distinct s.color
    FROM sales s INNER JOIN dealers d ON s.cifd = d.cifd
    WHERE d.named = 'acar';

-- 16: Codecar of the cars sold by any ‘madrid’ dealer.
SELECT distinct s.codecar
    FROM sales s INNER JOIN dealers d ON s.cifd = d.cifd
    WHERE d.cityd = 'madrid';

-- 17: Names of customers that have bought any car in the ‘dcar’ dealer.
SELECT cu.name
    FROM customers cu INNER JOIN sales s ON s.dni = cu.dni
        INNER JOIN dealers d ON s.cifd = d.cifd
    WHERE d.named = 'dcar';

-- 18: Name and surname of the customers that have bought a ‘gti’ model with ‘white’ color.
SELECT cu.name, cu.surname
    FROM customers cu INNER JOIN sales s ON s.dni = cu.dni
        INNER JOIN cars c ON c.codecar = s.codecar
    WHERE c.model = 'gti' AND s.color = 'white'; 

-- 19: Name and surname of customers that have bought a car in a ‘madrid’ dealer that has ‘gti’ cars.
SELECT cu.name, cu.surname
    FROM customers cu INNER JOIN sales s ON s.dni = cu.dni
        INNER JOIN cars c ON c.codecar = s.codecar
        INNER JOIN dealers d ON s.cifd = d.cifd
    WHERE c.model = 'gti' AND d.cityd = 'madrid';

-- 20: Name and surname of customers that have bought (at least) a ‘white’ and a ‘red’ car.
SELECT distinct cu.name, cu.surname
    FROM customers cu INNER JOIN sales s ON s.dni = cu.dni
    WHERE s.color = 'white' AND s.dni IN (SELECT s.dni FROM sales s WHERE s.color = 'red');

-- 21: DNI of customers that have only bought cars at the dealer with CIFD ‘1’.
SELECT dni
    FROM sales
    WHERE cifd = '1' MINUS SELECT dni FROM sales WHERE cifd != '1';

-- 22: Names of the customers that have NOT bought ‘red’ cars at ‘madrid’ dealers
SELECT name 
    FROM customers
    MINUS SELECT cu.name
            FROM customers cu INNER JOIN sales s ON cu.dni = s.dni
                INNER JOIN dealers d ON s.cifd = d.cifd
            WHERE s.color = 'red' AND d.cityd = 'madrid';
            
            
            
            
-- 23: For each dealer (cifd), show the total amount of cars stocked.
SELECT cifd, SUM(stockage), MAX(stockage), MIN(stockage), AVG(stockage), COUNT(stockage)
    FROM distribution
    GROUP BY cifd;
/*
SUM()
MAX()
MIN()
AVG()
COUNT()
*/

-- 24: Show the cifd of dealers with an average stockage of more than 10 units (show that average as well).
SELECT cifd, AVG(stockage)
    FROM distribution
    GROUP BY cifd
    HAVING AVG(stockage) > 10;

-- 25: CIFD of dealers with a stock between 10 and 18 units inclusive.
SELECT cifd, SUM(stockage)
    FROM distribution
    GROUP BY cifd
    HAVING SUM(stockage) >= 10 AND SUM(stockage) <= 18;

SELECT cifd, SUM(stockage)
    FROM distribution
    GROUP BY cifd
    HAVING SUM(stockage) BETWEEN 10 AND 18;


-- 26: Total amount of car makers. Total amount of cities with car makers.
SELECT COUNT('CUALQUIER COSA')
    FROM carmakers;

SELECT COUNT(DISTINCT citycm)
    FROM carmakers;

-- 27: Name and surname of customers that have bought a car in a ‘madrid’ dealer, and have a name starting with j
SELECT name, surname
    FROM customers c INNER JOIN sales s ON c.dni = s.dni
        INNER JOIN dealers d USING (cifd) -- Similar to ON
    WHERE d.cityd = 'madrid'
        AND name LIKE 'j%';
-- % is 0 or more characters
-- _ is 1 and only 1

-- 28: List customers ordered by name (ascending)
SELECT dni,name,surname
    FROM customers
    ORDER BY surname ASC, name DESC;
--- ASC or DESC

-- 29: List customers that have bought a car in the same dealer as customer with dni ‘2’ (excluding the customer with dni ‘2’). Same with dni ‘1’.
SELECT distinct c.name, c.surname
    FROM sales INNER JOIN customers c USING (dni)
    WHERE dni != '2' AND cifd IN (
        SELECT cifd
            FROM sales
            WHERE dni = '2'
        );

SELECT distinct c.name, c.surname
    FROM sales INNER JOIN customers c USING (dni)
    WHERE dni != '1' AND cifd IN (
        SELECT cifd
            FROM sales
            WHERE dni = '1'
        );

-- 30: Return a list with the dealers which have a total number of car units in stock greater than the global unit average of all dealers together.
SELECT cifd
    FROM dealers d INNER JOIN distribution dis USING (cifd)
    GROUP BY cifd
    HAVING SUM(dis.stockage) > (
        SELECT AVG(total) FROM (
            SELECT SUM(stockage)total FROM distribution GROUP BY cifd
        )
    );


-- 31: Dealer having the best average stockage of all dealers; that is, dealer having an average stockage greater than the average stockage of each one of the remaining dealers.
SELECT cifd, d.named, d.cityd
    FROM dealers d INNER JOIN distribution dis USING (cifd)
    GROUP BY cifd, d.named, d.cityd
        HAVING AVG(dis.stockage) = 
        (
            SELECT MAX(average) FROM (
                SELECT AVG(stockage) average FROM distribution GROUP BY cifd
            )
        );


-- 32: List the two customers that have bought more cars in total, ordered by the number of cars bought.
--      List the sales of cars ordered by color. We want to remove the first one and obtain the next two allowing for ties (and without allowing them).

-- 33: Create a view from query 34. Using such view, list for each of the customers who have bought more cars in total, the code of the cars bought, the cifd of the dealers where they were bought, and the color.













