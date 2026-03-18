/*
 * Listar las preguntas con mayores aciertos en base a un rango de fechas.
 */

/*
A. Crear una tabla temporal llamada CON_ACIERTOS

* 1. El GROUP BY tiene la función de agrupar los resultados por pregunta, respuesta correcta y ID de pregunta.
* 2. El WHERE filtra los registros para considerar solo aquellos que se encuentran dentro del rango de fechas especificado y donde la respuesta del usuario coincide con la respuesta correcta.
* 3. INNER JOIN se utiliza para conectar las tablas PREGUNTAS, RESPUESTA_USUARIO, EXAMEN y CORRELATIVO. 
* 4. COUNT se utiliza para contar el número de aciertos por pregunta.
*/
WITH CON_ACIERTOS AS (
    SELECT
        p.id_pregunta,
        p.pregunta_texto,
        p.respuesta                            AS RESPUESTA_CORRECTA,
        CASE 
            WHEN p.respuesta = 1 
                THEN p.res1
            WHEN p.respuesta = 2 
                THEN p.res2
            WHEN p.respuesta = 3
                THEN p.res3
            WHEN p.respuesta = 4 
                THEN p.res4
            ELSE 'Respuesta no válida'
        END AS RESPUESTA_CORRECTA_TEXTO,
        COUNT(ru.examen_id_examen)             AS TOTAL_ACIERTOS
    FROM PREGUNTAS P
    INNER JOIN RESPUESTA_USUARIO RU
        ON ru.pregunta_id_pregunta = p.id_pregunta
    INNER JOIN EXAMEN E
        ON e.id_examen = ru.examen_id_examen
    INNER JOIN CORRELATIVO C
        ON c.id_correlativo = e.correlativo_id_correlativo
    WHERE c.fecha 
        BETWEEN TO_DATE('01/03/2023','DD/MM/YYYY') 
            AND TO_DATE('31/03/2023','DD/MM/YYYY')
    GROUP BY
        p.id_pregunta,
        p.pregunta_texto,
        p.respuesta,
        p.res1,
        p.res2,
        p.res3,
        p.res4
)

/*
* ORDER BY funciona para ordenar los resultados de la consulta final 
* por total de aciertos en orden descendente, 
* mostrando primero las preguntas con más aciertos.
*/
SELECT
    id_pregunta,
    pregunta_texto,
    respuesta_correcta,
    respuesta_correcta_texto,
    total_aciertos
FROM CON_ACIERTOS
ORDER BY 
    total_aciertos DESC;