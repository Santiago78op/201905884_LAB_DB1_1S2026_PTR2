/*
* Dar los nombres de los estudiantes que este semestre se asignaron que no tienen ningún traslape de horario.
*/
SELECT DISTINCT 
    e.nombre AS Estudiante
FROM estudiante e
-- Valida que exista el estudiante asignado en ese semestre
WHERE EXISTS(
    SELECT 1
    FROM asignacion a
        JOIN seccion s ON
            s.curso_codigocurso = a.seccion_curso_codigocurso
            AND s.seccion = a.seccion_seccion
            AND s.anio = a.seccion_anio
            AND s.ciclo = a.seccion_ciclo
    WHERE a.estudiante_carnet = e.carnet
        AND a.seccion_anio = 2010
        AND a.seccion_ciclo = 'CICLO1'
) -- Valida que no exista traslape en los cursos asigandos del estudiante
AND NOT EXISTS(
    SELECT 1
    -- asignacion de los cursos 
    FROM asignacion a1
        JOIN seccion s1 ON
            s1.curso_codigocurso = a1.seccion_curso_codigocurso
            AND s1.seccion = a1.seccion_seccion
            AND s1.anio = a1.seccion_anio
            AND s1.ciclo = a1.seccion_ciclo 
        JOIN horario h1 ON
            h1.seccion_curso_codigocurso = s1.curso_codigocurso
            AND h1.seccion_seccion = s1.seccion
            AND h1.seccion_anio = s1.anio
            AND h1.seccion_ciclo = s1.ciclo
            
        -- Valida asignacion
        JOIN asignacion a2 ON
            a2.estudiante_carnet = a1.estudiante_carnet
        JOIN seccion s2 ON
            s2.curso_codigocurso = a2.seccion_curso_codigocurso
            AND s2.seccion = a2.seccion_seccion
            AND s2.anio = a2.seccion_anio
            AND s2.ciclo = a2.seccion_ciclo 
        JOIN horario h2 ON
            h1.seccion_curso_codigocurso = s1.curso_codigocurso
            AND h1.seccion_seccion = s1.seccion
            AND h1.seccion_anio = s1.anio
            AND h1.seccion_ciclo = s1.ciclo
    
    WHERE a1.estudiante_carnet = e.carnet
        AND s1.anio = 2010
        AND s1.ciclo = 'CICLO1'
        AND s2.anio = 2010
        AND s2.ciclo = 'CICLO1'
        
        /*
        * Evita comparar la misma asignación contra sí misma.
        */
        AND (
            a1.seccion_curso_codigocurso <> a2.seccion_curso_codigocurso
         OR a1.seccion_seccion <> a2.seccion_seccion
         OR a1.seccion_anio <> a2.seccion_anio
         OR a1.seccion_ciclo <> a2.seccion_ciclo
        )
        
        /*
        * Condición de traslape:
        * mismo día y mismo período.
        */
        AND h1.dia_dia = h2.dia_dia
        AND h1.periodo_periodo = h2.periodo_periodo
);
