-- Generado por Oracle SQL Developer Data Modeler 24.3.1.351.0831
--   en:        2026-04-21 10:45:09 CST
--   sitio:      Oracle Database 21c
--   tipo:      Oracle Database 21c



-- predefined type, no DDL - MDSYS.SDO_GEOMETRY

-- predefined type, no DDL - XMLTYPE

CREATE TABLE Asignacion 
    ( 
     Estudiante_Carnet         NUMBER (10)  NOT NULL , 
     Seccion_Curso_CodigoCurso NUMBER (10)  NOT NULL , 
     Seccion_Seccion           VARCHAR2 (2)  NOT NULL , 
     Seccion_Anio              NUMBER (4)  NOT NULL , 
     Seccion_Ciclo             VARCHAR2 (10)  NOT NULL , 
     Zona                      NUMBER (3)  NOT NULL , 
     Nota                      NUMBER (3)  NOT NULL 
    ) 
;

ALTER TABLE Asignacion 
    ADD CONSTRAINT Asignacion_PK PRIMARY KEY ( Estudiante_Carnet, Seccion_Curso_CodigoCurso, Seccion_Seccion, Seccion_Anio, Seccion_Ciclo ) ;

COMMENT ON COLUMN Asignacion.Zona IS 'Zona del Curso asignado' 
;

COMMENT ON COLUMN Asignacion.Nota IS 'Nota obtenida en el curso asignado' 
;

CREATE TABLE Carrera 
    ( 
     Carrera NUMBER (10)  NOT NULL , 
     Nombre  VARCHAR2 (50)  NOT NULL 
    ) 
;

COMMENT ON COLUMN Carrera.Carrera IS 'iID de Carrera como llave primaria como 9 o 35' 
;

COMMENT ON COLUMN Carrera.Nombre IS 'Nombre asignado a la carrera como "Ingenieria en Ciencias y Sistemas"' 
;

ALTER TABLE Carrera 
    ADD CONSTRAINT Carrera_PK PRIMARY KEY ( Carrera ) ;

CREATE TABLE Catedratico 
    ( 
     Catedratico   NUMBER (10)  NOT NULL , 
     Nombre        VARCHAR2 (50)  NOT NULL , 
     SueldoMensual NUMBER (10,2)  NOT NULL 
    ) 
;

COMMENT ON COLUMN Catedratico.Catedratico IS 'ID del catedratico' 
;

COMMENT ON COLUMN Catedratico.Nombre IS 'Nombre del Catedratico' 
;

COMMENT ON COLUMN Catedratico.SueldoMensual IS 'Sueldo mensual del catedratico' 
;

ALTER TABLE Catedratico 
    ADD CONSTRAINT Catedratico_PK PRIMARY KEY ( Catedratico ) ;

CREATE TABLE Curso 
    ( 
     CodigoCurso NUMBER (10)  NOT NULL , 
     NombreCurso VARCHAR2 (50)  NOT NULL 
    ) 
;

COMMENT ON COLUMN Curso.CodigoCurso IS 'ID llave primaria del Curso 3378' 
;

COMMENT ON COLUMN Curso.NombreCurso IS 'Nombre del curso' 
;

ALTER TABLE Curso 
    ADD CONSTRAINT Curso_PK PRIMARY KEY ( CodigoCurso ) ;

CREATE TABLE Dia 
    ( 
     Dia       NUMBER (1)  NOT NULL , 
     NombreDia VARCHAR2 (50)  NOT NULL 
    ) 
;

COMMENT ON COLUMN Dia.Dia IS 'ID dias de la semana, llave primaria solo 7' 
;

COMMENT ON COLUMN Dia.NombreDia IS 'Nombre del dia de la semana' 
;

ALTER TABLE Dia 
    ADD CONSTRAINT Dia_PK PRIMARY KEY ( Dia ) ;

CREATE TABLE Estudiante 
    ( 
     Carnet          NUMBER (10)  NOT NULL , 
     Nombre          VARCHAR2 (50)  NOT NULL , 
     IngresoFamiliar NUMBER (10,2)  NOT NULL , 
     FechaNacimiento DATE  NOT NULL 
    ) 
;

