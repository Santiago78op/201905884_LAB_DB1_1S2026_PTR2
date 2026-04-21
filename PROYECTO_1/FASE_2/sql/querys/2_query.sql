/*
* Dar el nombre del estudiante, nombre de la carrera, promedio y número * de créditos ganados, para los estudiantes que han cerrado en alguna carrera, estén inscritos en ella o no.
*/

-- INDICA QUE EL ESTUDIANTE YA CERRO O ESTA CERRANDO LA CARRERA, PERO EN ALGUN MOMENTO QUEDO REGISTRADO SU INSCRIPCIÓN EN ESA CARRERA, POR LO QUE SE INCLUYE EN EL RESULTADO DE LA CONSULTA.
SELECT *
FROM (
    SELECT 
    e.Nombre AS Estudiante,
    c.nombre AS Carrera,
    p.numerocreditoscierre,
    AVG(a.nota) AS Promedio_Nota,
    SUM(
        CASE
            WHEN a.Nota >= pe.notaaprobacion 
                AND a.zona >= pe.zonaminima
            THEN pe.numcreditos
            ELSE 0
        END
    ) AS Creditos_Ganados
    FROM asignacion a
    JOIN estudiante e ON
        e.carnet = a.estudiante_carnet
    JOIN inscripcion i ON
        i.estudiante_carnet = e.carnet 
    JOIN carrera c ON
        c.carrera = i.carrera_carrera
    JOIN plan p ON
        p.carrera_carrera = i.carrera_carrera
    JOIN pensum pe ON
        pe.curso_codigocurso = a.seccion_curso_codigocurso 
        AND pe.plan_plan = p.plan
        AND pe.plan_carrera_carrera = p.carrera_carrera
    GROUP BY 
        e.nombre, 
        c.nombre,
        p.numerocreditoscierre
) t
WHERE t.creditos_ganados >= t.numerocreditoscierre;