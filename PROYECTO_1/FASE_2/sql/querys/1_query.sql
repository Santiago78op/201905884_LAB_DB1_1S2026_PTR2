/*
* Consulta 1:
* Nombre del estudiante, promedio y créditos ganados,
* para quienes han cerrado Ingeniería en Ciencias y Sistemas.
*
* Criterio de cierre:
* créditos ganados >= número de créditos de cierre del plan de la carrera de sistemas.
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
    * en la carrera 9 (Sistemas), evaluando aprobación por Nota/Zona del pensum.
    */
    SELECT
        e.nombre,
        a.estudiante_carnet,
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
    JOIN plan p
        ON p.carrera_carrera = i.carrera_carrera
    JOIN pensum pe
        ON pe.plan_plan = p.plan
       AND pe.plan_carrera_carrera = p.carrera_carrera
       AND pe.curso_codigocurso = a.seccion_curso_codigocurso
    WHERE i.carrera_carrera = 9
    GROUP BY
        a.estudiante_carnet,
        e.nombre,
        p.numerocreditoscierre
) t
WHERE t.creditos_ganados >= t.numerocreditoscierre;