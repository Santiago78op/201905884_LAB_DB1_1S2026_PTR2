/*
*Dar el nombre de los estudiantes que tienen un promedio superior al promedio de los estudiantes de su carrera y su edad es menor que el promedio de edades de los estudiantes de su carrera.
*/
SELECT 
    t.estudiante,
    t.carrera,
    t.nombre_carrera,
    t.promedio_nota,
    t.edad
FROM (
    /*
    * Calcula, para cada estudiante en cada carrera, su promedio de notas y su edad.
    */
    SELECT
        e.carnet,
        e.nombre AS estudiante,
        c.carrera AS carrera,
        c.nombre AS nombre_carrera,
        AVG(a.nota) AS promedio_nota,
        TRUNC(MONTHS_BETWEEN(SYSDATE, e.fechanacimiento) / 12) AS edad
    FROM estudiante e
    JOIN inscripcion i
        ON i.estudiante_carnet = e.carnet
    JOIN carrera c
        ON c.carrera = i.carrera_carrera
    JOIN asignacion a
        ON a.estudiante_carnet = e.carnet
    GROUP BY
        e.carnet,
        e.nombre,
        c.carrera,
        c.nombre,
        e.fechanacimiento
) t
WHERE t.promedio_nota > (
    /*
    * Calcula el promedio de los promedios de los estudiantes de esa carrera.
    */
    SELECT AVG(t2.promedio_nota)
    FROM (
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
        GROUP BY
            e2.carnet,
            c2.carrera
    ) t2
    WHERE t2.carrera = t.carrera
)
AND t.edad < (
    /*
    * Calcula el promedio de edades de los estudiantes de esa carrera.
    */
    SELECT AVG(t3.edad)
    FROM (
        SELECT
            e3.carnet,
            c3.carrera,
            TRUNC(MONTHS_BETWEEN(SYSDATE, e3.fechanacimiento) / 12) AS edad
        FROM estudiante e3
        JOIN inscripcion i3
            ON i3.estudiante_carnet = e3.carnet
        JOIN carrera c3
            ON c3.carrera = i3.carrera_carrera
        GROUP BY
            e3.carnet,
            c3.carrera,
            e3.fechanacimiento
    ) t3
    WHERE t3.carrera = t.carrera
);