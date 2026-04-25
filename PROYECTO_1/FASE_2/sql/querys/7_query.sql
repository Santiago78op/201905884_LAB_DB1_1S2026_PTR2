/*
* Consulta 7:
* Agregar columna para guardar el sueldo en letras,
* convertir el monto a texto y mantener el dato sincronizado.
*/

/*
* Se agrega la columna donde se almacenará el sueldo en letras.
*/

/* Paso 1: Agregar columna si no existe 
* Lo hago con un contador para ver si tiene Datos
*/
DECLARE
    v_columna_existe NUMBER;
BEGIN
    SELECT COUNT(*)
    INTO v_columna_existe
    FROM USER_TAB_COLUMNS
    WHERE TABLE_NAME = 'CATEDRATICO'
      AND COLUMN_NAME = 'SUELDO_LETRAS';

    IF v_columna_existe = 0 THEN
        EXECUTE IMMEDIATE '
            ALTER TABLE CATEDRATICO
            ADD SUELDO_LETRAS VARCHAR2(255)
        ';
    END IF;
END;
/

/* Paso 2: Función auxiliar paraconvertir de num a letra */
CREATE OR REPLACE FUNCTION NUMERO_A_LETRAS(p_numero NUMBER)
RETURN VARCHAR2
IS
    v_entero          NUMBER;
    v_centavos        NUMBER;
    v_texto_entero    VARCHAR2(300);

    FUNCTION unidades(n NUMBER) RETURN VARCHAR2 IS
    BEGIN
        CASE n
            WHEN 0 THEN RETURN 'CERO';
            WHEN 1 THEN RETURN 'UNO';
            WHEN 2 THEN RETURN 'DOS';
            WHEN 3 THEN RETURN 'TRES';
            WHEN 4 THEN RETURN 'CUATRO';
            WHEN 5 THEN RETURN 'CINCO';
            WHEN 6 THEN RETURN 'SEIS';
            WHEN 7 THEN RETURN 'SIETE';
            WHEN 8 THEN RETURN 'OCHO';
            WHEN 9 THEN RETURN 'NUEVE';
            ELSE RETURN '';
        END CASE;
    END;

    FUNCTION unidades_aux(n NUMBER) RETURN VARCHAR2 IS
    BEGIN
        IF n = 1 THEN
            RETURN 'UN';
        ELSE
            RETURN unidades(n);
        END IF;
    END;

    FUNCTION decenas(n NUMBER) RETURN VARCHAR2 IS
        d NUMBER;
        u NUMBER;
        v_base VARCHAR2(30);
    BEGIN
        IF n < 10 THEN
            RETURN unidades(n);
        ELSIF n = 10 THEN RETURN 'DIEZ';
        ELSIF n = 11 THEN RETURN 'ONCE';
        ELSIF n = 12 THEN RETURN 'DOCE';
        ELSIF n = 13 THEN RETURN 'TRECE';
        ELSIF n = 14 THEN RETURN 'CATORCE';
        ELSIF n = 15 THEN RETURN 'QUINCE';
        ELSIF n < 20 THEN
            RETURN 'DIECI' || unidades(n - 10);
        ELSIF n = 20 THEN RETURN 'VEINTE';
        ELSIF n < 30 THEN
            RETURN 'VEINTI' || unidades(n - 20);
        ELSE
            d := TRUNC(n / 10);
            -- Se aplica MOD para poder extraer la unidad 55 = CINCUENTA Y CINCO
            u := MOD(n, 10);

            CASE d
                WHEN 3 THEN v_base := 'TREINTA';
                WHEN 4 THEN v_base := 'CUARENTA';
                WHEN 5 THEN v_base := 'CINCUENTA';
                WHEN 6 THEN v_base := 'SESENTA';
                WHEN 7 THEN v_base := 'SETENTA';
                WHEN 8 THEN v_base := 'OCHENTA';
                WHEN 9 THEN v_base := 'NOVENTA';
            END CASE;

            IF u > 0 THEN
                RETURN v_base || ' Y ' || unidades(u);
            ELSE
                RETURN v_base;
            END IF;
        END IF;
    END;

    FUNCTION decenas_aux(n NUMBER) RETURN VARCHAR2 IS
        d NUMBER;
        u NUMBER;
        v_base VARCHAR2(30);
    BEGIN
        IF n < 10 THEN
            RETURN unidades_aux(n);
        ELSIF n = 10 THEN RETURN 'DIEZ';
        ELSIF n = 11 THEN RETURN 'ONCE';
        ELSIF n = 12 THEN RETURN 'DOCE';
        ELSIF n = 13 THEN RETURN 'TRECE';
        ELSIF n = 14 THEN RETURN 'CATORCE';
        ELSIF n = 15 THEN RETURN 'QUINCE';
        ELSIF n < 20 THEN
            IF n = 16 THEN RETURN 'DIECISEIS';
            ELSIF n = 17 THEN RETURN 'DIECISIETE';
            ELSIF n = 18 THEN RETURN 'DIECIOCHO';
            ELSIF n = 19 THEN RETURN 'DIECINUEVE';
            END IF;
        ELSIF n = 20 THEN RETURN 'VEINTE';
        ELSIF n < 30 THEN
            IF n = 21 THEN
                RETURN 'VEINTIUN';
            ELSE
                RETURN 'VEINTI' || unidades(n - 20);
            END IF;
        ELSE
            d := TRUNC(n / 10);
            u := MOD(n, 10);

            CASE d
                WHEN 3 THEN v_base := 'TREINTA';
                WHEN 4 THEN v_base := 'CUARENTA';
                WHEN 5 THEN v_base := 'CINCUENTA';
                WHEN 6 THEN v_base := 'SESENTA';
                WHEN 7 THEN v_base := 'SETENTA';
                WHEN 8 THEN v_base := 'OCHENTA';
                WHEN 9 THEN v_base := 'NOVENTA';
            END CASE;

            IF u > 0 THEN
                RETURN v_base || ' Y ' || unidades_aux(u);
            ELSE
                RETURN v_base;
            END IF;
        END IF;
    END;

    FUNCTION centenas(n NUMBER) RETURN VARCHAR2 IS
        c NUMBER;
        r NUMBER;
        v_base VARCHAR2(40);
    BEGIN
        IF n < 100 THEN
            RETURN decenas(n);
        ELSIF n = 100 THEN
            RETURN 'CIEN';
        ELSE
            c := TRUNC(n / 100);
            r := MOD(n, 100);

            CASE c
                WHEN 1 THEN v_base := 'CIENTO';
                WHEN 2 THEN v_base := 'DOSCIENTOS';
                WHEN 3 THEN v_base := 'TRESCIENTOS';
                WHEN 4 THEN v_base := 'CUATROCIENTOS';
                WHEN 5 THEN v_base := 'QUINIENTOS';
                WHEN 6 THEN v_base := 'SEISCIENTOS';
                WHEN 7 THEN v_base := 'SETECIENTOS';
                WHEN 8 THEN v_base := 'OCHOCIENTOS';
                WHEN 9 THEN v_base := 'NOVECIENTOS';
            END CASE;

            IF r > 0 THEN
                RETURN v_base || ' ' || decenas(r);
            ELSE
                RETURN v_base;
            END IF;
        END IF;
    END;

    FUNCTION centenas_aux(n NUMBER) RETURN VARCHAR2 IS
        c NUMBER;
        r NUMBER;
        v_base VARCHAR2(40);
    BEGIN
        IF n < 100 THEN
            RETURN decenas_aux(n);
        ELSIF n = 100 THEN
            RETURN 'CIEN';
        ELSE
            c := TRUNC(n / 100);
            r := MOD(n, 100);

            CASE c
                WHEN 1 THEN v_base := 'CIENTO';
                WHEN 2 THEN v_base := 'DOSCIENTOS';
                WHEN 3 THEN v_base := 'TRESCIENTOS';
                WHEN 4 THEN v_base := 'CUATROCIENTOS';
                WHEN 5 THEN v_base := 'QUINIENTOS';
                WHEN 6 THEN v_base := 'SEISCIENTOS';
                WHEN 7 THEN v_base := 'SETECIENTOS';
                WHEN 8 THEN v_base := 'OCHOCIENTOS';
                WHEN 9 THEN v_base := 'NOVECIENTOS';
            END CASE;

            IF r > 0 THEN
                RETURN v_base || ' ' || decenas_aux(r);
            ELSE
                RETURN v_base;
            END IF;
        END IF;
    END;

    FUNCTION miles(n NUMBER) RETURN VARCHAR2 IS
        m NUMBER;
        r NUMBER;
        v_base VARCHAR2(300);
    BEGIN
        IF n < 1000 THEN
            RETURN centenas(n);
        END IF;

        m := TRUNC(n / 1000);
        r := MOD(n, 1000);

        IF m = 1 THEN
            v_base := 'MIL';
        ELSE
            v_base := centenas_aux(m) || ' MIL';
        END IF;

        IF r > 0 THEN
            RETURN v_base || ' ' || centenas(r);
        ELSE
            RETURN v_base;
        END IF;
    END;

