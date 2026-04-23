/*
* Consulta 4:
* Para un estudiante determinado (1001), que ya cerró alguna carrera,
* listar estudiantes que llevaron con él todos los cursos (misma sección/año/ciclo/curso).
*/

SELECT
    et.carnet,
    et.nombre
FROM estudiante et
WHERE et.carnet <> 1001
AND EXISTS (
    /*
    * El estudiante base (1001) debe haber cerrado al menos una carrera.
    */
    SELECT 1
    FROM (
        SELECT
            e.carnet,
            p.numerocreditoscierre,
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
            ON pe.curso_codigocurso = a.seccion_curso_codigocurso
           AND pe.plan_plan = p.plan
           AND pe.plan_carrera_carrera = p.carrera_carrera
        WHERE e.carnet = 1001
        GROUP BY
            e.carnet,
            p.numerocreditoscierre
    ) t
    WHERE t.creditos_ganados >= t.numerocreditoscierre
)
AND NOT EXISTS (
    /*
    * No debe existir ninguna asignación del estudiante base
    * que el estudiante comparado no haya llevado con él.
    */
    SELECT 1
    FROM asignacion a
    WHERE a.estudiante_carnet = 1001
      AND NOT EXISTS (
          SELECT 1
          FROM asignacion a2
          WHERE a2.estudiante_carnet = et.carnet
            AND a2.seccion_curso_codigocurso = a.seccion_curso_codigocurso
            AND a2.seccion_seccion = a.seccion_seccion
            AND a2.seccion_anio = a.seccion_anio
            AND a2.seccion_ciclo = a.seccion_ciclo
      )
);