COMMENT ON COLUMN Estudiante.Carnet IS 'ID del estudiante llave primaria, 201905884' 
;

COMMENT ON COLUMN Estudiante.Nombre IS 'Nombre del Estudiante' 
;

COMMENT ON COLUMN Estudiante.IngresoFamiliar IS 'Ingreso familiar de la familia del estudiante' 
;

COMMENT ON COLUMN Estudiante.FechaNacimiento IS 'Fecha de Nacimiento del estudiante' 
;

ALTER TABLE Estudiante 
    ADD CONSTRAINT Estudiante_PK PRIMARY KEY ( Carnet ) ;

CREATE TABLE Horario 
    ( 
     Seccion_Curso_CodigoCurso NUMBER (10)  NOT NULL , 
     Seccion_Seccion           VARCHAR2 (2)  NOT NULL , 
     Seccion_Anio              NUMBER (4)  NOT NULL , 
     Seccion_Ciclo             VARCHAR2 (10)  NOT NULL , 
     Periodo_Periodo           NUMBER (10)  NOT NULL , 
     Dia_Dia                   NUMBER (1)  NOT NULL , 
     Salon_Edificio            VARCHAR2 (10)  NOT NULL , 
     Salon_Salon               NUMBER (10)  NOT NULL 
    ) 
;

COMMENT ON COLUMN Horario.Seccion_Curso_CodigoCurso IS 'ID del Curso Asignado en el Horario' 
;

COMMENT ON COLUMN Horario.Seccion_Seccion IS 'ID del Seccion Asignado en el Horario' 
;

COMMENT ON COLUMN Horario.Seccion_Anio IS 'Año en el que se habilito ese horario' 
;

COMMENT ON COLUMN Horario.Periodo_Periodo IS 'Periodo del horario' 
;

COMMENT ON COLUMN Horario.Dia_Dia IS 'Dia del Horario' 
;

COMMENT ON COLUMN Horario.Salon_Salon IS 'Salon para impartir el horario' 
;

CREATE TABLE Inscripcion 
    ( 
     Carrera_Carrera   NUMBER (10)  NOT NULL , 
     Estudiante_Carnet NUMBER (10)  NOT NULL , 
     FechaInscripcion  DATE  NOT NULL 
    ) 
;

COMMENT ON COLUMN Inscripcion.Carrera_Carrera IS 'ID llave primaria de la Carrera, se junto con ID  Carnet, para llave compuesta Unica' 
;

COMMENT ON COLUMN Inscripcion.Estudiante_Carnet IS 'ID llave primaria de la Carnet, se junto con ID  Carrera, para llave compuesta Unica' 
;

COMMENT ON COLUMN Inscripcion.FechaInscripcion IS 'Fecha en la que se Inscribio el Estudiante a la Carrera' 
;

ALTER TABLE Inscripcion 
    ADD CONSTRAINT Inscripcion_PK PRIMARY KEY ( Carrera_Carrera, Estudiante_Carnet ) ;

CREATE TABLE Pensum 
    ( 
     Curso_CodigoCurso    NUMBER (10)  NOT NULL , 
     Plan_Plan            VARCHAR2 (30)  NOT NULL , 
     Plan_Carrera_Carrera NUMBER (10)  NOT NULL , 
     Obligatoriedad       NUMBER (1)  NOT NULL , 
     NumCreditos          NUMBER (3)  NOT NULL , 
     NotaAprobacion       NUMBER (3)  NOT NULL , 
     ZonaMinima           NUMBER (3)  NOT NULL , 
     CredPrerrequisitos   NUMBER (3)  NOT NULL 
    ) 
;

COMMENT ON COLUMN Pensum.Curso_CodigoCurso IS 'Codigo del curso referenciado al pensum' 
;

COMMENT ON COLUMN Pensum.Plan_Plan IS 'Plan en el que se  incorporo el pensum' 
;

COMMENT ON COLUMN Pensum.Plan_Carrera_Carrera IS 'Carrera del plan asignada al pensum' 
;

COMMENT ON COLUMN Pensum.Obligatoriedad IS 'Indica si es un curso obligatorio' 
;

COMMENT ON COLUMN Pensum.NumCreditos IS 'Numero de Creditos por el estudiante' 
;

