/*
* Dar el nombre de las parejas de estudiantes que han llevado todos los cursos en común (es decir, han sido compañeros en todos los cursos).
*/

-- Parejas de estudiantes
SELECT
    e1.nombre AS Estudiante1,
    e2.nombre AS Estudiante2
FROM estudiante e1
    JOIN estudiante e2 ON
    -- Forma parejas si tengo 1001 - 1002, 1001 - 1003 y 1002 - 1003
        e1.carnet < e2.carnet
-- Verifica que ambos estudiantes hayan llevado el mismo curso
WHERE EXISTS (
    /*
    * Esta subconsulta asegura que los estudiantes tengan al menos un curso en común.
    * Si no tienen cursos en común, no se consideran pareja válida.
    */
    SELECT 1
    FROM asignacion a1
    -- Se busca el mismo curso en el estudiante 2
        JOIN asignacion a2 ON
            a2.estudiante_carnet = e2.carnet
            AND a2.seccion_curso_codigocurso =  a1.seccion_curso_codigocurso
        WHERE a1.estudiante_carnet = e1.carnet
) 
-- Verifica que en el curso en común, ambos esten asignados
AND NOT EXISTS (
    /*
    * Esta subconsulta verifica que no exista ningún curso en común donde NO hayan sido compañeros.
    */ 
    SELECT 1
    FROM asignacion a1
    -- Se buscan cursos en común entre ambos estudiantes
        JOIN asignacion a2 ON
            a2.estudiante_carnet = e2.carnet
            AND a2.seccion_curso_codigocurso =  a1.seccion_curso_codigocurso
     
        WHERE a1.estudiante_carnet = e1.carnet
            AND NOT (
                /*
                * Esta condición verifica, que si fueron compañeros
                * comparten sección, año y ciclo.
                */
                a1.seccion_curso_codigocurso = a2.seccion_curso_codigocurso
                AND a1.seccion_seccion = a2.seccion_seccion
                AND a1.seccion_anio = a2.seccion_anio
                AND a1.seccion_ciclo = a2.seccion_ciclo
            )
);