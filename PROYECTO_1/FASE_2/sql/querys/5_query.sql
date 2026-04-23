/*
* Consulta 5:
* Parejas de estudiantes que, en todos sus cursos en común,
* sí fueron compañeros (misma sección, año y ciclo).
*/

SELECT
    e1.nombre AS estudiante1,
    e2.nombre AS estudiante2
FROM estudiante e1
JOIN estudiante e2
    ON e1.carnet < e2.carnet
WHERE EXISTS (
    /*
    * Deben tener al menos un curso en común,
    * de lo contrario no se considera pareja.
    */
    SELECT 1
    FROM asignacion a1
    JOIN asignacion a2
        ON a2.estudiante_carnet = e2.carnet
       AND a2.seccion_curso_codigocurso = a1.seccion_curso_codigocurso
    WHERE a1.estudiante_carnet = e1.carnet
)
AND NOT EXISTS (
    /*
    * No debe existir un curso en común donde no coincidieron
    * en la misma sección (año/ciclo/sección).
    */
    SELECT 1
    FROM asignacion a1
    JOIN asignacion a2
        ON a2.estudiante_carnet = e2.carnet
       AND a2.seccion_curso_codigocurso = a1.seccion_curso_codigocurso
    WHERE a1.estudiante_carnet = e1.carnet
      AND NOT (
          a1.seccion_seccion = a2.seccion_seccion
      AND a1.seccion_anio = a2.seccion_anio
      AND a1.seccion_ciclo = a2.seccion_ciclo
      )
);