BEGIN
    IF p_numero IS NULL OR p_numero < 0 THEN
        RETURN 'MONTO INVALIDO';
    END IF;

    IF p_numero > 99000 THEN
        RETURN 'MONTO FUERA DE RANGO';
    END IF;

    v_entero := TRUNC(p_numero);
    v_centavos := ROUND((p_numero - v_entero) * 100);

    IF v_centavos = 100 THEN
        v_entero := v_entero + 1;
        v_centavos := 0;
    END IF;

    v_texto_entero := miles(v_entero);

    IF v_centavos > 0 THEN
        RETURN v_texto_entero || ' QUETZALES CON ' ||
               decenas(v_centavos) || ' CENTAVOS';
    ELSE
        RETURN v_texto_entero || ' QUETZALES';
    END IF;
END;
/

/* Paso 3: Actualiza la tabla catedratico en el campo Sueldo_letras */
UPDATE CATEDRATICO
SET SUELDO_LETRAS = NUMERO_A_LETRAS(SUELDOMENSUAL);

COMMIT;

/* Paso 4: Disparador que se ejecuta despues del evento actualizar   */
CREATE OR REPLACE TRIGGER TRG_CATEDRATICO_SUELDO_LETRAS
BEFORE INSERT OR UPDATE OF SUELDOMENSUAL
ON CATEDRATICO
FOR EACH ROW
BEGIN
    :NEW.SUELDO_LETRAS := NUMERO_A_LETRAS(:NEW.SUELDOMENSUAL);
END;
/

/* Paso 5: Query de Salida data */
SELECT CATEDRATICO, NOMBRE, SUELDOMENSUAL, SUELDO_LETRAS
FROM CATEDRATICO;
