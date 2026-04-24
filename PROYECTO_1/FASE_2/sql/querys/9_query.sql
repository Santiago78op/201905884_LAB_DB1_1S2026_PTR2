/*
* Consulta 9:
* Dar el nombre de los estudiantes que, en cada dia donde llevan cursos,
* tienen mas de un curso y no presentan periodos intermedios libres.
*
* Nota:
* Se valida el semestre (2010, CICLO1), igual que en la consulta 8.

* Paso 1:
* Para cada estudiante, validar que tenga asignaciones en el semestre a validar.

* Paso 2:
* Para cada estudiante con asignaciones en el semestre a validar, validar que no
* exista ningún par de cursos del mismo estudiante que coincida en día y período
* (traslape).

* Paso 3:
* Mostrar el nombre de los estudiantes que cumplen la condición.
 */

/*
* Tabla temporal para almacenar el horario de cada estudiante en el semestre a validar.
*/
WITH horario_estudiante AS (
    /*
    * Horario base del estudiante en el semestre a validar.
    * Se usa DISTINCT para evitar duplicados de asignacion.
    */
    SELECT DISTINCT
        a.estudiante_carnet,
        h.dia_dia,
        a.seccion_curso_codigocurso,
        h.periodo_periodo,
        -- Convierte el horario de inicio y fin a formato de hora para facilitar comparaciones.
        -- Tuve falla por que los guardo como tipo char y eso me daba error al comparar.
        TO_DATE(p.horarioinicio, 'HH24:MI') AS hora_inicio,
        TO_DATE(p.horariofinal, 'HH24:MI') AS hora_fin
    FROM asignacion a
    JOIN horario h
        ON h.seccion_curso_codigocurso = a.seccion_curso_codigocurso
       AND h.seccion_seccion = a.seccion_seccion
       AND h.seccion_anio = a.seccion_anio
       AND h.seccion_ciclo = a.seccion_ciclo
    JOIN periodo p
        ON p.periodo = h.periodo_periodo
    -- Valida que las asignaciones sean del mismo estudiante.
    WHERE a.seccion_anio = 2010
      AND a.seccion_ciclo = 'CICLO1'
),
/*
* Tabla temporal para almacenar el resumen por estudiante y dia, 
* con la cantidad de cursos ese dia.
*/
resumen_dia AS (
    /*
    * Resumen por estudiante y dia:
    * - cantidad de cursos distintos ese dia.
    */
    SELECT
        he.estudiante_carnet,
        he.dia_dia,
        -- Cuenta la cantidad de cursos distintos ese dia.
        COUNT(DISTINCT he.seccion_curso_codigocurso) AS cursos_por_dia
    FROM horario_estudiante he
    GROUP BY
        he.estudiante_carnet,
        he.dia_dia
),
/*
* Tabla temporal para almacenar los bloques ordenados por estudiante y dia,
* con el inicio del siguiente bloque.
*/
bloques_ordenados AS (
    /*
    * Para cada estudiante y dia, ordenar bloques y conocer el inicio del siguiente.
    */
    SELECT
        he.estudiante_carnet,
        he.dia_dia,
        he.hora_fin,
        /*
        * LEAD me permite obtener el valor de la fila siguiente en el orden definido,
        * lo que me permite comparar el fin del bloque actual con el inicio del siguiente.
        
        * Ejemplo 
        * estudiante_carnet | dia_dia | hora_fin | siguiente_inicio
        * 1001             | Lunes   | 10:00    | 10:30
        * 1001             | Lunes   | 12:00    | NULL
        * 1002             | Martes  | 09:00    | 09:30
        * 1002             | Martes  | 10:00    | NULL
        */
        LEAD(he.hora_inicio) OVER (
            PARTITION BY he.estudiante_carnet, he.dia_dia
            ORDER BY he.hora_inicio, he.periodo_periodo
        ) AS siguiente_inicio
    FROM horario_estudiante he
)
/*
* Esta consulta se hace con el fin de mostrar el nombre de los estudiantes 
* que han sido asignados en el semestre a validar, y que no tienen ningún
* traslape de horario entre sus cursos asignados en ese semestre.
*/
SELECT
    e.nombre AS estudiante
FROM estudiante e
WHERE EXISTS (
    -- Debe tener al menos un dia con cursos en el semestre evaluado.
    SELECT 1
    FROM resumen_dia rd
    WHERE rd.estudiante_carnet = e.carnet
)
AND NOT EXISTS (
    /*
    * No debe existir ningun dia que incumpla:
    * - mas de un curso por dia
        * - sin periodo intermedio libre entre dos bloques consecutivos
    */
    SELECT 1
    FROM resumen_dia rd
    -- Valida que el estudiante sea el mismo.
    WHERE rd.estudiante_carnet = e.carnet
    -- Y que el dia tenga mas de un curso.
      AND (
          rd.cursos_por_dia <= 1
    -- O si tiene mas de un curso, debe validar que no exista un periodo intermedio libre entre bloques consecutivos.
        OR EXISTS (
                SELECT 1
                FROM bloques_ordenados bo
                WHERE bo.estudiante_carnet = rd.estudiante_carnet
                    AND bo.dia_dia = rd.dia_dia
                    AND bo.siguiente_inicio IS NOT NULL
                    AND EXISTS (
                            /*
                            * Si hay un periodo completo entre hora_fin y siguiente_inicio,
                            * entonces existe un periodo intermedio libre.
                            */
                            SELECT 1
                            FROM periodo pm
                            WHERE TO_DATE(pm.horarioinicio, 'HH24:MI') >= bo.hora_fin
                                AND TO_DATE(pm.horariofinal, 'HH24:MI') <= bo.siguiente_inicio
                    )
        )
    )
)
ORDER BY e.nombre;