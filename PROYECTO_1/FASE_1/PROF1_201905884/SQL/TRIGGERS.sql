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
CREATE OR REPLACE TRIGGER INSCRIPCION_LIMIT_ACTIVAS
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
CREATE OR REPLACE TRIGGER INSCRIPCION_LIMIT_ACTIVAS
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
CREATE OR REPLACE TRIGGER ASIGNACION_VALIDAR_NOTA_ZONA
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
CREATE OR REPLACE TRIGGER ASIGNACION_VALIDAR_NOTA_ZONA
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
-- Tabla:   ASIGNACION (AFTER UPDATE) → INSCRIPCION
-- Evento:  Cada vez que un curso cambia a estado APROBADO.
-- Lógica:
--   1. Obtiene el PLAN_ID_PLAN activo del estudiante en la carrera (de INSCRIPCION).
--   2. Cuenta los cursos obligatorios (OBLIGATORIEDAD='S') del plan actual que el
--      estudiante aún NO ha aprobado. Para la búsqueda de aprobados se consideran
--      TODOS los planes de la misma carrera (portabilidad entre planes anteriores).
--   3. Verifica que los créditos acumulados del estudiante >= PLAN.CREDITOS_CIERRE.
--   4. Si ambas condiciones se cumplen → cierra la inscripción:
--      INSCRIPCION.ESTADO = 'CERRADA', INSCRIPCION.FECHA_CIERRE = SYSDATE.
-- Tipo:    TRIGGER OBLIGATORIO
-- Razón:   CHECK no puede referenciar agregados de otras tablas.
-- ============================================================
CREATE OR REPLACE TRIGGER INSCRIPCION_VERIFICAR_CIERRE_CARRERA
AFTER UPDATE ON ASIGNACION
FOR EACH ROW
WHEN (NEW.ESTADO = 'APROBADO' AND OLD.ESTADO != 'APROBADO')
DECLARE
    v_plan_id             NUMBER;
    v_carrera_id          NUMBER;
    v_pendientes          NUMBER;
    v_creditos_cierre     NUMBER;
    v_creditos_acumulados NUMBER;
BEGIN
    -- 1. Obtener el plan actual del estudiante en la carrera
    SELECT PLAN_ID_PLAN, CARRERA_ID_CARRERA
    INTO v_plan_id, v_carrera_id
    FROM INSCRIPCION
    WHERE ESTUDIANTE_ID_ESTUDIANTE = :NEW.ESTUDIANTE_ID_ESTUDIANTE
      AND CARRERA_ID_CARRERA       = :NEW.PENSUM_PLAN_CARRERA_ID_CARRERA
      AND ESTADO = 'ACTIVA';

    -- 2. Contar cursos obligatorios del plan actual que el estudiante NO ha aprobado.
    --    Se buscan aprobados en cualquier plan de la misma carrera (portabilidad de planes).
    SELECT COUNT(*)
    INTO v_pendientes
    FROM PENSUM p
    WHERE p.PLAN_ID_PLAN            = v_plan_id
      AND p.PLAN_CARRERA_ID_CARRERA = v_carrera_id
      AND p.OBLIGATORIEDAD          = 'S'
      AND p.CURSO_ID_CURSO NOT IN (
          SELECT DISTINCT a.PENSUM_CURSO_ID_CURSO
          FROM ASIGNACION a
          WHERE a.ESTUDIANTE_ID_ESTUDIANTE       = :NEW.ESTUDIANTE_ID_ESTUDIANTE
            AND a.PENSUM_PLAN_CARRERA_ID_CARRERA = v_carrera_id
            AND a.ESTADO                         = 'APROBADO'
      );

    -- 3. Obtener créditos de cierre requeridos por el plan vigente
    SELECT CREDITOS_CIERRE
    INTO v_creditos_cierre
    FROM PLAN
    WHERE ID_PLAN            = v_plan_id
      AND CARRERA_ID_CARRERA = v_carrera_id;

    -- Leer créditos acumulados del estudiante (ya actualizados por el BEFORE UPDATE trigger)
    SELECT CREDITOS_ACUMULADOS
    INTO v_creditos_acumulados
    FROM INSCRIPCION
    WHERE ESTUDIANTE_ID_ESTUDIANTE = :NEW.ESTUDIANTE_ID_ESTUDIANTE
      AND CARRERA_ID_CARRERA       = v_carrera_id
      AND ESTADO = 'ACTIVA';

    -- 4. Si no quedan obligatorios pendientes y se alcanzaron los créditos → cerrar carrera
    IF v_pendientes = 0 AND v_creditos_acumulados >= v_creditos_cierre THEN
        UPDATE INSCRIPCION
        SET ESTADO       = 'CERRADA',
            FECHA_CIERRE = SYSDATE
        WHERE ESTUDIANTE_ID_ESTUDIANTE = :NEW.ESTUDIANTE_ID_ESTUDIANTE
          AND CARRERA_ID_CARRERA       = v_carrera_id
          AND ESTADO = 'ACTIVA';
    END IF;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        NULL; -- El estudiante no tiene inscripción activa en esta carrera, no hacer nada
END;
/

-- ============================================================
-- VIEW: V_COMPANEROS_TODOS_CURSOS
-- Descripción: Para cada estudiante que ha cerrado al menos una
--              carrera, muestra los nombres de los estudiantes
--              que estuvieron en la MISMA SECCIÓN en TODOS Y
--              CADA UNO de los cursos que llevó el cerrado.
-- División relacional usando doble NOT EXISTS:
--   "no existe ningún curso del cerrado en el que el compañero
--    NO haya estado en la misma sección".
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
-- donde el compañero NO haya estado en la misma sección
AND NOT EXISTS (
    SELECT 1
    FROM ASIGNACION a_cerrado
    WHERE a_cerrado.ESTUDIANTE_ID_ESTUDIANTE = c.ESTUDIANTE_ID_ESTUDIANTE
      AND NOT EXISTS (
          SELECT 1
          FROM ASIGNACION a_comp
          WHERE a_comp.ESTUDIANTE_ID_ESTUDIANTE = e_comp.ID_ESTUDIANTE
            AND a_comp.SECCION_ID_SECCION       = a_cerrado.SECCION_ID_SECCION
            AND a_comp.SECCION_CURSO_ID_CURSO   = a_cerrado.SECCION_CURSO_ID_CURSO
            AND a_comp.SECCION_ANIO             = a_cerrado.SECCION_ANIO
            AND a_comp.SECCION_CICLO            = a_cerrado.SECCION_CICLO
      )
)
ORDER BY e_cerrado.NOMBRE, e_comp.NOMBRE;