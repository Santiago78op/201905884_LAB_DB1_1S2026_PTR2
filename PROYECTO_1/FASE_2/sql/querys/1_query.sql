/*
* Consulta 1:
* Dar el nombre del estudiante, promedio y número de créditos ganados,
* para quienes han cerrado Ingeniería en Ciencias y Sistemas.

* Paso 1:
* Como se que un estudiante ha cerrado la carrera?
* Tengo que sumar los créditos de los cursos que ha aprobado, 
* y comparar el resultado contra el número de créditos cierre.

* Paso 2:
* Valido si créditos ganados >= número de créditos de cierre 
* en la tabla PLAN.
*/

/*
* Esta consulta se hace con el fin de mostrar el nombre, promedio y 
* créditos ganados de los estudiantes que han cerrado la 
* carrera de Ingeniería en Ciencias y Sistemas.

* Pero se hace una subconsulta interna para calcular el promedio y créditos ganados de cada estudiante,
* y luego se filtra en la consulta externa para mostrar solo aquellos que han cerrado la carrera
*/
SELECT
    t.nombre,
    t.estudiante_carnet,
    t.promedio_nota,
    t.creditos_ganados,
    t.numerocreditoscierre
FROM (
    /*
    * Se calcula el promedio del estudiante y los créditos acumulados
    * en la carrera 9, evaluando los campos de Nota/Zona del pensum.
    */
    SELECT
        e.nombre,
        a.estudiante_carnet,
        p.numerocreditoscierre,
        -- Promedio de nota sobre los cursos del estudiante.
        AVG(a.nota) AS promedio_nota,
        -- Suma de creditos solo de cursos aprobados por nota y zona minima.
        SUM(
            CASE
                WHEN a.nota >= pe.notaaprobacion
                 AND a.zona >= pe.zonaminima
                THEN pe.numcreditos
                ELSE 0
            END
        ) AS creditos_ganados
    FROM asignacion a
    JOIN estudiante e
        ON e.carnet = a.estudiante_carnet
    JOIN inscripcion i
        ON i.estudiante_carnet = e.carnet
    JOIN plan p
        ON p.carrera_carrera = i.carrera_carrera
    JOIN pensum pe
        ON pe.plan_plan = p.plan
       AND pe.plan_carrera_carrera = p.carrera_carrera
       AND pe.curso_codigocurso = a.seccion_curso_codigocurso
    -- Valida que la carrera del estudiante sea Ingeniería en Ciencias y Sistemas.
    WHERE i.carrera_carrera = 9
    -- Agrupa por estudiante para calcular el promedio y créditos ganados por cada uno.
    GROUP BY
        a.estudiante_carnet,
        e.nombre,
        p.numerocreditoscierre
) t
-- Filtra solo los estudiantes que ttengan o superen el número de creditos cierre.
WHERE t.creditos_ganados >= t.numerocreditoscierre;