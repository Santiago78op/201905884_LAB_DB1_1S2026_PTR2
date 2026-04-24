/*
* Consulta 3:
* Dar el nombre de los estudiantes que han ganado algún curso, con alguno
* de los catedráticos que han impartido alguno de los cursos de la carrera de
* sistemas en alguno de los planes que se han impartido en el semestre pasado.
*
* Nota:
* Tomare como semestre pasado el (2010, CICLO1).

* Paso 1:
* Identificar los catedráticos que impartieron cursos de la carrera de sistemas
* en el semestre pasado.

* Paso 2:
* Para cada estudiante, validar si ha ganado algún curso con alguno de esos 
* catedráticos, usando el criterio de aprobación del pensum de su carrera/plan.

* Paso 3:
* Mostrar el nombre de los estudiantes que cumplen la condición.
*/

/*
* Tabla temporal para almacenar los catedráticos que impartieron cursos de 
* la carrera de sistemas en el semestre pasado.

* Hago una consulta para validar que el estudiante haya ganado algún curso
* con alguno de esos catedráticos, usando el criterio de aprobación del 
* pensum de su carrera/plan.  
*/
WITH catedraticos_sistemas_semestre_pasado AS (
    /*
    * Conjunto de catedráticos que impartieron al menos un curso
    * perteneciente a la carrera 9 el semestre pasado.
    */
    SELECT DISTINCT
        s.catedratico_catedratico
    FROM seccion s
    JOIN plan p
        ON p.carrera_carrera = 9
    JOIN pensum pe
        ON pe.curso_codigocurso = s.curso_codigocurso
       AND pe.plan_plan = p.plan
       AND pe.plan_carrera_carrera = p.carrera_carrera
    -- Filtra por el semestre pasado.
    WHERE s.anio = 2010
      AND s.ciclo = 'CICLO1'
)
/*
* Consulta para mostrar el nombre de los estudiantes que han ganado algún curso,
* con alguno de los catedráticos que han impartido alguno de los cursos 
* de la carrera de sistemas en alguno de los planes que se han impartido 
* en el semestre pasado.
*/
SELECT DISTINCT
    e.nombre AS estudiante
FROM asignacion a
JOIN estudiante e
    ON e.carnet = a.estudiante_carnet
JOIN seccion s_est
    ON s_est.curso_codigocurso = a.seccion_curso_codigocurso
   AND s_est.seccion = a.seccion_seccion
   AND s_est.anio = a.seccion_anio
   AND s_est.ciclo = a.seccion_ciclo
/*
 * Valida que el catedrático de la sección del curso asignado al estudiante
 * esté en el conjunto de catedráticos que impartieron cursos de sistemas
 * el semestre pasado en la tabla temporal.
 */
WHERE s_est.catedratico_catedratico IN (
    -- Consilta la tabla temporal.
    SELECT cs.catedratico_catedratico
    FROM catedraticos_sistemas_semestre_pasado cs
)
/*
* Exists me permite validar que el estudiante haya ganado algún curso con 
* alguno de esos catedráticos, usando el criterio de aprobación del 
* pensum de su carrera/plan.

* EXISTS devuelve TRUE si hay almenos una fila que cumple la condición. 
*/
AND EXISTS (
    /*
    * Valida que la asignación del estudiante esté ganada,
    * usando el criterio de aprobación del pensum de su carrera/plan.
    */
    SELECT 1
    FROM inscripcion i
    JOIN plan p
        ON p.carrera_carrera = i.carrera_carrera
    JOIN pensum pe
        ON pe.curso_codigocurso = a.seccion_curso_codigocurso
       AND pe.plan_plan = p.plan
       AND pe.plan_carrera_carrera = p.carrera_carrera
    -- Valida que tenga ganado el curso.
    WHERE i.estudiante_carnet = a.estudiante_carnet
      AND a.nota >= pe.notaaprobacion
      AND a.zona >= pe.zonaminima
);