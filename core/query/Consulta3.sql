/*
* En base a un rango de fechas, mostrar cuantos registros de evaluaciones fueron 
* realizadas por tipo de trámite y tipo de licencia solicitada.
*/

-- Listar evaluaciones realizadas en el rango de fechas.
SELECT *
FROM CORRELATIVO
WHERE FECHA 
    BETWEEN TO_DATE('01/03/2023','DD/MM/YYYY') 
        AND TO_DATE('31/03/2023','DD/MM/YYYY');

-- A. Crear una tabla temporal llamafa EVALUACION
/*
* 1. El GROUP BY tiene la función de agrupar 
*    los resultados por tipo de trámite y tipo de licencia.
* 2. El WHERE filtra los registros para considerar solo aquellos 
*    que se encuentran dentro del rango de fechas especificado.
* 3. INNER JOIN se utiliza para conectar las tablas CORRELATIVO, EXAMEN y REGISTRO
* 4. 
*/
WITH EVALUACION AS (
    SELECT
        r.tipo_tramite,
        r.tipo_licencia,
        
        COUNT(e.id_examen) AS TOTAL_EVALUACIONES
    FROM CORRELATIVO C
    INNER JOIN EXAMEN E
        ON e.correlativo_id_correlativo = c.id_correlativo
    INNER JOIN REGISTRO R
        ON r.id_registro = e.registro_id_registro
    WHERE e.fecha 
        BETWEEN TO_DATE('01/03/2023','DD/MM/YYYY') 
            AND TO_DATE('31/03/2023','DD/MM/YYYY')
    GROUP BY 
        r.tipo_tramite, 
        r.tipo_licencia
)

/* 
* ORDER BY funciona para ordenar los resultados de la consulta final
* por tipo de trámite y tipo de licencia.

* Primero ordena por tipo de trámite y luego, dentro de cada tipo 
* de trámite, ordena por tipo de licencia.
*/
SELECT
    tipo_tramite,
    tipo_licencia,
    total_evaluaciones
FROM EVALUACION
ORDER BY
    tipo_tramite,
    tipo_licencia;