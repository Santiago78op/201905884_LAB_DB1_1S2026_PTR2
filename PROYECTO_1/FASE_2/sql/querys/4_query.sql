/*
* Para un estudiante determinado que cerrado en alguna carrera, dar el nombre de los estudiantes que llevaron con él todos los cursos.
*/
SELECT
    et.carnet,
    et.nombre
FROM estudiante et
-- et estudiante temporal para encontrar aquellos diferentes al 1001, pero con mismos cursos ganados.
WHERE et.carnet <> 1001
-- Devuelve TRUE si la subconsulta no devuelve filas. 
-- Se usa para validar que el estudiante cerro alguna carrera
AND NOT EXISTS (
    -- Se usa 1, por convencion, indica que no importan las columnas, solo interesa si devuelve filas.
    SELECT 1
    FROM(
        SELECT
            e.carnet,
            p.numerocreditoscierre,
            SUM(
                CASE
                    WHEN  a.nota >= pe.notaaprobacion
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
        JOIN plan p ON
            p.carrera_carrera = i.carrera_carrera
        JOIN pensum pe ON
            pe.curso_codigocurso = a.seccion_curso_codigocurso 
            AND pe.plan_plan = p.plan
            AND pe.plan_carrera_carrera = p.carrera_carrera
        WHERE e.carnet = 1001
        GROUP BY p.numerocreditoscierre,
            e.carnet
    ) t
    WHERE t.Creditos_Ganados >= t.numerocreditoscierre
)
-- Se usa para validar estudiantes que llevaron los mismos cursos.
AND NOT EXISTS (
    SELECT 1
    FROM asignacion a
    WHERE a.estudiante_carnet = 1001
    AND NOT EXISTS (
        SELECT 1
        FROM asignacion a2
        WHERE a2.estudiante_carnet = et.carnet
            AND a2.seccion_curso_codigocurso = a.seccion_curso_codigocurso
    )
);

