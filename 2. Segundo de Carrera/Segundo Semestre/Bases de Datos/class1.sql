select apuntame_bd from dual; -- Para apuntarme
select estoy_apuntado_bd from dual; -- Para comprobar que toy apuntado

/* Comentario multil�nea
F8 para el historial
*/

SELECT *
    FROM cars
    WHERE model = 'gtd';

INSERT INTO cars (codecar, model, namec)
    VALUES (21, 'c3po', 'paquito');

SELECT *
    FROM cars;
    
DELETE FROM cars
    WHERE codecar=21;

UPDATE cars
    SET model='txi'
    WHERE model='gtd';
    
