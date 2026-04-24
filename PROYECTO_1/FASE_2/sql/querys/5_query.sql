/*
* Consulta 5:
* Dar el nombre de las parejas de estudiantes que, en todos sus cursos en común,
* sí fueron compañeros (misma sección, año y ciclo).

* Paso 1:
* Para cada pareja de estudiantes, identificar los cursos que han llevado en común.

* Paso 2:
* Validar que para cada curso en común, hayan sido compañeros (misma sección/año/ciclo).

* Paso 3:
* Mostrar el nombre de las parejas de estudiantes que cumplen la condición.
*/

/*
* Esta consulta se hace con el fin de mostrar el nombre de las parejas de estudiantes que,
* en todos sus cursos en común, sí fueron compañeros (misma sección, año y ciclo).
*/
SELECT
    e1.nombre AS estudiante1,
    e2.nombre AS estudiante2
FROM estudiante e1
JOIN estudiante e2
    /*
    * Filtra para comparar cada estudiante con los demás estudiantes, 
    * sin repetir parejas.

    * Por ejemplo, 
    * Tabla
    * estudiante
    * carnet | nombre
    * 1001   | Juan
    * 1002   | Maria
    * 1003   | Pedro

    * Parejas comparadas:
    * 1001 - 1002
    * 1001 - 1003
    * 1002 - 1003
    */
    ON e1.carnet < e2.carnet

/*
* Exists me permite validar que exista al menos un curso en común entre 
* los estudiantes comparados, y que para cada curso en común hayan 
* sido compañeros (misma sección/año/ciclo).
*/
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
    -- Valida que la asignación sea del estudiante comparado.
    WHERE a1.estudiante_carnet = e1.carnet
)
/*
* Not Exists me permite validar que no exista ningún curso en común 
* donde no hayan sido compañeros (misma sección/año/ciclo).
*/
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
    -- Valida que la asignación sea del estudiante comparado.
    WHERE a1.estudiante_carnet = e1.carnet
      -- Valida que no hayan sido compañeros en la misma sección/año/ciclo.
      AND NOT (
          a1.seccion_seccion = a2.seccion_seccion
      AND a1.seccion_anio = a2.seccion_anio
      AND a1.seccion_ciclo = a2.seccion_ciclo
      )
);