COMMENT ON COLUMN Pensum.NotaAprobacion IS 'Nota de aprobación para ganar el curso' 
;

COMMENT ON COLUMN Pensum.ZonaMinima IS 'Zona minima para poder tomar el examen final y aprobar el curso.' 
;

COMMENT ON COLUMN Pensum.CredPrerrequisitos IS 'Numero de creditos necesarios para tomar el curso' 
;

ALTER TABLE Pensum 
    ADD CONSTRAINT Pensum_PK PRIMARY KEY ( Plan_Carrera_Carrera, Plan_Plan, Curso_CodigoCurso ) ;

CREATE TABLE Periodo 
    ( 
     Periodo       NUMBER (10)  NOT NULL , 
     HorarioInicio VARCHAR2 (5)  NOT NULL , 
     HorarioFinal  VARCHAR2 (5)  NOT NULL 
    ) 
;

COMMENT ON COLUMN Periodo.Periodo IS 'ID periodo, llave primaria' 
;

COMMENT ON COLUMN Periodo.HorarioInicio IS 'Hora de Inicio del Periodo de Clases' 
;

COMMENT ON COLUMN Periodo.HorarioFinal IS 'Hora Fin del periodo de clases' 
;

ALTER TABLE Periodo 
    ADD CONSTRAINT Periodo_PK PRIMARY KEY ( Periodo ) ;

CREATE TABLE Plan 
    ( 
     Plan                 VARCHAR2 (30)  NOT NULL , 
     Carrera_Carrera      NUMBER (10)  NOT NULL , 
     Nombre               VARCHAR2 (50)  NOT NULL , 
     AnioInicial          NUMBER (4)  NOT NULL , 
     CicloInicial         VARCHAR2 (20)  NOT NULL , 
     AnioFinal            NUMBER (4)  NOT NULL , 
     CicloFinal           VARCHAR2 (20)  NOT NULL , 
     NumeroCreditosCierre NUMBER (3)  NOT NULL 
    ) 
;

COMMENT ON COLUMN Plan.Plan IS 'El plan se identifica con el nombre del plan ejemplo DIARIO, MIXTO...' 
;

COMMENT ON COLUMN Plan.Carrera_Carrera IS 'Codigo de Carrera ID' 
;

COMMENT ON COLUMN Plan.Nombre IS 'Nombre del Plan, en su defecto tipo' 
;

COMMENT ON COLUMN Plan.AnioInicial IS 'Año en el cual se inicio el Plan' 
;

COMMENT ON COLUMN Plan.CicloInicial IS 'Ciclo en el cual se inicio el Plan de estudio' 
;

COMMENT ON COLUMN Plan.AnioFinal IS 'Año en el cual se Finalizo el Plan' 
;

COMMENT ON COLUMN Plan.CicloFinal IS 'Ciclo en el cual se dio fin al  Plan de estudio' 
;

COMMENT ON COLUMN Plan.NumeroCreditosCierre IS 'Numero de creditos con los que cerro el estudiante el plan de estudios para esa carrera' 
;

ALTER TABLE Plan 
    ADD CONSTRAINT Plan_PK PRIMARY KEY ( Plan, Carrera_Carrera ) ;

CREATE TABLE Prerreq 
    ( 
     Pensum_Carrera           NUMBER (10)  NOT NULL , 
     Pensum_Plan              VARCHAR2 (30)  NOT NULL , 
     Pensum_Curso_CodigoCurso NUMBER (10)  NOT NULL , 
     CursoPrerrequisito       NUMBER (10)  NOT NULL 
    ) 
;

COMMENT ON COLUMN Prerreq.Pensum_Carrera IS 'Carrera a la que pertenece el prerrequisito' 
;

COMMENT ON COLUMN Prerreq.Pensum_Plan IS 'plan a la que pertenece el prerrequisito' 
;

COMMENT ON COLUMN Prerreq.Pensum_Curso_CodigoCurso IS 'Curso  a la que pertenece el prerrequisito' 
;

COMMENT ON COLUMN Prerreq.CursoPrerrequisito IS 'ID del prerrequisto.' 
;

