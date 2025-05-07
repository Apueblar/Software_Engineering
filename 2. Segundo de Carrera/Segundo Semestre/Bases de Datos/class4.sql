select apuntame_bd from dual;
select estoy_apuntado_bd from dual;

SELECT c.dni, name, surname
FROM customers c, 
(
	SELECT count(codecar) total_cars, dni
	FROM sales
	GROUP  BY dni
	ORDER BY total_cars DESC
	FETCH FIRST 2 ROWS WITH TIES
) a
WHERE c.dni = a.dni;

-- 32: List the two customers that have bought more cars in total, ordered by the number of cars bought.
--      List the sales of cars ordered by color. We want to remove the first one and obtain the next two allowing for ties (and without allowing them).

SELECT *
    FROM sales
    ORDER BY color
    OFFSET 1 ROWS
    FETCH FIRST 2 ROWS WITH TIES;

-- OFFSET n ROWS -> Skips n rows 
-- FETCH FIRST n ROWS ONLY -> ONLY 2 
-- FETCH FIRST n ROWS WITH TIES -> 2 or more if empate en la última

-- 33: Create a view from query 34. Using such view, list for each of the customers who have bought more cars in total, 
--  the code of the cars bought, the cifd of the dealers where they were bought, and the color.
CREATE VIEW customersMoreCARS AS
    SELECT c.dni, name, surname
        FROM customers c, 
        (
            SELECT count(codecar) total_cars, dni
            FROM sales
            GROUP  BY dni
            ORDER BY total_cars DESC
            FETCH FIRST 2 ROWS WITH TIES
        ) a
        WHERE c.dni = a.dni; -- ONCE you close the view disapears

DROP VIEW customersMoreCARS; -- TO remove / drop the table

SELECT s.codecar, s.cifd, s.color
    FROM sales s INNER JOIN customersmorecars c ON s.dni = c.dni;

-- NEW SQL·

-- 1. Retrieve a relation with two columns, one for the titles and one for the expected revenue for each
--  title. The revenue is calculated as expected sales times price of the title.
SELECT title, expected_sales * price EXPECTED_REVENUE
    FROM titles;
    
-- 2. Show the titles with expected sales between 200 and 5000 units (copies).
SELECT title, expected_sales
    FROM titles
    GROUP BY title, expected_sales
    HAVING SUM(expected_sales) BETWEEN 200 AND 5000;

-- 3. Show the name, surname and telephone number for all the authors ordered first by name in
--  ascending order and then by surname in descending order.
SELECT au_name, au_surname, au_telephone
    FROM authors
    ORDER BY au_name ASC, au_surname DESC;

-- 4. Show the name and surname of the authors that do not have telephone number (i.e. it is null).
SELECT au_name, au_surname
    FROM authors
    WHERE au_telephone IS null;

-- 5. Show the name, surname and telephone number of all the authors, denoting “no telephone” for those
--  that do not have telephone number. Express the query using the function NVL.
SELECT au_name, au_surname, au_telephone, NVL(au_telephone, 'no telephone')
    FROM authors;
-- NVL(variable, 'replaces null by this')

-- 6. Show the title id, title and expected sales for titles with type database (BD) or programming (PROG).
--  Order them descendingly by price. Express the query in two different ways.
SELECT title_id, title, expected_sales
    FROM titles
    WHERE type IN ('BD','PROG')
    ORDER BY price DESC;

SELECT title_id, title, expected_sales
    FROM titles
    WHERE type = 'BD' OR type = 'PROG'
    ORDER BY price DESC;

-- 7. Show the authors with a telephone number starting with ‘456’.
SELECT au_name, au_surname, au_telephone
    FROM authors
    WHERE au_telephone LIKE '456%';
-- REGULAR EXPRESIONS
-- % -> 0 or more chars
-- _ -> Only 1 char

-- 8. Show the average price for titles in the relation TITLES. Show average price for titles with BD type.
--  Express the query in two different ways.
SELECT AVG(price) AVG_PRICE
    FROM titles;

SELECT AVG(price) AVG_PRICE_BD
    FROM titles
    WHERE type = 'BD';

-- 9. Show the number of titles of each publisher. Number of titles belonging to each type, per publisher.
SELECT pub_id, COUNT(title) NUMBER_TITLES
    FROM titles
    GROUP BY pub_id;

SELECT pub_id, type, COUNT(title) NUMBER_TITLES
    FROM titles
    GROUP BY pub_id, type
    ORDER BY type ASC;

-- 10. Show the number of copies in stock for each type of title. Ignore null values.
SELECT type, COUNT(type) TOTAL
    FROM titles
    WHERE type IS NOT null
    GROUP BY type;

-- 11. Show the average price for each type of title with a publishing date later than year 2000.
SELECT type, AVG(price)
    FROM titles
    WHERE d_publishing > TO_DATE('31/12/1999','DD/MM/YYYY')
    GROUP BY type;
-- GIVEN date > TO_DATE('31/12/1999','DD/MM/YYYY')

-- 12. Show the number of copies in stock for each type of title, but only if it is greater than 1.
SELECT type, COUNT(title) AVERAGE_PRICE  
    FROM titles
    GROUP BY type
    HAVING COUNT(title) > 1;

-- 13. Show the average price for each type of title, but only if it is greater than 35.
SELECT type, AVG(price) AVERAGE_PRICE
    FROM titles
    GROUP BY type
    HAVING AVG(price) > 35;

-- 14. Show the average price for the titles of each publisher, but only if its identifier is greater than 2 and
--  the average price is greater than 60. The result should be ordered ascendingly by publisher id.
SELECT pub_id, AVG(price) AVERAGE_PRICE
    FROM titles
    WHERE pub_id > 2
    GROUP BY pub_id
    HAVING AVG(price) > 60
    ORDER BY pub_id ASC;

-- 15. Show the name, surname and editor_order for the title with ‘1’ as identifier.
SELECT ed_name, ed_surname, editor_order
    FROM titleseditors te INNER JOIN editors e USING (ed_id)
    WHERE title_id = '1';

-- 16. Show the names of the editors and publishers that are in the same city.
SELECT pub_name, ed_name, ed_city
    FROM publishers p, editors e
    WHERE p.pub_city = e.ed_city;

-- 17. Show the titles of BD type books, with the names of the authors and author_order.
SELECT title, au_name, au_surname, author_order
    FROM titles INNER JOIN titlesauthors USING (title_id)
        INNER JOIN authors USING (au_id)
    WHERE type = 'BD'

-- 18. Show the name and surname of editors with the name of his chief editor.
SELECT ed_name, ed_surname, ed_chief
    FROM editors


-- 19. Show the data from authors (au_id, au_name and au_surname) that have the same surname.
-- 20. Show the names of publishers that publish PROG titles. Express the query in two different ways.
-- 21. Show the title and price of books having the same price as the cheapest book. Same with the most
--  expensive one.
-- 22. Show the name and city of authors that live in the same city as ‘Abraham Silberschatz’.
-- 23. Show the name and surname of authors that are both individual authors and co-authors.
-- 24. Show the types of books that are in common for more than one publisher. Express the query in two
--  different ways.
-- 25. Show the types of books with a maximum price at least a 10% more expensive than the average price
--  of that type. And for 20%.
-- 26. Show the books that have a greater pre-publishing than the greatest pre-publishing of ‘Prentice Hall’
--  publisher.
-- 27. Show the titles of the books published by a publisher established in a city starting with ‘B’.
-- 28. Show the names of publishers that do not publish BD type books. Express the query in two different ways











