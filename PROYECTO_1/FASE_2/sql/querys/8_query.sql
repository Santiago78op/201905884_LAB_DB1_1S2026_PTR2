/*
* Consulta 8:
* Estudiantes asignados este semestre sin ningún traslape de horario.
*
* Nota:
* Se utiliza (2010, CICLO1) como "este semestre" según la convención del script.
*/

SELECT DISTINCT
    e.nombre AS estudiante
FROM estudiante e
WHERE EXISTS (
    /*
    * El estudiante debe tener al menos una asignación en el semestre objetivo.
    */
    SELECT 1
    FROM asignacion a
    WHERE a.estudiante_carnet = e.carnet
      AND a.seccion_anio = 2010
      AND a.seccion_ciclo = 'CICLO1'
)
AND NOT EXISTS (
    /*
    * No debe existir ningún par de cursos del mismo estudiante
    * que coincida en día y período (traslape).
    */
    SELECT 1
    FROM asignacion a1
    JOIN horario h1
        ON h1.seccion_curso_codigocurso = a1.seccion_curso_codigocurso
       AND h1.seccion_seccion = a1.seccion_seccion
       AND h1.seccion_anio = a1.seccion_anio
       AND h1.seccion_ciclo = a1.seccion_ciclo
    JOIN asignacion a2
        ON a2.estudiante_carnet = a1.estudiante_carnet
    JOIN horario h2
        ON h2.seccion_curso_codigocurso = a2.seccion_curso_codigocurso
       AND h2.seccion_seccion = a2.seccion_seccion
       AND h2.seccion_anio = a2.seccion_anio
       AND h2.seccion_ciclo = a2.seccion_ciclo
    WHERE a1.estudiante_carnet = e.carnet
      AND a1.seccion_anio = 2010
      AND a1.seccion_ciclo = 'CICLO1'
      AND a2.seccion_anio = 2010
      AND a2.seccion_ciclo = 'CICLO1'
      AND (
          a1.seccion_curso_codigocurso < a2.seccion_curso_codigocurso
       OR (a1.seccion_curso_codigocurso = a2.seccion_curso_codigocurso AND a1.seccion_seccion < a2.seccion_seccion)
      )
      AND h1.dia_dia = h2.dia_dia
      AND h1.periodo_periodo = h2.periodo_periodo
);
