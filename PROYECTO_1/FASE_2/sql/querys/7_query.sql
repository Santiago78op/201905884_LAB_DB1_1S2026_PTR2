/*
* Consulta 7:
* Agregar columna para guardar el sueldo en letras,
* convertir el monto a texto y mantener el dato sincronizado.
*/

/*
* Se agrega la columna donde se almacenará el sueldo en letras.
*/
ALTER TABLE CATEDRATICO
ADD SUELDO_LETRAS VARCHAR2(255);

/*
* Función de conversión de número a letras (rango soportado: 0 a 99,000.00).
*/
CREATE OR REPLACE FUNCTION NUMERO_A_LETRAS(p_numero NUMBER)
RETURN VARCHAR2
IS
    v_entero   NUMBER;
    v_centavos NUMBER;
    v_texto    VARCHAR2(300);

    FUNCTION unidades(n NUMBER) RETURN VARCHAR2 IS
    BEGIN
        CASE n
            WHEN 0 THEN RETURN '';
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

    FUNCTION decenas(n NUMBER) RETURN VARCHAR2 IS
        d NUMBER;
        u NUMBER;
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
            u := MOD(n, 10);

            CASE d
                WHEN 3 THEN v_texto := 'TREINTA';
                WHEN 4 THEN v_texto := 'CUARENTA';
                WHEN 5 THEN v_texto := 'CINCUENTA';
                WHEN 6 THEN v_texto := 'SESENTA';
                WHEN 7 THEN v_texto := 'SETENTA';
                WHEN 8 THEN v_texto := 'OCHENTA';
                WHEN 9 THEN v_texto := 'NOVENTA';
            END CASE;

            IF u > 0 THEN
                RETURN v_texto || ' Y ' || unidades(u);
            ELSE
                RETURN v_texto;
            END IF;
        END IF;
    END;

    FUNCTION centenas(n NUMBER) RETURN VARCHAR2 IS
        c NUMBER;
        r NUMBER;
    BEGIN
        IF n < 100 THEN
            RETURN decenas(n);
        ELSIF n = 100 THEN
            RETURN 'CIEN';
        ELSE
            c := TRUNC(n / 100);
            r := MOD(n, 100);

            CASE c
                WHEN 1 THEN v_texto := 'CIENTO';
                WHEN 2 THEN v_texto := 'DOSCIENTOS';
                WHEN 3 THEN v_texto := 'TRESCIENTOS';
                WHEN 4 THEN v_texto := 'CUATROCIENTOS';
                WHEN 5 THEN v_texto := 'QUINIENTOS';
                WHEN 6 THEN v_texto := 'SEISCIENTOS';
                WHEN 7 THEN v_texto := 'SETECIENTOS';
                WHEN 8 THEN v_texto := 'OCHOCIENTOS';
                WHEN 9 THEN v_texto := 'NOVECIENTOS';
            END CASE;

            IF r > 0 THEN
                RETURN v_texto || ' ' || decenas(r);
            ELSE
                RETURN v_texto;
            END IF;
        END IF;
    END;

    FUNCTION miles(n NUMBER) RETURN VARCHAR2 IS
        m NUMBER;
        r NUMBER;
    BEGIN
        IF n < 1000 THEN
            RETURN centenas(n);
        ELSE
            m := TRUNC(n / 1000);
            r := MOD(n, 1000);

            IF m = 1 THEN
                v_texto := 'MIL';
            ELSE
                v_texto := centenas(m) || ' MIL';
            END IF;

            IF r > 0 THEN
                RETURN v_texto || ' ' || centenas(r);
            ELSE
                RETURN v_texto;
            END IF;
        END IF;
    END;

BEGIN
    IF p_numero IS NULL OR p_numero < 0 THEN
        RETURN 'MONTO INVALIDO';
    END IF;

    v_entero := TRUNC(p_numero);
    v_centavos := ROUND((p_numero - v_entero) * 100);

    IF p_numero > 99000 THEN
        RETURN 'MONTO FUERA DE RANGO';
    END IF;

    RETURN 'QUETZALES ' || miles(v_entero) || 
           ' CON ' || LPAD(v_centavos, 2, '0') || '/100';
END;
/

/*
* Se actualizan registros existentes.
*/
UPDATE catedratico
SET sueldo_letras = numero_a_letras(sueldomensual);

/*
* Trigger para mantener sincronizada la columna en altas/cambios de sueldo.
*/
CREATE OR REPLACE TRIGGER TRG_CATEDRATICO_SUELDO_LETRAS
BEFORE INSERT OR UPDATE OF SUELDOMENSUAL
ON CATEDRATICO
FOR EACH ROW
BEGIN
    :NEW.SUELDO_LETRAS := NUMERO_A_LETRAS(:NEW.SUELDOMENSUAL);
END;
/
