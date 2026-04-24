/*
* Consulta 6:
* Estudiantes con promedio de nota mayor al promedio de su carrera
* y edad menor al promedio de edad de su carrera.

* Paso 1:
* Para cada estudiante, calcular su promedio de nota y edad.

* Paso 2:
* Para cada carrera, calcular el promedio de nota y edad de sus estudiantes.

* Paso 3:
* Mostrar el nombre de los estudiantes que cumplen la condición.
*/

/*
* Esta consulta se hace con el fin de mostrar el nombre, promedio de nota y edad
* de los estudiantes que tienen un promedio de nota mayor al promedio de su carrera
* y una edad menor al promedio de edad de su carrera.
*/
SELECT 
    t.estudiante,
    t.carrera,
    t.nombre_carrera,
    t.promedio_nota,
    t.edad
FROM (
    /*
    * Para cada estudiante/carrera:
    * - promedio de nota
    * - edad en años completos
    */
    SELECT
        e.carnet,
        e.nombre AS estudiante,
        c.carrera AS carrera,
        c.nombre AS nombre_carrera,
        -- Promedio general de nota de los cursos asociados.
        AVG(a.nota) AS promedio_nota,
        -- Edad en años completos.
        /*
        * TRUNC se usa para elimnar o ajustar fechas a un nivel especifico
        * MONTHS_BETWEEN devuelve el número de meses entre dos fechas.
        * Al dividir entre 12, obtenemos la edad en años, y al truncar
        * obtenemos la edad en años completos.
        */
        TRUNC(MONTHS_BETWEEN(SYSDATE, e.fechanacimiento) / 12) AS edad
    FROM estudiante e
    JOIN inscripcion i
        ON i.estudiante_carnet = e.carnet
    JOIN carrera c
        ON c.carrera = i.carrera_carrera
    JOIN asignacion a
        ON a.estudiante_carnet = e.carnet
    -- Agrupa para calcular edad y promedio por estudiante/carrera.
    GROUP BY
        e.carnet,
        e.nombre,
        c.carrera,
        c.nombre,
        e.fechanacimiento
) t
/*
* Filtra los estudiantes que tengan un promedio de nota mayor al promedio de 
* su carrera y una edad menor al promedio de edad de su carrera.
*/
WHERE t.promedio_nota > (
    /*
    * Promedio de promedios en la misma carrera.
    */
    SELECT AVG(t2.promedio_nota)
    FROM (
        /*
        * Para cada estudiante/carrera:
        * - promedio de nota
        */
        SELECT
            e2.carnet,
            c2.carrera,
            AVG(a2.nota) AS promedio_nota
        FROM estudiante e2
        JOIN inscripcion i2
            ON i2.estudiante_carnet = e2.carnet
        JOIN carrera c2
            ON c2.carrera = i2.carrera_carrera
        JOIN asignacion a2
            ON a2.estudiante_carnet = e2.carnet
        -- Agrupa para calcular el promedio por estudiante/carrera.
        GROUP BY
            e2.carnet,
            c2.carrera
    ) t2
    -- Filtra por la misma carrera.
    WHERE t2.carrera = t.carrera
)
/*
* Valida que la edad del estudiante sea menor al promedio de edad de su carrera.
*/
AND t.edad < (
    /*
    * Promedio de edades en la misma carrera.
    */
    SELECT AVG(t3.edad)
    FROM (
        /*
        * Para cada estudiante/carrera:
        * - edad en años completos
        */
        SELECT
            e3.carnet,
            c3.carrera,
            TRUNC(MONTHS_BETWEEN(SYSDATE, e3.fechanacimiento) / 12) AS edad
        FROM estudiante e3
        JOIN inscripcion i3
            ON i3.estudiante_carnet = e3.carnet
        JOIN carrera c3
            ON c3.carrera = i3.carrera_carrera
        -- Agrupa para calcular la edad por estudiante/carrera.
        GROUP BY
            e3.carnet,
            c3.carrera,
            e3.fechanacimiento
    ) t3
    -- Filtra por la misma carrera.
    WHERE t3.carrera = t.carrera
);