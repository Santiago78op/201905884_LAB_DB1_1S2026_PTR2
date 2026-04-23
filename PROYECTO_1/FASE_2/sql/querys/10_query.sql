/*
*Para un estudiante, dar el código y nombre de los cursos que pueden asignarse el próximo semestre, basado en que ya aprobó los respectivos prerrequisitos.
*/

SELECT
    c.codigocurso,
    c.nombrecurso
FROM inscripcion i
JOIN plan pl ON
    pl.carrera_carrera = i.carrera_carrera
JOIN pensum pe ON
    pe.plan_plan = pl.plan
    AND pe.plan_carrera_carrera = pl.carrera_carrera
JOIN curso c ON
    c.codigocurso = pe.curso_codigocurso
WHERE i.estudiante_carnet = 1001

/*
* El estudiante no debe haber aprobado ya el curso candidato.
*/
AND NOT EXISTS (
    SELECT 1
    FROM asignacion a
    JOIN pensum pe_aprobado ON
        pe_aprobado.curso_codigocurso = a.seccion_curso_codigocurso
        AND pe_aprobado.plan_plan = pe.plan_plan
        AND pe_aprobado.plan_carrera_carrera = pe.plan_carrera_carrera
    WHERE a.estudiante_carnet = i.estudiante_carnet
    AND a.seccion_curso_codigocurso = pe.curso_codigocurso
    AND a.nota >= pe_aprobado.notaaprobacion
    AND a.zona >= pe_aprobado.zonaminima
)

/*
* No debe existir ningún prerrequisito del curso candidato
* que el estudiante no haya aprobado.
*/
AND NOT EXISTS (
    SELECT 1
    FROM PRERREQ pr
    WHERE pr.PENSUM_PLAN = pe.plan_plan
    AND pr.PENSUM_CARRERA = pe.plan_carrera_carrera
    AND pr.pensum_curso_codigocurso = pe.curso_codigocurso

    AND NOT EXISTS (
        SELECT 1
        FROM asignacion a2
        JOIN pensum pe_pre ON
            pe_pre.curso_codigocurso = a2.seccion_curso_codigocurso
            AND pe_pre.plan_plan = pe.plan_plan
            AND pe_pre.plan_carrera_carrera = pe.plan_carrera_carrera
        WHERE a2.estudiante_carnet = i.estudiante_carnet
            AND a2.seccion_curso_codigocurso = pr.CURSOPRERREQUISITO
            AND a2.nota >= pe_pre.notaaprobacion
            AND a2.zona >= pe_pre.zonaminima
    )
  );