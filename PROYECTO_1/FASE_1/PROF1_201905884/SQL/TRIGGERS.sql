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

-- TRIGGER PARA VALIDAR ZONA Y NOTA EN ASIGNACION PARA ACTUALIZAR
CREATE OR REPLACE TRIGGER ASIGNACION_VALIDAR_NOTA_ZONA
BEFORE UPDATE ON ASIGNACION
FOR EACH ROW
DECLARE
    v_zona_minima NUMBER(5,2);
    v_nota_aprobacion NUMBER(5,2);
    v_creditos NUMBER(3);
BEGIN

    IF :NEW.ESTADO == 'APROBADO' THEN
        -- Obtener los valores de zona minima y nota de aprobación del pensum para el curso que se está asignando
        SELECT ZONA_MINIMA, NOTA_APROBACION, CREDITOS

        INTO v_zona_minima, v_nota_aprobacion, v_creditos
        FROM PENSUM WHERE 
            PENSUM.PLAN_ID_PLAN = :NEW.PENSUM_PLAN_ID_PLAN AND
            PENSUM.PLAN_CARRERA_ID_CARRERA = :NEW.PENSUM_PLAN_CARRERA_ID_CARRERA AND
            PENSUM.CURSO_ID_CURSO = :NEW.PENSUM_CURSO_ID_CURSO;

        -- Valida si la zona referida en la asignación es menor a la zona mínima requerida por el pensum
        IF :NEW.ZONA < v_zona_minima THEN
            RAISE_APPLICATION_ERROR(-20003, 'La zona del estudiante no cumple con la zona mínima requerida por el pensum para este curso.');
        END IF;

        -- Valida si la nota referida en la asignación es menor a la nota de aprobación requerida por el pensum
        IF :NEW.NOTA < v_nota_aprobacion THEN
            RAISE_APPLICATION_ERROR(-20003, 'La nota del estudiante no cumple con la nota de aprobación requerida por el pensum para este curso.');
        END IF;

        -- Set a CREDITOS ACUMULADOS en INSCRIPCION sumando los creditos del curso aprobado
        UPDATE INSCRIPCION
        SET CREDITOS_ACUMULADOS = v_creditos + CREDITOS_ACUMULADOS 
        WHERE ESTUDIANTE_ID_ESTUDIANTE = :NEW.ESTUDIANTE_ID_ESTUDIANTE
            AND CARRERA_ID_CARRERA = :NEW.PENSUM_PLAN_CARRERA_ID_CARRERA
            AND ESTADO = 'ACTIVA';
    
    ELSIF :NEW.ESTADO == 'REPROBADO' THEN
        -- Obtener los valores de zona minima y nota de aprobación del pensum para el curso que se está asignando
        SELECT ZONA_MINIMA, NOTA_APROBACION
        INTO v_zona_minima, v_nota_aprobacion
        FROM PENSUM WHERE 
            PENSUM.PLAN_ID_PLAN = :NEW.PENSUM_PLAN_ID_PLAN AND
            PENSUM.PLAN_CARRERA_ID_CARRERA = :NEW.PENSUM_PLAN_CARRERA_ID_CARRERA AND
            PENSUM.CURSO_ID_CURSO = :NEW.PENSUM_CURSO_ID_CURSO;

        -- Valida si la zona referida en la asignación es mayor o igual a la zona mínima requerida por el pensum
        IF :NEW.ZONA >= v_zona_minima  AND :NEW.NOTA >= v_nota_aprobacion THEN
            RAISE_APPLICATION_ERROR(-20003, 'No se puede marcar un curso como REPROBADO si la zona y nota del estudiante cumplen con los requisitos 
            de aprobación del pensum para este curso.');
        END IF;

    END IF;     
END;