ALTER TABLE Prerreq 
    ADD CONSTRAINT Prerreq_PK PRIMARY KEY ( CursoPrerrequisito, Pensum_Curso_CodigoCurso, Pensum_Plan, Pensum_Carrera ) ;

CREATE TABLE Salon 
    ( 
     Edificio  VARCHAR2 (10)  NOT NULL , 
     Salon     NUMBER (10)  NOT NULL , 
     Capacidad NUMBER (3)  NOT NULL 
    ) 
;

COMMENT ON COLUMN Salon.Edificio IS 'ID del Edificio T13' 
;

COMMENT ON COLUMN Salon.Salon IS 'ID salon 113' 
;

COMMENT ON COLUMN Salon.Capacidad IS 'Capasidad de alumnos del salon' 
;

ALTER TABLE Salon 
    ADD CONSTRAINT Salon_PK PRIMARY KEY ( Salon, Edificio ) ;

CREATE TABLE Seccion 
    ( 
     Seccion                 VARCHAR2 (2)  NOT NULL , 
     Anio                    NUMBER (4)  NOT NULL , 
     Ciclo                   VARCHAR2 (10)  NOT NULL , 
     Curso_CodigoCurso       NUMBER (10)  NOT NULL , 
     Catedratico_Catedratico NUMBER (10)  NOT NULL 
    ) 
;

COMMENT ON COLUMN Seccion.Seccion IS 'ID seccion referenciada' 
;

COMMENT ON COLUMN Seccion.Anio IS 'Anio en el que estuvo vigente esta seccion' 
;

COMMENT ON COLUMN Seccion.Ciclo IS 'Ciclo en la carrera que se dio esa seccion' 
;

COMMENT ON COLUMN Seccion.Curso_CodigoCurso IS 'Codigo referenciado a esa seccion' 
;

COMMENT ON COLUMN Seccion.Catedratico_Catedratico IS 'Catedratico asignado a la seccion' 
;

ALTER TABLE Seccion 
    ADD CONSTRAINT Seccion_PK PRIMARY KEY ( Curso_CodigoCurso, Anio, Seccion, Ciclo ) ;

ALTER TABLE Asignacion 
    ADD CONSTRAINT Asignacion_Estudiante_FK FOREIGN KEY 
    ( 
     Estudiante_Carnet
    ) 
    REFERENCES Estudiante 
    ( 
     Carnet
    ) 
    ON DELETE CASCADE 
;

ALTER TABLE Asignacion 
    ADD CONSTRAINT Asignacion_Seccion_FK FOREIGN KEY 
    ( 
     Seccion_Curso_CodigoCurso,
     Seccion_Anio,
     Seccion_Seccion,
     Seccion_Ciclo
    ) 
    REFERENCES Seccion 
    ( 
     Curso_CodigoCurso,
     Anio,
     Seccion,
     Ciclo
    ) 
    ON DELETE CASCADE 
;

ALTER TABLE Horario 
    ADD CONSTRAINT Horario_Dia_FK FOREIGN KEY 
    ( 
     Dia_Dia
    ) 
    REFERENCES Dia 
    ( 
     Dia
    ) 
    ON DELETE CASCADE 
;

ALTER TABLE Horario 
    ADD CONSTRAINT Horario_Periodo_FK FOREIGN KEY 
    ( 
     Periodo_Periodo
    ) 
    REFERENCES Periodo 
    ( 
     Periodo
    ) 
    ON DELETE CASCADE 
;

ALTER TABLE Horario 
    ADD CONSTRAINT Horario_Salon_FK FOREIGN KEY 
    ( 
     Salon_Salon,
     Salon_Edificio
    ) 
    REFERENCES Salon 
    ( 
     Salon,
     Edificio
    ) 
    ON DELETE CASCADE 
;

ALTER TABLE Horario 
    ADD CONSTRAINT Horario_Seccion_FK FOREIGN KEY 
    ( 
     Seccion_Curso_CodigoCurso,
     Seccion_Anio,
     Seccion_Seccion,
     Seccion_Ciclo
    ) 
    REFERENCES Seccion 
    ( 
     Curso_CodigoCurso,
     Anio,
     Seccion,
     Ciclo
    ) 
    ON DELETE CASCADE 
;

