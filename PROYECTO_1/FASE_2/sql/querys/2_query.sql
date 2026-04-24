/*
* Consulta 2:
* Dar el nombre del estudiante, nombre de carrera, promedio y número de 
* créditos ganados, para quienes han cerrado en alguna carrera, estén 
* inscritos o no actualmente.

* Nota: Tome la tabla inscripción como estudiantes que estan inscritos,
* con la salvedad de que algunos pueden estarlo pero con la carrera cerrada
* o detenida, pero eso no los deja como no inscrito, ya que aunque ya no estén
* en un punto el estudiante fue inscrito.

* Paso 1:
* Para cada estudiante, se evalúa su promedio y créditos ganados en cada carrera
* en la que estuvo inscrito, usando el plan/pensum de esa carrera.

* Paso 2:
* Se valida si créditos ganados >= número de créditos de cierre 
* en la tabla PLAN para cada carrera, y se muestra el resultado.
*/

/*
* Esta consulta se hace con el fin de mostrar el nombre, promedio y
* créditos ganados de los estudiantes que han cerrado alguna carrera, 
* estén inscritos o no actualmente.

* Pero se hace una subconsulta interna para calcular el promedio y 
* créditos ganados de cada estudiante en cada carrera, y luego se 
* filtra en la consulta externa para mostrar solo aquellos que han 
* cerrado alguna carrera

* Nota: No se muestan otras carreras ya que en la data de asignacion
* solo estan estudiantes de la carrera 9.
*/
SELECT
    t.estudiante,
    t.carrera,
    t.promedio_nota,
    t.creditos_ganados,
    t.numerocreditoscierre
FROM (
    /*
    * El cierre se valida por cada carrera en la que el estudiante estuvo inscrito,
    * usando el pensum/plan de esa carrera.
    */
    SELECT
        e.nombre AS estudiante,
        c.nombre AS carrera,
        p.numerocreditoscierre,
        -- Promedio general de nota de los cursos asociados.
        AVG(a.nota) AS promedio_nota,
        -- Suma de creditos solo cuando cumple nota y zona minima.
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
    JOIN carrera c
        ON c.carrera = i.carrera_carrera
    JOIN plan p
        ON p.carrera_carrera = i.carrera_carrera
    JOIN pensum pe
        ON pe.curso_codigocurso = a.seccion_curso_codigocurso
       AND pe.plan_plan = p.plan
       AND pe.plan_carrera_carrera = p.carrera_carrera
    -- Agrupa por estudiante, nombre de carrera y créditos de cierre.
    GROUP BY
        e.nombre,
        c.nombre,
        p.numerocreditoscierre
) t
-- Filtro final: solo carreras donde el estudiante ya alcanzo el cierre.
WHERE t.creditos_ganados >= t.numerocreditoscierre;