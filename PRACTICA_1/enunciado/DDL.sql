-- Generado por Oracle SQL Developer Data Modeler 24.3.1.351.0831
--   en:        2026-02-20 09:28:10 CST
--   sitio:      Oracle Database 12c
--   tipo:      Oracle Database 12c



-- predefined type, no DDL - MDSYS.SDO_GEOMETRY

-- predefined type, no DDL - XMLTYPE

CREATE TABLE CENTRO_EVALUACIÓN 
    ( 
     id_centro INTEGER  NOT NULL , 
     nombre    VARCHAR2 (40)  NOT NULL , 
     direccion VARCHAR2 (50)  NOT NULL 
    ) 
;

ALTER TABLE CENTRO_EVALUACIÓN 
    ADD CONSTRAINT CENTRO_EVALUACIÓN_PK PRIMARY KEY ( id_centro ) ;

CREATE TABLE CONDUCTOR 
    ( 
     id_conductor         INTEGER  NOT NULL , 
     fecha_registro       DATE  NOT NULL , 
     nombre               VARCHAR2 (40)  NOT NULL , 
     direccion            VARCHAR2 (50)  NOT NULL , 
     identificacion       INTEGER  NOT NULL , 
     telefono             INTEGER  NOT NULL , 
     fotografia           BLOB  NOT NULL , 
     genero               VARCHAR2 (1)  NOT NULL , 
     departamento         VARCHAR2 (10)  NOT NULL , 
     municipio            VARCHAR2 (10)  NOT NULL , 
     fecha_nacimiento     DATE  NOT NULL , 
     CONDUCTOR_ID         NUMBER  NOT NULL , 
     EMPLEADO_EMPLEADO_ID NUMBER  NOT NULL 
    ) 
;

ALTER TABLE CONDUCTOR 
    ADD CONSTRAINT CONDUCTOR_PK PRIMARY KEY ( CONDUCTOR_ID ) ;

CREATE TABLE CORREL_EXAMEN 
    ( 
     id_correl     INTEGER  NOT NULL , 
     fecha_correl  DATE  NOT NULL , 
     correl_actual INTEGER  NOT NULL 
    ) 
;

ALTER TABLE CORREL_EXAMEN 
    ADD CONSTRAINT CORREL_EXAMEN_PK PRIMARY KEY ( id_correl ) ;

CREATE TABLE EMPLEADO 
    ( 
     id_empleado                      INTEGER  NOT NULL , 
     nombre                           VARCHAR2 (40)  NOT NULL , 
     direccion                        VARCHAR2 (50)  NOT NULL , 
     identificacion                   INTEGER  NOT NULL , 
     telefono                         INTEGER  NOT NULL , 
     fotografia                       BLOB  NOT NULL , 
     genero                           VARCHAR2 (1)  NOT NULL , 
     puesto                           VARCHAR2 (10)  NOT NULL , 
     activo                           NUMBER  NOT NULL , 
     fecha_inicio_labores             DATE  NOT NULL , 
     fecha_fin_labores                DATE , 
--  ERROR: Column name length exceeds maximum allowed length(30) 
     ESCUELA_AUTOMOVILISMO_id_escuela INTEGER  NOT NULL , 
     EMPLEADO_ID                      NUMBER  NOT NULL 
    ) 
;

ALTER TABLE EMPLEADO 
    ADD CONSTRAINT EMPLEADO_PK PRIMARY KEY ( EMPLEADO_ID ) ;

CREATE TABLE ESCUELA_AUTOMOVILISMO 
    ( 
     id_escuela          INTEGER  NOT NULL , 
     nombre              VARCHAR2 (40)  NOT NULL , 
     direccion           VARCHAR2 (50)  NOT NULL , 
     numero_autorizacion INTEGER  NOT NULL 
    ) 
;

ALTER TABLE ESCUELA_AUTOMOVILISMO 
    ADD CONSTRAINT ESCUELA_AUTOMOVILISMO_PK PRIMARY KEY ( id_escuela ) ;

