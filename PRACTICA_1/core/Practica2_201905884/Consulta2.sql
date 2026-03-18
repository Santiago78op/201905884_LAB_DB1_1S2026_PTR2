/*
* Query Numero 2:

* En base a un rango de fechas, mostrar las notas de las evaluaciones 
* considerando solo las evaluaciones aprobadas.
*/

-- Listar evaluaciones realizadas en el rango de fechas.
SELECT *
FROM CORRELATIVO
WHERE FECHA 
    BETWEEN TO_DATE('01/03/2023','DD/MM/YYYY') 
        AND TO_DATE('31/03/2023','DD/MM/YYYY');

-- Listar notas las notas de las evaluaciones, con el rango de fechas.
WITH NOTAS_TEO_APROBADAS AS (
    SELECT
        ru.examen_id_examen,
        
        SUM
        (
            CASE WHEN ru.respuesta = p.respuesta 
                THEN 4 
                ELSE 0 
            END
        ) AS TEMP_NOTAS_APROBADAS_TEO
    FROM RESPUESTA_USUARIO RU
    INNER JOIN PREGUNTAS P
        ON p.id_pregunta = ru.pregunta_id_pregunta
    GROUP BY 
        ru.examen_id_examen
),

NOTAS_PRAC_APROBADAS AS (
    SELECT
        rpu.examen_id_examen,
        
        SUM
        (
            rpu.nota 
        ) AS TEMP_NOTAS_APROBADAS_PRAC
    FROM RESPUESTA_PRACTICO_USUARIO RPU
    INNER JOIN PREGUNTAS_PRACTICO PP
        ON pp.id_pregunta_practico = rpu.pregunta_practico_id_pregunta_practico
    GROUP BY rpu.examen_id_examen
),

NOTAS_APROBADAS AS (
    SELECT
        c.id_correlativo,
        c.fecha,
        e.id_examen,
        r.nombre_completo,
        nt.TEMP_NOTAS_APROBADAS_TEO,
        np.TEMP_NOTAS_APROBADAS_PRAC
    FROM CORRELATIVO C
    INNER JOIN EXAMEN E
        ON e.correlativo_id_correlativo = c.id_correlativo
    INNER JOIN REGISTRO R
        ON r.id_registro = e.registro_id_registro
    INNER JOIN NOTAS_TEO_APROBADAS NT
        ON nt.examen_id_examen = e.id_examen
    INNER JOIN NOTAS_PRAC_APROBADAS NP
        ON np.examen_id_examen = e.id_examen
    WHERE C.fecha 
    BETWEEN TO_DATE('01/03/2023','DD/MM/YYYY') 
        AND TO_DATE('31/03/2023','DD/MM/YYYY')
    AND nt.TEMP_NOTAS_APROBADAS_TEO  >= 70
    AND np.TEMP_NOTAS_APROBADAS_PRAC >= 70
)

SELECT
    id_correlativo,
    fecha,
    id_examen,
    nombre_completo,
    temp_notas_aprobadas_teo,
    temp_notas_aprobadas_prac,
    'APROBADO' AS RESULTADO
FROM NOTAS_APROBADAS;