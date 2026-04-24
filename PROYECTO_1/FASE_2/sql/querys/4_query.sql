/*
* Consulta 4:
* Para un estudiante determinado, que ya cerró alguna carrera, dar el nombre de
* los estudiantes que llevaon con él todos los cursos.

* Nota: 
* Para los cursos use el criterio que deben de estar en (misma sección/año/ciclo/curso).

* Paso 1:
* Identificar un estudiante que haya cerrado alguna carrera.

* Paso 2:
* Para ese estudiante, identificar los cursos que ha llevado (sección/año/ciclo/curso).

* Paso 3:
* Validar que otro estudiante haya llevado exactamente los mismos cursos (sección/año/ciclo/curso).

* Paso 4:
* Mostrar el nombre de los estudiantes que cumplen la condición.
*/

/*
* Esta consulta se hace con el fin de mostrar el nombre de los estudiantes que 
* han llevado exactamente los mismos cursos (sección/año/ciclo/curso) 
* que el estudiante base, siempre y cuando este haya cerrado alguna carrera.
*/
SELECT
    et.carnet,
    et.nombre
FROM estudiante et
-- Valida para todos los estudiantes excepto el estudiante base.
WHERE et.carnet <> 1001
/*
* Exists me permite validar que el estudiante base haya cerrado alguna carrera.
*/
AND EXISTS (
    /*
    * El estudiante base debe haber cerrado al menos una carrera.
    */
    SELECT 1
    FROM (
        /*
        * La subconsulta permite calcular los créditos ganados por el estudiante 
        * base en cada carrera en la que estuvo inscrito, usando el plan/pensum 
        * de esa carrera.
        */
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
        -- Valida que el estudiante sea el estudiante base.
        WHERE e.carnet = 1001
        -- Agrupa por estudiante para calcular los créditos ganados por cada carrera.
        GROUP BY
            e.carnet,
            p.numerocreditoscierre
    ) t
    -- Filtra por el estudiante base y valida que haya cerrado alguna carrera.
    WHERE t.carnet = 1001
      AND t.creditos_ganados >= t.numerocreditoscierre
)
/*
* Not Exists me permite validar que no exista ningún curso (sección/año/ciclo/curso)
* que el estudiante base haya llevado y el estudiante comparado no lo haya llevado.

* NOT EXISTS devuelve TRUE si no hay ninguna fila que cumple la condición.
*/
AND NOT EXISTS (
    /*
    * No debe existir ninguna asignación del estudiante base
    * que el estudiante comparado no haya llevado con él.
    */
    SELECT 1
    FROM asignacion a
    -- Valida que la asignación sea del estudiante base.
    WHERE a.estudiante_carnet = 1001
      /*
      * Valida que no exista una asignación del estudiante comparado con 
      * la misma sección/año/ciclo/curso.
      */
      AND NOT EXISTS (
          SELECT 1
          FROM asignacion a2
          -- Valida que la asignación sea del estudiante comparado.
          WHERE a2.estudiante_carnet = et.carnet
            AND a2.seccion_curso_codigocurso = a.seccion_curso_codigocurso
            AND a2.seccion_seccion = a.seccion_seccion
            AND a2.seccion_anio = a.seccion_anio
            AND a2.seccion_ciclo = a.seccion_ciclo
      )
);