CREATE TABLE EXAMEN 
    ( 
     id_examen                       INTEGER  NOT NULL , 
     categoria                       VARCHAR2 (10)  NOT NULL , 
     fecha_evaluacion                DATE  NOT NULL , 
     correlativo                     INTEGER  NOT NULL , 
     nota                            NUMBER  NOT NULL , 
--  ERROR: Column name length exceeds maximum allowed length(30) 
     SOLICITUD_LICENCIA_id_solicitud INTEGER  NOT NULL , 
     EMPLEADO_EMPLEADO_ID            NUMBER  NOT NULL 
    ) 
;

ALTER TABLE EXAMEN 
    ADD CONSTRAINT EXAMEN_PK PRIMARY KEY ( id_examen ) ;

CREATE TABLE LICENCIA 
    ( 
     id_licencia INTEGER  NOT NULL , 
     tipo        VARCHAR2 (1)  NOT NULL , 
     descripcion VARCHAR2 (20)  NOT NULL 
    ) 
;

ALTER TABLE LICENCIA 
    ADD CONSTRAINT LICENCIA_PK PRIMARY KEY ( id_licencia ) ;

CREATE TABLE PREGUNTA 
    ( 
     id_pregunta            INTEGER  NOT NULL , 
     categoria              VARCHAR2 (15)  NOT NULL , 
     respuesta_correcta     VARCHAR2 (30) , 
     respuestas_incorrectas CLOB , 
     EMPLEADO_EMPLEADO_ID   NUMBER  NOT NULL 
    ) 
;

ALTER TABLE PREGUNTA 
    ADD CONSTRAINT PREGUNTA_PK PRIMARY KEY ( id_pregunta ) ;

CREATE TABLE R_CENTRO_ESCUELA 
    ( 
     CENTRO_EVALUACIÓN_id_centro      INTEGER  NOT NULL , 
--  ERROR: Column name length exceeds maximum allowed length(30) 
     ESCUELA_AUTOMOVILISMO_id_escuela INTEGER  NOT NULL 
    ) 
;

ALTER TABLE R_CENTRO_ESCUELA 
    ADD CONSTRAINT R_CENTRO_ESCUELA_PK PRIMARY KEY ( CENTRO_EVALUACIÓN_id_centro, ESCUELA_AUTOMOVILISMO_id_escuela ) ;

CREATE TABLE R_CONDUCTOR_LICENCIA 
    ( 
     CONDUCTOR_CONDUCTOR_ID NUMBER  NOT NULL , 
     LICENCIA_id_licencia   INTEGER  NOT NULL 
    ) 
;

ALTER TABLE R_CONDUCTOR_LICENCIA 
    ADD CONSTRAINT R_CONDUCTOR_LICENCIA_PK PRIMARY KEY ( CONDUCTOR_CONDUCTOR_ID, LICENCIA_id_licencia ) ;

CREATE TABLE R_EXAMEN_PREGUNTA 
    ( 
     EXAMEN_id_examen     INTEGER  NOT NULL , 
     PREGUNTA_id_pregunta INTEGER  NOT NULL , 
     satisfactorio        NUMBER  NOT NULL 
    ) 
;

ALTER TABLE R_EXAMEN_PREGUNTA 
    ADD CONSTRAINT R_EXAMEN_PREGUNTA_PK PRIMARY KEY ( EXAMEN_id_examen, PREGUNTA_id_pregunta ) ;

CREATE TABLE SOLICITUD_LICENCIA 
    ( 
     id_solicitud                     INTEGER  NOT NULL , 
     tipo_tramite                     VARCHAR2 (15)  NOT NULL , 
     fecha_solicitud                  DATE  NOT NULL , 
     estado_tramite                   INTEGER  NOT NULL , 
     LICENCIA_id_licencia             INTEGER  NOT NULL , 
--  ERROR: Column name length exceeds maximum allowed length(30) 
     ESCUELA_AUTOMOVILISMO_id_escuela INTEGER  NOT NULL , 
     CONDUCTOR_CONDUCTOR_ID           NUMBER  NOT NULL , 
     EMPLEADO_EMPLEADO_ID             NUMBER  NOT NULL 
    ) 
