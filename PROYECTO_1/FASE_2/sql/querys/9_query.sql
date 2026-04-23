/*
* Dar el nombre de los estudiantes que todos los días llevan más de un curso que no tienen ningún período intermedio libre.
*/

SELECT DISTINCT
    e.nombre AS Estudiante
FROM estudiante e
WHERE EXISTS (
    SELECT 1
    FROM asignacion a
    WHERE a.estudiante_carnet = e.carnet
)
AND NOT EXISTS (
    /*
    * No debe existir un día en el que el estudiante lleve
    * un solo curso o menos.
    */
    SELECT 1
    FROM (
        SELECT
            x.dia_dia,
            COUNT(*) AS cont_cursos_por_dia
        FROM (
            SELECT DISTINCT
                h.dia_dia,
                a.seccion_curso_codigocurso,
                a.seccion_seccion,
                a.seccion_anio,
                a.seccion_ciclo
            FROM asignacion a
            JOIN seccion s ON
                s.curso_codigocurso = a.seccion_curso_codigocurso
                AND s.seccion = a.seccion_seccion
                AND s.anio = a.seccion_anio
                AND s.ciclo = a.seccion_ciclo
            JOIN horario h ON
                h.seccion_curso_codigocurso = s.curso_codigocurso
                AND h.seccion_seccion = s.seccion
                AND h.seccion_anio = s.anio
                AND h.seccion_ciclo = s.ciclo
            WHERE a.estudiante_carnet = e.carnet
        ) x
        GROUP BY x.dia_dia
    ) t
    WHERE t.cont_cursos_por_dia <= 1
)
AND NOT EXISTS (
    /*
    * No debe existir un hueco entre un bloque y el siguiente
    * en un mismo día.
    */
    SELECT 1
    FROM (
        SELECT
            z.dia_dia,
            z.horarioinicio,
            z.horariofinal,
            LEAD(z.horarioinicio) OVER (
                PARTITION BY z.dia_dia
                ORDER BY z.horarioinicio
            ) AS siguiente_horario_inicio
        FROM (
            SELECT DISTINCT
                h.dia_dia,
                p.horarioinicio,
                p.horariofinal
            FROM asignacion a
            JOIN seccion s ON
                s.curso_codigocurso = a.seccion_curso_codigocurso
                AND s.seccion = a.seccion_seccion
                AND s.anio = a.seccion_anio
                AND s.ciclo = a.seccion_ciclo
            JOIN horario h ON
                h.seccion_curso_codigocurso = s.curso_codigocurso
                AND h.seccion_seccion = s.seccion
                AND h.seccion_anio = s.anio
                AND h.seccion_ciclo = s.ciclo
            JOIN periodo p ON
                p.periodo = h.periodo_periodo
            WHERE a.estudiante_carnet = e.carnet
        ) z
    ) t1
    WHERE t1.siguiente_horario_inicio IS NOT NULL
      AND t1.siguiente_horario_inicio > t1.horariofinal
);

-- Otra forma
/*
* Dar el nombre de los estudiantes que todos los días llevan más de un curso
* y que no tienen ningún período intermedio libre.

SELECT e.nombre AS Estudiante
FROM estudiante e
WHERE EXISTS (
    *
    * El estudiante debe tener al menos una clase.
    /
    SELECT 1
    FROM asignacion a
    WHERE a.estudiante_carnet = e.carnet
)
AND NOT EXISTS (
    *
    * No debe existir ningún día en el que el estudiante tenga
    * solo un curso o menos.
    /
    SELECT 1
    FROM (
        SELECT
            h.dia_dia,
            COUNT(*) AS cursos_por_dia
        FROM asignacion a
        JOIN seccion s
            ON s.curso_codigocurso = a.seccion_curso_codigocurso
           AND s.seccion = a.seccion_seccion
           AND s.anio = a.seccion_anio
           AND s.ciclo = a.seccion_ciclo
        JOIN horario h
            ON h.seccion_curso_codigocurso = s.curso_codigocurso
           AND h.seccion_seccion = s.seccion
           AND h.seccion_anio = s.anio
           AND h.seccion_ciclo = s.ciclo
        WHERE a.estudiante_carnet = e.carnet
        GROUP BY h.dia_dia
    ) t
    WHERE t.cursos_por_dia <= 1
)
AND NOT EXISTS (
    *
    * No debe existir un hueco entre dos clases consecutivas del mismo día.
    
    SELECT 1
    FROM (
        SELECT
            x.dia_dia,
            x.horarioinicio,
            x.horariofinal,
            LEAD(x.horarioinicio) OVER (
                PARTITION BY x.dia_dia
                ORDER BY x.horarioinicio
            ) AS siguiente_inicio
        FROM (
            SELECT
                h.dia_dia,
                p.horarioinicio,
                p.horariofinal
            FROM asignacion a
            JOIN seccion s
                ON s.curso_codigocurso = a.seccion_curso_codigocurso
               AND s.seccion = a.seccion_seccion
               AND s.anio = a.seccion_anio
               AND s.ciclo = a.seccion_ciclo
            JOIN horario h
                ON h.seccion_curso_codigocurso = s.curso_codigocurso
               AND h.seccion_seccion = s.seccion
               AND h.seccion_anio = s.anio
               AND h.seccion_ciclo = s.ciclo
            JOIN periodo p
                ON p.periodo = h.periodo_periodo
            WHERE a.estudiante_carnet = e.carnet
        ) x
    ) y
    WHERE y.siguiente_inicio IS NOT NULL
      AND y.siguiente_inicio > y.horariofinal
);
*/