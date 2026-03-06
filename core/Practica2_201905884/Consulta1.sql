/*
* Query Numero 1:

* Listado de todas las evaluaciones realizadas en el día. La consulta debe recibir de parámetro la fecha a 
* consultar y como resultado debe mostrar todos los datos generales del Evaluado, así como también las 
* notas obtenidas y si fue aprobado o reprobado

? Restriccion si aplica:
* Considerar como datos Generales todos los atributos del registro de la persona a ser evaluada. Para considerar 
* APRBADO una evaluación deberá ganar con 70 puntos teóricos y prácticos.
*/

-- Listar evaluaciones realizadas en el dia.
SELECT *
FROM CORRELATIVO
WHERE FECHA = TO_DATE('13/03/2023','DD/MM/YYYY');

-- Listar los datos generales del Evaluado
SELECT c.id_correlativo,
    c.fecha,
    e.registro_id_escuela,
    e.registro_id_centro,
    e.registro_municipio_id_municipio,
    e.registro_municipio_departamento_id_departamento,
    e.registro_id_registro,
    r.tipo_tramite,
    r.tipo_licencia,
    r.nombre_completo,
    r.genero
FROM CORRELATIVO C
INNER JOIN EXAMEN E
    ON e.correlativo_id_correlativo = c.id_correlativo
INNER JOIN REGISTRO R
    ON r.id_registro = e.registro_id_registro
    WHERE c.fecha = TO_DATE('13/03/2023','DD/MM/YYYY');

/*
* Para considerar APRBADO una evaluación deberá ganar 
* con 70 puntos teóricos y prácticos.
*/
-- A. Creo una tabla temporal llamada TEMP_NOTAS durante la consulta
--      1.  Logica de preguntas teoricas y practica
--      2.  Logica de union de tablas
--      3.  Logica de parametro fecha
--      4.  Logica de APROVADA
-- B. Realizo la consulta general del Query
-- C. Primero se calcula la tabla Notas y
--    Posterior se realiza la consulta
/*
*1.
* Por cada fila:
*   → ¿Es pregunta TEORICA y la respuesta es correcta?
*       SÍ  → vale 4 puntos
*       NO  → vale 0 puntos
* Todos los valores que aplique se guardan en TEMP_NOTAS_TEO
*
* Por cada fila:
*   → ¿Es pregunta PRACTICA, es correcta?
*       SÍ  → vale en un rango de 0 a 10 puntos
*       NO  → vale 0 puntos
* Todos los valores que apliquen se guardan en TEMP_NOTAS_PRAC

*2.
* Para conectar dos mas tablas por una columna en comun.
*   → Solo aplica para las filas que existan en ambas tablas,
*     depende del campo solicitado.

*3.
* Para filtrar solo los registros con un parametro especifico 
*   → Aplica para comparar parametro con campo fecha.

*4.
* Para poder sumar sin que summarize todas las filas de la tabla
*   → "Suma por separado para cada combinación de
*       ID_CORRELATIVO + FECHA + ID_EXAMEN".
*/

-- TABLA TEMPORAL NOTAS
WITH NOTAS AS
(
    SELECT 
        c.id_correlativo,
        c.fecha,
        e.id_examen, 
        e.registro_id_escuela,
        e.registro_id_centro,
        e.registro_municipio_id_municipio,
        e.registro_municipio_departamento_id_departamento,
        e.registro_id_registro,
        r.tipo_tramite,
        r.tipo_licencia,
        r.nombre_completo,
        r.genero,
        
        SUM
        (
            CASE 
                WHEN ru.respuesta = p.respuesta
                THEN 4 
                ELSE 0 
            END
        ) AS TEMP_NOTAS_TEO,
        
        SUM
        (
            CASE 
                WHEN rpu.pregunta_practico_id_pregunta_practico = p.respuesta
                THEN rpu.nota
                ELSE 0
            END
        ) AS TEMP_NOTAS_PRAC
        
    FROM CORRELATIVO C
    INNER JOIN EXAMEN E
        ON e.correlativo_id_correlativo = c.id_correlativo
    INNER JOIN REGISTRO R
        ON r.id_registro = e.registro_id_registro
    INNER JOIN RESPUESTA_USUARIO RU
        ON ru.examen_id_examen = e.id_examen
    INNER JOIN PREGUNTAS P
        ON p.id_pregunta = ru.pregunta_id_pregunta
    INNER JOIN RESPUESTA_PRACTICO_USUARIO RPU
        ON rpu.examen_id_examen = e.id_examen
    INNER JOIN PREGUNTAS_PRACTICO PP
        ON pp.id_pregunta_practico = rpu.pregunta_practico_id_pregunta_practico
    WHERE 
        c.fecha = TO_DATE('13/03/2023','DD/MM/YYYY')
    GROUP BY
        c.id_correlativo,
        c.fecha,
        e.id_examen, 
        e.registro_id_escuela,
        e.registro_id_centro,
        e.registro_municipio_id_municipio,
        e.registro_municipio_departamento_id_departamento,
        e.registro_id_registro,
        r.tipo_tramite,
        r.tipo_licencia,
        r.nombre_completo,
        r.genero
)

