/*
* Consulta 2:
* Nombre del estudiante, nombre de carrera, promedio y créditos ganados,
* para quienes han cerrado en alguna carrera (aunque ya no estén activos hoy).
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
        AVG(a.nota) AS promedio_nota,
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
    GROUP BY
        e.nombre,
        c.nombre,
        p.numerocreditoscierre
) t
WHERE t.creditos_ganados >= t.numerocreditoscierre;