;

ALTER TABLE SOLICITUD_LICENCIA 
    ADD CONSTRAINT SOLICITUD_LICENCIA_PK PRIMARY KEY ( id_solicitud ) ;

ALTER TABLE CONDUCTOR 
    ADD CONSTRAINT CONDUCTOR_EMPLEADO_FK FOREIGN KEY 
    ( 
     EMPLEADO_EMPLEADO_ID
    ) 
    REFERENCES EMPLEADO 
    ( 
     EMPLEADO_ID
    ) 
;

--  ERROR: FK name length exceeds maximum allowed length(30) 
ALTER TABLE EMPLEADO 
    ADD CONSTRAINT EMPLEADO_ESCUELA_AUTOMOVILISMO_FK FOREIGN KEY 
    ( 
     ESCUELA_AUTOMOVILISMO_id_escuela
    ) 
    REFERENCES ESCUELA_AUTOMOVILISMO 
    ( 
     id_escuela
    ) 
;

ALTER TABLE EXAMEN 
    ADD CONSTRAINT EXAMEN_EMPLEADO_FK FOREIGN KEY 
    ( 
     EMPLEADO_EMPLEADO_ID
    ) 
    REFERENCES EMPLEADO 
    ( 
     EMPLEADO_ID
    ) 
;

ALTER TABLE EXAMEN 
    ADD CONSTRAINT EXAMEN_SOLICITUD_LICENCIA_FK FOREIGN KEY 
    ( 
     SOLICITUD_LICENCIA_id_solicitud
    ) 
    REFERENCES SOLICITUD_LICENCIA 
    ( 
     id_solicitud
    ) 
;

ALTER TABLE PREGUNTA 
    ADD CONSTRAINT PREGUNTA_EMPLEADO_FK FOREIGN KEY 
    ( 
     EMPLEADO_EMPLEADO_ID
    ) 
    REFERENCES EMPLEADO 
    ( 
     EMPLEADO_ID
    ) 
;

--  ERROR: FK name length exceeds maximum allowed length(30) 
ALTER TABLE R_CENTRO_ESCUELA 
    ADD CONSTRAINT R_CENTRO_ESCUELA_CENTRO_EVALUACIÓN_FK FOREIGN KEY 
    ( 
     CENTRO_EVALUACIÓN_id_centro
    ) 
    REFERENCES CENTRO_EVALUACIÓN 
    ( 
     id_centro
    ) 
;

--  ERROR: FK name length exceeds maximum allowed length(30) 
ALTER TABLE R_CENTRO_ESCUELA 
    ADD CONSTRAINT R_CENTRO_ESCUELA_ESCUELA_AUTOMOVILISMO_FK FOREIGN KEY 
    ( 
     ESCUELA_AUTOMOVILISMO_id_escuela
    ) 
    REFERENCES ESCUELA_AUTOMOVILISMO 
    ( 
     id_escuela
    ) 
;

--  ERROR: FK name length exceeds maximum allowed length(30) 
ALTER TABLE R_CONDUCTOR_LICENCIA 
    ADD CONSTRAINT R_CONDUCTOR_LICENCIA_CONDUCTOR_FK FOREIGN KEY 
    ( 
     CONDUCTOR_CONDUCTOR_ID
    ) 
    REFERENCES CONDUCTOR 
    ( 
     CONDUCTOR_ID
    ) 
;

--  ERROR: FK name length exceeds maximum allowed length(30) 
ALTER TABLE R_CONDUCTOR_LICENCIA 
    ADD CONSTRAINT R_CONDUCTOR_LICENCIA_LICENCIA_FK FOREIGN KEY 
    ( 
     LICENCIA_id_licencia
    ) 
    REFERENCES LICENCIA 
    ( 
     id_licencia
    ) 
;

ALTER TABLE R_EXAMEN_PREGUNTA 
    ADD CONSTRAINT R_EXAMEN_PREGUNTA_EXAMEN_FK FOREIGN KEY 
    ( 
     EXAMEN_id_examen
    ) 
    REFERENCES EXAMEN 
    ( 
     id_examen
    ) 
