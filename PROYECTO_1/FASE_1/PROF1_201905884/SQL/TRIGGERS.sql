-- ************************************************************

-- ============================================================
-- TRIGGERS PARA VALIDAR RESTRICCIONES DE NEGOCIO
-- ============================================================

-- ============================================================
-- Tabla:   INSCRIPCION (BEFORE INSERT / BEFORE UPDATE)
-- Lógica:  Contar inscripciones activas del estudiante. Si COUNT >= 2, lanzar error.
-- Tipo:    TRIGGER OBLIGATORIO
-- Razón:   CHECK no puede referenciar agregados (COUNT) sobre la misma tabla.
-- Descripción: Este trigger asegura que un estudiante no pueda tener más de dos inscripciones activas al mismo tiempo.
-- ============================================================

-- TRIGGER PARA INSERTAR INSCRIPCION
CREATE OR REPLACE TRIGGER INSCRIPCION_LIMIT_ACTIVAS_INS
BEFORE INSERT ON INSCRIPCION
FOR EACH ROW
DECLARE
    v_count NUMBER;
BEGIN
    -- Contar inscripciones activas del estudiante, excluyendo la fila que se está insertando o actualizando
    SELECT COUNT(*)
        INTO v_count
    FROM INSCRIPCION
        WHERE ESTUDIANTE_ID_ESTUDIANTE = :NEW.ESTUDIANTE_ID_ESTUDIANTE
            AND ESTADO = 'ACTIVA';

    -- Si el conteo es mayor o igual a 2, lanzar error
    IF v_count >= 2 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Un estudiante no puede tener más de dos inscripciones activas.');
    END IF;
END;
/

-- TRIGGER PARA ACTUALIZAR INSCRIPCION
CREATE OR REPLACE TRIGGER INSCRIPCION_LIMIT_ACTIVAS_UPD
BEFORE UPDATE ON INSCRIPCION
FOR EACH ROW
DECLARE
    v_count NUMBER;
BEGIN

    IF :NEW.ESTUDIANTE_ID_ESTUDIANTE != :OLD.ESTUDIANTE_ID_ESTUDIANTE THEN 
        RAISE_APPLICATION_ERROR(-20004, 'No se puede cambiar el estudiante de una inscripción. Para cambiar el estudiante, se debe crear una nueva inscripción para el nuevo estudiante.');
    END IF;

    IF :NEW.CARRERA_ID_CARRERA != :OLD.CARRERA_ID_CARRERA THEN 
        RAISE_APPLICATION_ERROR(-20005, 'No se puede cambiar la carrera de una inscripción. Para cambiar la carrera, se debe crear una nueva inscripción para la nueva carrera.');
    END IF;

    IF :NEW.ESTADO = 'ACTIVA' AND :OLD.ESTADO = 'CERRADA' THEN 
        -- Si se está intentando reactivar una inscripción cerrada, contar inscripciones activas del estudiante, excluyendo la fila que se está actualizando
        SELECT COUNT(*)
            INTO v_count
        FROM INSCRIPCION
            WHERE ESTUDIANTE_ID_ESTUDIANTE = :NEW.ESTUDIANTE_ID_ESTUDIANTE
                AND ESTADO = 'ACTIVA';

        -- Si el conteo es mayor o igual a 2, lanzar error
        IF v_count >= 2 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Un estudiante no puede tener más de dos inscripciones activas.');
        END IF;
    END IF;
END;
/

-- ============================================================
-- Tabla:   ASIGNACION (TRIGGER)
-- Lógica:  Para cada asignación, verificar que la zona y nota sean suficientes para
--           aprobar el curso según el pensum. Si no, lanzar error.
-- Tipo:    TRIGGER OBLIGATORIO
-- Razón:   CHECK no puede referenciar agregados (SELECT) sobre la misma tabla.
-- Descripción: Esta restricción asegura que un estudiante solo pueda ser asignado a una sección
--              si cumple con los requisitos de zona y nota establecidos en el pensum para ese curso.
-- Para la aprobación de un curso requiere que:
-- ZONA >= PENSUM.ZONA_MINIMA
-- NOTA >= PENSUM.NOTA_APROBACION
-- ============================================================

