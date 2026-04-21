/*
* Dar el nombre del estudiante, promedio, y número de créditos ganados, * para los  estudiantes que han cerrado Ingeniería en Ciencias y Sistemas.
*/
SELECT *
FROM (
    SELECT 
        e.nombre,
        a.estudiante_carnet,
        p.numerocreditoscierre,
        AVG(a.nota) AS Promedio_Nota,
        SUM(CASE 
                WHEN a.nota >= pe.notaaprobacion 
                    AND a.zona >= pe.zonaminima 
                THEN pe.numcreditos ELSE 0 
            END
        ) AS Creditos_Ganados
    FROM asignacion a
    JOIN estudiante e ON
        e.carnet = a.estudiante_carnet
    JOIN inscripcion i ON
        i.estudiante_carnet = e.carnet 
    JOIN plan p ON
        p.carrera_carrera = i.carrera_carrera
    JOIN pensum pe ON
            pe.plan_plan = p.plan 
        AND pe.plan_carrera_carrera = p.carrera_carrera
        AND pe.curso_codigocurso = a.seccion_curso_codigocurso
    WHERE i.carrera_carrera = 9
    GROUP BY 
        a.estudiante_carnet, 
        e.nombre, 
        p.numerocreditoscierre
) t
WHERE t.creditos_ganados >= t.numerocreditoscierre;