;

ALTER TABLE R_EXAMEN_PREGUNTA 
    ADD CONSTRAINT R_EXAMEN_PREGUNTA_PREGUNTA_FK FOREIGN KEY 
    ( 
     PREGUNTA_id_pregunta
    ) 
    REFERENCES PREGUNTA 
    ( 
     id_pregunta
    ) 
;

--  ERROR: FK name length exceeds maximum allowed length(30) 
ALTER TABLE SOLICITUD_LICENCIA 
    ADD CONSTRAINT SOLICITUD_LICENCIA_CONDUCTOR_FK FOREIGN KEY 
    ( 
     CONDUCTOR_CONDUCTOR_ID
    ) 
    REFERENCES CONDUCTOR 
    ( 
     CONDUCTOR_ID
    ) 
;

ALTER TABLE SOLICITUD_LICENCIA 
    ADD CONSTRAINT SOLICITUD_LICENCIA_EMPLEADO_FK FOREIGN KEY 
    ( 
     EMPLEADO_EMPLEADO_ID
    ) 
    REFERENCES EMPLEADO 
    ( 
     EMPLEADO_ID
    ) 
;

--  ERROR: FK name length exceeds maximum allowed length(30) 
ALTER TABLE SOLICITUD_LICENCIA 
    ADD CONSTRAINT SOLICITUD_LICENCIA_ESCUELA_AUTOMOVILISMO_FK FOREIGN KEY 
    ( 
     ESCUELA_AUTOMOVILISMO_id_escuela
    ) 
    REFERENCES ESCUELA_AUTOMOVILISMO 
    ( 
     id_escuela
    ) 
;

ALTER TABLE SOLICITUD_LICENCIA 
    ADD CONSTRAINT SOLICITUD_LICENCIA_LICENCIA_FK FOREIGN KEY 
    ( 
     LICENCIA_id_licencia
    ) 
    REFERENCES LICENCIA 
    ( 
     id_licencia
    ) 
;

CREATE SEQUENCE CONDUCTOR_CONDUCTOR_ID_SEQ 
START WITH 1 
    NOCACHE 
    ORDER ;

CREATE OR REPLACE TRIGGER CONDUCTOR_CONDUCTOR_ID_TRG 
BEFORE INSERT ON CONDUCTOR 
FOR EACH ROW 
WHEN (NEW.CONDUCTOR_ID IS NULL) 
BEGIN 
    :NEW.CONDUCTOR_ID := CONDUCTOR_CONDUCTOR_ID_SEQ.NEXTVAL; 
END;
/

CREATE SEQUENCE EMPLEADO_EMPLEADO_ID_SEQ 
START WITH 1 
    NOCACHE 
    ORDER ;

CREATE OR REPLACE TRIGGER EMPLEADO_EMPLEADO_ID_TRG 
BEFORE INSERT ON EMPLEADO 
FOR EACH ROW 
WHEN (NEW.EMPLEADO_ID IS NULL) 
BEGIN 
    :NEW.EMPLEADO_ID := EMPLEADO_EMPLEADO_ID_SEQ.NEXTVAL; 
END;
/



-- Informe de Resumen de Oracle SQL Developer Data Modeler: 
-- 
-- CREATE TABLE                            12
-- CREATE INDEX                             0
-- ALTER TABLE                             27
-- CREATE VIEW                              0
-- ALTER VIEW                               0
-- CREATE PACKAGE                           0
-- CREATE PACKAGE BODY                      0
-- CREATE PROCEDURE                         0
-- CREATE FUNCTION                          0
-- CREATE TRIGGER                           2
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
-- CREATE SEQUENCE                          2
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
-- TSDP POLICY                              0
-- 
-- ORDS DROP SCHEMA                         0
-- ORDS ENABLE SCHEMA                       0
-- ORDS ENABLE OBJECT                       0
-- 
-- ERRORS                                  11
-- WARNINGS                                 0