-- FUNCION PARA VALIDAR PRERREQUISITOS, EN CONJUNTO CON EL TRIGGER DE ASIGNACION
-- EL CUAL CUENTA EL NUMERO DE PRERREQUISITOS DEL CURSO QUE NO HAN SIDO APROBADOS POR EL ESTUDIANTE
CREATE OR REPLACE FUNCTION FN_CUMPLE_REQUISITOS (
    P_PENSUM_PLAN_ID_PLAN            IN NUMBER,
    P_PENSUM_PLAN_CARRERA_ID_CARRERA IN NUMBER,
    P_PENSUM_CURSO_ID_CURSO          IN NUMBER,
    P_ESTUDIANTE_ID_ESTUDIANTE       IN NUMBER
) RETURN NUMBER IS
    v_count NUMBER;
BEGIN
    SELECT COUNT(*)
    INTO v_count
    FROM PRERREQUISITO p
    LEFT JOIN ASIGNACION a ON 
        p.PENSUM_PLAN_ID_PLAN = a.PENSUM_PLAN_ID_PLAN AND 
        p.PENSUM_PLAN_CARRERA_ID_CARRERA = a.PENSUM_PLAN_CARRERA_ID_CARRERA AND
        p.CURSO_ID_CURSO = a.PENSUM_CURSO_ID_CURSO AND 
        a.ESTUDIANTE_ID_ESTUDIANTE = P_ESTUDIANTE_ID_ESTUDIANTE AND 
        a.ESTADO = 'APROBADO'
    WHERE p.PENSUM_PLAN_ID_PLAN = P_PENSUM_PLAN_ID_PLAN
      AND p.PENSUM_PLAN_CARRERA_ID_CARRERA = P_PENSUM_PLAN_CARRERA_ID_CARRERA
      AND p.PENSUM_CURSO_ID_CURSO = P_PENSUM_CURSO_ID_CURSO
      AND a.ESTUDIANTE_ID_ESTUDIANTE IS NULL;

    RETURN v_count;
END;
/

-- FUNCION PARA VALIDAR PRERREQUISITOS DE CREDITOS, EN CONJUNTO CON EL TRIGGER DE ASIGNACION
CREATE OR REPLACE FUNCTION FN_CUMPLE_REQUISITOS_CREDITOS (
    P_PENSUM_PLAN_ID_PLAN            IN NUMBER,
    P_PENSUM_PLAN_CARRERA_ID_CARRERA IN NUMBER,
    P_PENSUM_CURSO_ID_CURSO          IN NUMBER,
    P_ESTUDIANTE_ID_ESTUDIANTE       IN NUMBER
) RETURN NUMBER IS
    v_count NUMBER;
BEGIN

    -- Se obtiene el numero de creditos acumulados del estudiante en la carrera, de la TABLA INSCRIPCION
    -- Y se compara con el numero de creditos requeridos por el pensum para llevar el curso, de la TABLA PENSUM
    SELECT COUNT(*)
    INTO v_count
    FROM PENSUM p
    JOIN INSCRIPCION i ON
        i.ESTUDIANTE_ID_ESTUDIANTE = P_ESTUDIANTE_ID_ESTUDIANTE AND
        i.CARRERA_ID_CARRERA = P_PENSUM_PLAN_CARRERA_ID_CARRERA AND
        p.PLAN_ID_PLAN = P_PENSUM_PLAN_ID_PLAN AND
        p.PLAN_CARRERA_ID_CARRERA = P_PENSUM_PLAN_CARRERA_ID_CARRERA AND
        p.CURSO_ID_CURSO = P_PENSUM_CURSO_ID_CURSO AND
        i.ESTADO = 'ACTIVA'
    WHERE p.PLAN_ID_PLAN = P_PENSUM_PLAN_ID_PLAN
      AND p.PLAN_CARRERA_ID_CARRERA = P_PENSUM_PLAN_CARRERA_ID_CARRERA
      AND p.CURSO_ID_CURSO = P_PENSUM_CURSO_ID_CURSO
      AND i.CREDITOS_ACUMULADOS < p.PREREQUISITO_CREDITOS;

    RETURN v_count;
END;
/

