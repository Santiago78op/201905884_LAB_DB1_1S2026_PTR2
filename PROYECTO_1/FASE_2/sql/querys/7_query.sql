/*
*Insertar una nueva columna en la tabla catedráticos en la que se grabe el salario que ganan, pero en letras. Pueden usar tablas auxiliares (no mayor a Q99,000 sin centavos, menor a Q99,000 con centavos)
*/
ALTER TABLE catedratico
ADD COLUMN salario_letras VARCHAR(255);

UPDATE catedratico
SET salario_letras = CASE
    WHEN salario >= 99000 THEN 'Q99,000 o más'
    WHEN salario >= 0 AND salario < 99000 THEN CONCAT('Q', FORMAT(salario, 2))
    ELSE 'Salario no válido'
END;

