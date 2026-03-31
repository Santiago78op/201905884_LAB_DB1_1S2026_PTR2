-- Dar el nombre del estudiante, promedio y número de créditos ganados, 
-- para los estudiantes que han cerrado Ingeniería en Ciencias y Sistemas.
SELECT 
    e.nombre,
    i.promedio_ponderado,
    i.creditos_acumulados
FROM
    ESTUDIANTE e
INNER JOIN
    INSCRIPCION i
        ON  e.id_estudiante = i.estudiante_id_estudiante
WHERE
    i.carrera_id_carrera = 9 -- Ingeniería en Ciencias y Sistemas
    AND i.estado = 'CERRADA';

-- Dar el nombre del estudiante, nombre de la carrera, promedio y numero de créditos ganadoos,
-- para los estudiantes que han cerrado en alguna carrera, esten inscritos en ella o no.
SELECT 
    e.nombre AS nombre_estudiante,
    c.nombre AS nombre_carrera,
    i.promedio_ponderado,
    i.creditos_acumulados,
    i.estado
FROM
    ESTUDIANTE e
INNER JOIN
    INSCRIPCION i
        ON  e.id_estudiante = i.estudiante_id_estudiante
INNER JOIN
    CARRERA c
        ON i.carrera_id_carrera = c.id_carrera
WHERE
    i.estado = 'CERRADA';

-- Dar el nombre de los estudiantes que han ganado algún curso con alguno de los catedraticos que han impartido alguno de los cursos de la carrera de Ingeniería en Ciencias y Sistemas en alguno de los planes que se han impartido en el semestre pasado.
SELECT DISTINCT -- DISTINCT para evitar duplicados
    e.NOMBRE AS nombre_estudiante,
    cu.NOMBRE AS nombre_curso,
    ca.NOMBRE AS nombre_carrera,
    d.NOMBRE AS nombre_docente,
    pl.ID_PLAN AS id_plan,
    j.NOMBRE AS nombre_jornada,
    a.SECCION_ANIO AS anio,
    a.SECCION_CICLO AS ciclo
FROM ESTUDIANTE e
INNER JOIN ASIGNACION a
    ON a.ESTUDIANTE_ID_ESTUDIANTE = e.ID_ESTUDIANTE
INNER JOIN SECCION s
    ON s.ID_SECCION = a.SECCION_ID_SECCION
   AND s.CURSO_ID_CURSO = a.SECCION_CURSO_ID_CURSO
   AND s.ANIO = a.SECCION_ANIO
   AND s.CICLO = a.SECCION_CICLO
INNER JOIN DOCENTE d
    ON d.ID_DOCENTE = s.DOCENTE_ID_DOCENTE
INNER JOIN PENSUM pe
    ON pe.PLAN_ID_PLAN = a.PENSUM_PLAN_ID_PLAN
   AND pe.PLAN_CARRERA_ID_CARRERA = a.PENSUM_PLAN_CARRERA_ID_CARRERA
   AND pe.CURSO_ID_CURSO = a.PENSUM_CURSO_ID_CURSO
INNER JOIN PLAN pl
    ON pl.ID_PLAN = pe.PLAN_ID_PLAN
   AND pl.CARRERA_ID_CARRERA = pe.PLAN_CARRERA_ID_CARRERA
INNER JOIN CARRERA ca
    ON ca.ID_CARRERA = pl.CARRERA_ID_CARRERA
INNER JOIN JORNADA j
    ON j.ID_JORNADA = pl.JORNADA_ID_JORNADA
INNER JOIN CURSO cu
    ON cu.ID_CURSO = pe.CURSO_ID_CURSO
WHERE ca.id_carrera = 9
  AND a.ESTADO = 'APROBADO'
  AND a.SECCION_ANIO = 2025
  AND a.SECCION_CICLO = 5
ORDER BY
    e.NOMBRE,
    cu.NOMBRE,
    d.NOMBRE;