-- TRIGGER PARA VALIDAR ZONA Y NOTA EN ASIGNACION PARA INSERTAR
CREATE OR REPLACE TRIGGER ASIGNACION_VALIDAR_NOTA_ZONA_INS
BEFORE INSERT ON ASIGNACION
FOR EACH ROW
DECLARE
    v_count NUMBER;
BEGIN
    -- Obtener los valores de zona minima y nota de aprobación del pensum para el curso que se está asignando
    IF :NEW.ESTADO != 'CURSANDO' THEN
        RAISE_APPLICATION_ERROR(-20003, 'No se puede asignar un curso con estado diferente a CURSANDO. 
        Para asignar un curso con estado APROBADO o REPROBADO, primero se debe asignar el curso con 
        estado CURSANDO y luego actualizar el estado a APROBADO o REPROBADO.');
    END IF;

    -- Logica para los prerrequisitos, se cuenta el numero de prerrequisitos del curso que no han sido aprobados por el estudiante
    v_count := FN_CUMPLE_REQUISITOS(
        :NEW.PENSUM_PLAN_ID_PLAN,
        :NEW.PENSUM_PLAN_CARRERA_ID_CARRERA,
        :NEW.PENSUM_CURSO_ID_CURSO,
        :NEW.ESTUDIANTE_ID_ESTUDIANTE
    );

    -- Si el conteo es mayor a 0, significa que hay prerrequisitos no cumplidos, lanzar error
    IF v_count > 0 THEN
        RAISE_APPLICATION_ERROR(-20002, 'El estudiante no cumple con todos los prerrequisitos para este curso.');
    END IF;

    -- Logica para los prerrequisitos de creditos, se cuenta el numero de prerrequisitos de creditos del curso que no han sido aprobados por el estudiante
    v_count := FN_CUMPLE_REQUISITOS_CREDITOS(
        :NEW.PENSUM_PLAN_ID_PLAN,
        :NEW.PENSUM_PLAN_CARRERA_ID_CARRERA,
        :NEW.PENSUM_CURSO_ID_CURSO,
        :NEW.ESTUDIANTE_ID_ESTUDIANTE
    );

    -- Si el conteo es mayor a 0, significa que faltan creditos para poder llevar el curso, lanzar error
    IF v_count > 0 THEN
        RAISE_APPLICATION_ERROR(-20006, 'El estudiante no cumple con el número de créditos necesario para este curso.');
    END IF;

END;
/

-- FUNCION PARA VALIDAR LA ZONA Y NOTA EN ASIGNACION PARA ACTUALIZAR
CREATE OR REPLACE FUNCTION FN_VALIDAR_NOTA_ZONA (
    P_PLAN_ID_PLAN            IN NUMBER,
    P_CARRERA_ID_CARRERA      IN NUMBER,
    P_CURSO_ID_CURSO          IN NUMBER,
    P_ZONA                    IN NUMBER,
    P_NOTA                    IN NUMBER,
    P_ESTADO                  IN VARCHAR2
) RETURN NUMBER IS
    v_zona_minima      NUMBER;
    v_nota_aprobacion  NUMBER;
BEGIN
    SELECT ZONA_MINIMA, NOTA_APROBACION
    INTO v_zona_minima, v_nota_aprobacion
    FROM PENSUM
    WHERE PLAN_ID_PLAN = P_PLAN_ID_PLAN
      AND PLAN_CARRERA_ID_CARRERA = P_CARRERA_ID_CARRERA
      AND CURSO_ID_CURSO = P_CURSO_ID_CURSO;

    IF P_ESTADO = 'APROBADO' THEN
        IF P_ZONA < v_zona_minima OR P_NOTA < v_nota_aprobacion THEN
            RETURN 0;
        END IF;

    ELSIF P_ESTADO = 'REPROBADO' THEN
        IF P_ZONA >= v_zona_minima AND P_NOTA >= v_nota_aprobacion THEN
            RETURN 2;
        END IF;
    END IF;

    RETURN 1;
END;
/

-- FUNCION PARA SUMAR CREDITOS SI EL ESTUDIANTE APROBO EL CURSO
CREATE OR REPLACE FUNCTION FN_SUMAR_CREDITOS (
    P_PLAN_ID_PLAN            IN NUMBER,
    P_CARRERA_ID_CARRERA      IN NUMBER,
    P_CURSO_ID_CURSO          IN NUMBER
) RETURN NUMBER IS
    v_creditos NUMBER;
BEGIN
    SELECT CREDITOS
    INTO v_creditos
    FROM PENSUM
    WHERE PLAN_ID_PLAN = P_PLAN_ID_PLAN
      AND PLAN_CARRERA_ID_CARRERA = P_CARRERA_ID_CARRERA
      AND CURSO_ID_CURSO = P_CURSO_ID_CURSO;

    RETURN v_creditos;
END;
/

-- TRIGGER PARA VALIDAR ZONA Y NOTA EN ASIGNACION PARA ACTUALIZAR
CREATE OR REPLACE TRIGGER ASIGNACION_VALIDAR_NOTA_ZONA_UPD
BEFORE UPDATE ON ASIGNACION
FOR EACH ROW
DECLARE
    v_valido   NUMBER;
    v_creditos NUMBER;
BEGIN
    -- Solo validar si cambia el estado
    IF :NEW.ESTADO IN ('APROBADO', 'REPROBADO') THEN

        v_valido := FN_VALIDAR_NOTA_ZONA(
            :NEW.PENSUM_PLAN_ID_PLAN,
            :NEW.PENSUM_PLAN_CARRERA_ID_CARRERA,
            :NEW.PENSUM_CURSO_ID_CURSO,
            :NEW.ZONA,
            :NEW.NOTA,
            :NEW.ESTADO
        );

        IF v_valido = 0 THEN
            RAISE_APPLICATION_ERROR(-20003, 'La nota del estudiante no cumple con la nota de aprobación requerida por el pensum para este curso.');
        END IF;

        IF v_valido = 2 THEN
            RAISE_APPLICATION_ERROR(-20003, 'No se puede marcar un curso como REPROBADO si la zona y nota del estudiante cumplen con los requisitos 
            de aprobación del pensum para este curso.');
        END IF;

    END IF;

    -- SOLO SUMAR CRÉDITOS SI CAMBIA A APROBADO
    IF :OLD.ESTADO != 'APROBADO' AND :NEW.ESTADO = 'APROBADO' THEN

        v_creditos := FN_SUMAR_CREDITOS(
            :NEW.PENSUM_PLAN_ID_PLAN,
            :NEW.PENSUM_PLAN_CARRERA_ID_CARRERA,
            :NEW.PENSUM_CURSO_ID_CURSO
        );

        UPDATE INSCRIPCION
        SET CREDITOS_ACUMULADOS = CREDITOS_ACUMULADOS + v_creditos
        WHERE ESTUDIANTE_ID_ESTUDIANTE = :NEW.ESTUDIANTE_ID_ESTUDIANTE
          AND CARRERA_ID_CARRERA = :NEW.PENSUM_PLAN_CARRERA_ID_CARRERA
          AND ESTADO = 'ACTIVA';

    END IF;
END;
/

-- ============================================================
-- Tabla:   ASIGNACION (UPDATE) → INSCRIPCION
-- Evento:  Cada vez que un curso cambia a estado APROBADO.
-- Tipo:    COMPOUND TRIGGER (evita ORA-04091 mutating table)
-- Razón:   Un trigger FOR EACH ROW en ASIGNACION no puede hacer
--          SELECT sobre la misma tabla ASIGNACION. El compound
--          trigger resuelve esto en dos fases:
--            AFTER EACH ROW  → solo captura IDs, no consulta ASIGNACION
--            AFTER STATEMENT → procesa cuando la tabla ya no muta
-- Lógica (ejecutada en AFTER STATEMENT):
--   1. Obtiene el PLAN_ID_PLAN activo del estudiante en la carrera.
--   2. Determina si el período de vigencia del plan ha expirado
--      comparando (ANIO_FIN, CICLO_FIN) con el semestre actual.
--   3. Cuenta los cursos obligatorios (OBLIGATORIEDAD='S') del plan
--      que el estudiante aún NO ha aprobado. Se consideran aprobados
--      en TODOS los planes de la misma carrera (portabilidad).
--   4. Verifica créditos acumulados >= PLAN.CREDITOS_CIERRE.
--   5. Cierra la inscripción si:
--      - Créditos >= CREDITOS_CIERRE (siempre obligatorio), Y
--      - Sin obligatorios pendientes O el plan ya expiró.
-- Nota sobre CICLO: 1 = Semestre 1 (ene-jun), 8 = Semestre 2 (jul-dic).
-- ============================================================
CREATE OR REPLACE TRIGGER INSCRIPCION_VERIFICAR_CIERRE_CARRERA
FOR UPDATE ON ASIGNACION
COMPOUND TRIGGER

    -- Colección para guardar los pares (estudiante, carrera) a procesar
    TYPE t_rec IS RECORD (
        estudiante_id NUMBER,
        carrera_id    NUMBER
    );
    TYPE t_tab IS TABLE OF t_rec INDEX BY PLS_INTEGER;
    g_filas t_tab;
    g_idx   PLS_INTEGER := 0;

-- Fase 1: capturar IDs sin consultar ASIGNACION (tabla mutante)
AFTER EACH ROW IS
BEGIN
    IF :NEW.ESTADO = 'APROBADO' AND :OLD.ESTADO != 'APROBADO' THEN
        g_idx := g_idx + 1;
        g_filas(g_idx).estudiante_id := :NEW.ESTUDIANTE_ID_ESTUDIANTE;
        g_filas(g_idx).carrera_id    := :NEW.PENSUM_PLAN_CARRERA_ID_CARRERA;
    END IF;
END AFTER EACH ROW;

-- Fase 2: procesar al finalizar el statement (ASIGNACION ya no muta)
AFTER STATEMENT IS
    v_plan_id        NUMBER;
    v_carrera_id     NUMBER;
    v_pendientes     NUMBER;
    v_cred_cierre    NUMBER;
    v_cred_acum      NUMBER;
    v_anio_fin       NUMBER;
    v_ciclo_fin      NUMBER;
    v_anio_actual    NUMBER;
    v_ciclo_actual   NUMBER;
    v_plan_expirado  NUMBER;
BEGIN
    v_anio_actual  := TO_NUMBER(TO_CHAR(SYSDATE, 'YYYY'));
    v_ciclo_actual := CASE
                          WHEN TO_NUMBER(TO_CHAR(SYSDATE, 'MM')) <= 6 THEN 1
                          ELSE 8
                      END;

    FOR i IN 1 .. g_idx LOOP
        v_plan_expirado := 0;
        BEGIN
            -- 1. Plan activo del estudiante en la carrera
            SELECT PLAN_ID_PLAN, CARRERA_ID_CARRERA
            INTO v_plan_id, v_carrera_id
            FROM INSCRIPCION
            WHERE ESTUDIANTE_ID_ESTUDIANTE = g_filas(i).estudiante_id
              AND CARRERA_ID_CARRERA       = g_filas(i).carrera_id
              AND ESTADO = 'ACTIVA';

            -- 2. Vigencia del plan y créditos de cierre
            SELECT ANIO_FIN, CICLO_FIN, CREDITOS_CIERRE
            INTO v_anio_fin, v_ciclo_fin, v_cred_cierre
            FROM PLAN
            WHERE ID_PLAN            = v_plan_id
              AND CARRERA_ID_CARRERA = v_carrera_id;

            IF    v_anio_actual > v_anio_fin
               OR (v_anio_actual = v_anio_fin AND v_ciclo_actual > v_ciclo_fin)
            THEN
                v_plan_expirado := 1;
            END IF;

            -- 3. Cursos obligatorios pendientes (portabilidad entre planes)
            SELECT COUNT(*)
            INTO v_pendientes
            FROM PENSUM p
            WHERE p.PLAN_ID_PLAN            = v_plan_id
              AND p.PLAN_CARRERA_ID_CARRERA = v_carrera_id
              AND p.OBLIGATORIEDAD          = 'S'
              AND p.CURSO_ID_CURSO NOT IN (
                  SELECT DISTINCT a.PENSUM_CURSO_ID_CURSO
                  FROM ASIGNACION a
                  WHERE a.ESTUDIANTE_ID_ESTUDIANTE       = g_filas(i).estudiante_id
                    AND a.PENSUM_PLAN_CARRERA_ID_CARRERA = v_carrera_id
                    AND a.ESTADO                         = 'APROBADO'
              );

            -- 4. Créditos acumulados (ya actualizados por el BEFORE UPDATE trigger)
            SELECT CREDITOS_ACUMULADOS
            INTO v_cred_acum
            FROM INSCRIPCION
            WHERE ESTUDIANTE_ID_ESTUDIANTE = g_filas(i).estudiante_id
              AND CARRERA_ID_CARRERA       = v_carrera_id
              AND ESTADO = 'ACTIVA';

            -- 5. Condición de cierre
            IF v_cred_acum >= v_cred_cierre
               AND (v_pendientes = 0 OR v_plan_expirado = 1)
            THEN
                UPDATE INSCRIPCION
                SET ESTADO       = 'CERRADA',
                    FECHA_CIERRE = SYSDATE
                WHERE ESTUDIANTE_ID_ESTUDIANTE = g_filas(i).estudiante_id
                  AND CARRERA_ID_CARRERA       = v_carrera_id
                  AND ESTADO = 'ACTIVA';
            END IF;

        EXCEPTION
            WHEN NO_DATA_FOUND THEN NULL;
        END;
    END LOOP;

    -- Limpiar colección para el próximo statement
    g_idx := 0;
    g_filas.DELETE;
END AFTER STATEMENT;

END INSCRIPCION_VERIFICAR_CIERRE_CARRERA;
/

-- ============================================================
-- VIEW: V_COMPANEROS_TODOS_CURSOS
-- Descripción: Para cada estudiante que ha cerrado al menos una
--              carrera, muestra los nombres de los estudiantes
--              que llevaron TODOS Y CADA UNO de los mismos cursos
--              que llevó el cerrado (en cualquier sección, año o ciclo).
-- División relacional usando doble NOT EXISTS:
--   "no existe ningún curso del cerrado que el compañero
--    NO haya llevado en algún momento".
-- Uso:
--   SELECT * FROM V_COMPANEROS_TODOS_CURSOS;
--   SELECT * FROM V_COMPANEROS_TODOS_CURSOS
--     WHERE NOMBRE_ESTUDIANTE_CERRADO = 'Juan Pérez';
-- ============================================================
CREATE OR REPLACE VIEW V_COMPANEROS_TODOS_CURSOS AS
-- CTE: estudiantes que cerraron al menos una carrera
WITH CERRADOS AS (
    SELECT DISTINCT ESTUDIANTE_ID_ESTUDIANTE
    FROM INSCRIPCION
    WHERE ESTADO = 'CERRADA'
)
SELECT DISTINCT
    e_cerrado.ID_ESTUDIANTE AS ID_ESTUDIANTE_CERRADO,
    e_cerrado.NOMBRE        AS NOMBRE_ESTUDIANTE_CERRADO,
    e_comp.NOMBRE           AS NOMBRE_COMPANERO
FROM CERRADOS                          c
JOIN ESTUDIANTE e_cerrado ON e_cerrado.ID_ESTUDIANTE = c.ESTUDIANTE_ID_ESTUDIANTE
JOIN ESTUDIANTE e_comp    ON e_comp.ID_ESTUDIANTE   != c.ESTUDIANTE_ID_ESTUDIANTE
-- El cerrado debe tener al menos un curso (evitar verdad vacua)
WHERE EXISTS (
    SELECT 1
    FROM ASIGNACION
    WHERE ESTUDIANTE_ID_ESTUDIANTE = c.ESTUDIANTE_ID_ESTUDIANTE
)
-- División relacional: no debe existir ningún curso del cerrado
-- que el compañero NO haya llevado (en cualquier sección, año o ciclo)
AND NOT EXISTS (
    SELECT 1
    FROM ASIGNACION a_cerrado
    WHERE a_cerrado.ESTUDIANTE_ID_ESTUDIANTE = c.ESTUDIANTE_ID_ESTUDIANTE
      AND NOT EXISTS (
          SELECT 1
          FROM ASIGNACION a_comp
          WHERE a_comp.ESTUDIANTE_ID_ESTUDIANTE = e_comp.ID_ESTUDIANTE
            AND a_comp.SECCION_CURSO_ID_CURSO   = a_cerrado.SECCION_CURSO_ID_CURSO
      )
)
ORDER BY e_cerrado.NOMBRE, e_comp.NOMBRE;