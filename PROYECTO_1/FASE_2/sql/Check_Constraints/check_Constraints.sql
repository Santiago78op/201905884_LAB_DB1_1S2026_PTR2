/* Para aprobar un curso es necesario tener una zona >= zona mínima y una nota >= nota de  aprobación, que corresponda al plan (pensum) vigente en la asignación (para cualesquiera de las carreras en que inscrito un estudiante), además de haber aprobado los prerrequisitos 
de créditos y los cursos prerrequisito del curso en ese plan (pensum) */

-- Función para validar el cumplimiento de los prerrequisitos de créditos
CREATE OR REPLACE FUNCTION FN_CUMPLE_PRERREQ_CRED (
    A_ESTUDIANTE_CARNET    IN NUMBER,
    A_SECCION_CURSO_CODIGO IN NUMBER,
    A_SECCION_SECCION      IN NUMBER,
    A_SECCION_ANIO         IN NUMBER,
    A_SECCION_CICLO        IN NUMBER
) RETURNS NUMBER IS
    v_credPrerrq NUMBER;
BEGIN

    -- Consulta para verificar si el estudiante cumple con el requisito de créditos
    SELECT COUNT(*)
    INTO v_credPrerrq
    FROM Inscripcion i
    JOIN Plan p ON
        p.Carrera_Carrera = i.Carrera_Carrera
    JOIN Pensum pe ON
        pe.Plan = Pensum_Plan AND
        pe.Plan_Carrera_Carrera = i.Carrera_Carrera
    JOIN Asignacion a ON
        
    WHERE i.Estudiante_Carnet = A_ESTUDIANTE_CARNET
        AND 
    

    RETURN v_credPrerrq; -- Retorna 1 si cumple con el requisito, 0 si no cumple
END;

-- TRIGGER General de validación de asignación de nota y zona para aprobar un curso, considerando los prerrequisitos de créditos y cursos.
CREATE OR REPLACE TRIGGER ASIGNACION_VALIDA_NOTA_ZONA_INS
BEFORE INSERT ON Asignacion
FOR EACH ROW
DECLARE
    v_credPrerrq NUMBER;
BEGIN

    -- Validar el requisito de créditos en INSERT
    v_credPrerrq := FN_CUMPLE_PRERREQ_CRED(
        :NEW.Estudiante_Carnet,
        :NEW.Seccion_Curso_Codigo,
        :NEW.Seccion_Seccion,
        :NEW.Seccion_Anio,
        :NEW.Seccion_Ciclo
    );

    IF v_credPrerrq = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'El estudiante no cumple con el requisito de créditos para esta asignación.');
    END IF;
END:
/

SELECT 
    e.Nombre,
    a.Estudiante_Carnet,
    AVG(a.Nota) AS Promedio_Nota
FROM Asignacion a
JOIN Estudiante e ON
    e.Carnet = a.Estudiante_Carnet
JOIN Inscripcion i ON
    i.Estudiante_Carnet = e.Carnet and
    i.Carrera_Carrera = 9
WHERE a.Estudiante_Carnet = 201905884
GROUP BY a.Estudiante_Carnet, e.Nombre;