-- CONSULTA 1
SELECT 
    id_correlativo,
    fecha,
    id_examen, 
    registro_id_escuela,
    registro_id_centro,
    registro_municipio_id_municipio,
    registro_municipio_departamento_id_departamento,
    registro_id_registro,
    tipo_tramite,
    tipo_licencia,
    nombre_completo,
    genero,
    temp_notas_teo,
    temp_notas_prac,
    
    CASE
        WHEN TEMP_NOTAS_TEO  >= 70 AND
             TEMP_NOTAS_PRAC >= 70
        THEN 'APROBADO'
        ELSE 'REPROBADO'
    END AS RESULTADO
FROM NOTAS;

-- Fallo la consulta, tengo problemas en las filas de respuestas examene
/*
INNER JOIN RESPUESTA_USUARIO RU
    ON ru.examen_id_examen = e.id_examen       -- N filas

INNER JOIN RESPUESTA_PRACTICO_USUARIO RPU
    ON rpu.examen_id_examen = e.id_examen      -- M filas
*/

-- Query Correcta

-- Tengo que separa valores
WITH NOTAS_TEO AS (
    SELECT
        ru.examen_id_examen,
        
        SUM
        (
            CASE WHEN ru.respuesta = p.respuesta 
                THEN 4 
                ELSE 0 
            END
        ) AS TEMP_NOTAS_TEO
    FROM RESPUESTA_USUARIO RU
    INNER JOIN PREGUNTAS P
        ON p.id_pregunta = ru.pregunta_id_pregunta
    GROUP BY 
        ru.examen_id_examen
),

NOTAS_PRAC AS (
    SELECT
        rpu.examen_id_examen,
        
        SUM
        (
            rpu.nota 
        ) AS TEMP_NOTAS_PRAC
    FROM RESPUESTA_PRACTICO_USUARIO RPU
    INNER JOIN PREGUNTAS_PRACTICO PP
        ON pp.id_pregunta_practico = rpu.pregunta_practico_id_pregunta_practico
    GROUP BY rpu.examen_id_examen
),

NOTAS AS (
    SELECT
        c.id_correlativo,
        c.fecha,
        e.id_examen,
        e.registro_id_escuela,
        e.registro_id_centro,
        e.registro_municipio_id_municipio,
        e.registro_municipio_departamento_id_departamento,
        e.registro_id_registro,
        r.tipo_tramite,
        r.tipo_licencia,
        r.nombre_completo,
        r.genero,
        nt.TEMP_NOTAS_TEO,
        np.TEMP_NOTAS_PRAC
    FROM CORRELATIVO C
    INNER JOIN EXAMEN E
        ON e.correlativo_id_correlativo = c.id_correlativo
    INNER JOIN REGISTRO R
        ON r.id_registro = e.registro_id_registro
    INNER JOIN NOTAS_TEO NT
        ON nt.examen_id_examen = e.id_examen
    INNER JOIN NOTAS_PRAC NP
        ON np.examen_id_examen = e.id_examen
    WHERE c.fecha = TO_DATE('13/03/2023', 'DD/MM/YYYY')
)

SELECT
    id_correlativo,
    fecha,
    id_examen,
    registro_id_escuela,
    registro_id_centro,
    registro_municipio_id_municipio,
    registro_municipio_departamento_id_departamento,
    registro_id_registro,
    tipo_tramite,
    tipo_licencia,
    nombre_completo,
    genero,
    temp_notas_teo,
    temp_notas_prac,
    CASE
        WHEN TEMP_NOTAS_TEO  >= 70
         AND TEMP_NOTAS_PRAC >= 70
        THEN 'APROBADO'
        ELSE 'REPROBADO'
    END AS RESULTADO
FROM NOTAS;
    