ALTER TABLE Inscripcion 
    ADD CONSTRAINT Inscripcion_Carrera_FK FOREIGN KEY 
    ( 
     Carrera_Carrera
    ) 
    REFERENCES Carrera 
    ( 
     Carrera
    ) 
    ON DELETE CASCADE 
;

ALTER TABLE Inscripcion 
    ADD CONSTRAINT Inscripcion_Estudiante_FK FOREIGN KEY 
    ( 
     Estudiante_Carnet
    ) 
    REFERENCES Estudiante 
    ( 
     Carnet
    ) 
    ON DELETE CASCADE 
;

ALTER TABLE Pensum 
    ADD CONSTRAINT Pensum_Curso_FK FOREIGN KEY 
    ( 
     Curso_CodigoCurso
    ) 
    REFERENCES Curso 
    ( 
     CodigoCurso
    ) 
    ON DELETE CASCADE 
;

ALTER TABLE Pensum 
    ADD CONSTRAINT Pensum_Plan_FK FOREIGN KEY 
    ( 
     Plan_Plan,
     Plan_Carrera_Carrera
    ) 
    REFERENCES Plan 
    ( 
     Plan,
     Carrera_Carrera
    ) 
    ON DELETE CASCADE 
;

ALTER TABLE Plan 
    ADD CONSTRAINT Plan_Carrera_FK FOREIGN KEY 
    ( 
     Carrera_Carrera
    ) 
    REFERENCES Carrera 
    ( 
     Carrera
    ) 
    ON DELETE CASCADE 
;

ALTER TABLE Prerreq 
    ADD CONSTRAINT Prerreq_Pensum_FK FOREIGN KEY 
    ( 
     Pensum_Carrera,
     Pensum_Plan,
     Pensum_Curso_CodigoCurso
    ) 
    REFERENCES Pensum 
    ( 
     Plan_Carrera_Carrera,
     Plan_Plan,
     Curso_CodigoCurso
    ) 
    ON DELETE CASCADE 
;

ALTER TABLE Seccion 
    ADD CONSTRAINT Seccion_Catedratico_FK FOREIGN KEY 
    ( 
     Catedratico_Catedratico
    ) 
    REFERENCES Catedratico 
    ( 
     Catedratico
    ) 
    ON DELETE CASCADE 
;

ALTER TABLE Seccion 
    ADD CONSTRAINT Seccion_Curso_FK FOREIGN KEY 
    ( 
     Curso_CodigoCurso
    ) 
    REFERENCES Curso 
    ( 
     CodigoCurso
    ) 
    ON DELETE CASCADE 
;



-- Informe de Resumen de Oracle SQL Developer Data Modeler: 
-- 
-- CREATE TABLE                            14
-- CREATE INDEX                             0
-- ALTER TABLE                             26
-- CREATE VIEW                              0
-- ALTER VIEW                               0
-- CREATE PACKAGE                           0
-- CREATE PACKAGE BODY                      0
-- CREATE PROCEDURE                         0
-- CREATE FUNCTION                          0
-- CREATE TRIGGER                           0
-- ALTER TRIGGER                            0
-- CREATE COLLECTION TYPE                   0
-- CREATE STRUCTURED TYPE                   0
-- CREATE STRUCTURED TYPE BODY              0
-- CREATE CLUSTER                           0
-- CREATE CONTEXT                           0
-- CREATE DATABASE                          0
-- CREATE DIMENSION                         0
-- CREATE DIRECTORY                         0
-- CREATE DISK GROUP                        0
-- CREATE ROLE                              0
-- CREATE ROLLBACK SEGMENT                  0
-- CREATE SEQUENCE                          0
-- CREATE MATERIALIZED VIEW                 0
-- CREATE MATERIALIZED VIEW LOG             0
-- CREATE SYNONYM                           0
-- CREATE TABLESPACE                        0
-- CREATE USER                              0
-- 
-- DROP TABLESPACE                          0
-- DROP DATABASE                            0
-- 
-- REDACTION POLICY                         0
-- 
-- ORDS DROP SCHEMA                         0
-- ORDS ENABLE SCHEMA                       0
-- ORDS ENABLE OBJECT                       0
-- 
-- ERRORS                                   0
-- WARNINGS                                 0
