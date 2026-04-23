/*
* Consulta 3:
* Estudiantes que han ganado algún curso con catedráticos que,
* en el semestre pasado, impartieron cursos de Sistemas.
*
* Nota:
* Se toma como semestre pasado el par (2010, CICLO1) según la convención del script.
*/

WITH catedraticos_sistemas_semestre_pasado AS (
    /*
    * Conjunto de catedráticos que impartieron al menos un curso
    * perteneciente a planes de la carrera 9 (Sistemas) en semestre pasado.
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
    WHERE s.anio = 2010
      AND s.ciclo = 'CICLO1'
)
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
WHERE s_est.catedratico_catedratico IN (
    SELECT cs.catedratico_catedratico
    FROM catedraticos_sistemas_semestre_pasado cs
)
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
    WHERE i.estudiante_carnet = a.estudiante_carnet
      AND a.nota >= pe.notaaprobacion
      AND a.zona >= pe.zonaminima
);