/*
* Consulta 7:
* Agregar columna para guardar el sueldo en letras,
* convertir el monto a texto y mantener el dato sincronizado.
*/

/*
* Se agrega la columna donde se almacenará el sueldo en letras.
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
        EXECUTE IMMEDIATE 'ALTER TABLE CATEDRATICO ADD SUELDO_LETRAS VARCHAR2(255)';
    END IF;
END;
/

/*
* Función de conversión de número a letras (rango soportado: 0 a 99,000.00).
*/
CREATE OR REPLACE FUNCTION NUMERO_A_LETRAS(p_numero NUMBER)
RETURN VARCHAR2
IS
    v_entero          NUMBER;
    v_centavos        NUMBER;
    v_texto_entero    VARCHAR2(300);
    v_texto_centavos  VARCHAR2(20);

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

    FUNCTION decenas(n NUMBER) RETURN VARCHAR2 IS
        d NUMBER;
        u NUMBER;
        v_base VARCHAR2(30);
    BEGIN
        IF n = 10 THEN RETURN 'DIEZ';
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
                WHEN 1 THEN v_texto_entero := 'CIENTO';
                WHEN 2 THEN v_texto_entero := 'DOSCIENTOS';
                WHEN 3 THEN v_texto_entero := 'TRESCIENTOS';
                WHEN 4 THEN v_texto_entero := 'CUATROCIENTOS';
                WHEN 5 THEN v_texto_entero := 'QUINIENTOS';
                WHEN 6 THEN v_texto_entero := 'SEISCIENTOS';
                WHEN 7 THEN v_texto_entero := 'SETECIENTOS';
                WHEN 8 THEN v_texto_entero := 'OCHOCIENTOS';
                WHEN 9 THEN v_texto_entero := 'NOVECIENTOS';
            END CASE;

            IF r > 0 THEN
                RETURN v_texto_entero || ' ' || decenas(r);
            ELSE
                RETURN v_texto_entero;
            END IF;
        END IF;
    END;

    FUNCTION miles(n NUMBER) RETURN VARCHAR2 IS
        m NUMBER;
        r NUMBER;
    BEGIN
        -- Divido en n en 1000 para obtener la parte de Unidad
        m := TRUNC(n / 1000);

        r := MOD(n, 1000);

        IF m = 1 THEN
            v_texto_entero := 'MIL';
        ELSE
            v_texto_entero := centenas(m) || ' MIL';
        END IF;

        IF r > 0 THEN
            RETURN v_texto_entero || ' ' || centenas(r);
        ELSE
            RETURN v_texto_entero;
        END IF;
    END;

    FUNCTION convertir(n NUMBER) RETURN VARCHAR2 IS
    BEGIN
        IF n = 0 THEN
            RETURN 'CERO';
        ELSIF n < 10 THEN
            RETURN unidades(n);
        ELSIF n < 100 THEN
            RETURN decenas(n);
        ELSIF n < 1000 THEN
            RETURN centenas(n);
        ELSE
            RETURN miles(n);
        END IF;
    END;

BEGIN

    -- Si valido que es Null retorno Error
    IF p_numero IS NULL OR p_numero < 0 THEN
        RETURN 'MONTO INVALIDO';
    END IF;

    -- Elimina parte decimal sin redondear
    -- 123.75 -> 123
    v_entero := TRUNC(p_numero);
    -- Parte decimal en centavos
    -- 123.75 - 123 -> 0.75 * 100 -> 75
    v_centavos := ROUND((p_numero - v_entero) * 100);

    -- Si es mayor da conflicto con la instrucción
    IF p_numero > 99000 THEN
        RETURN 'MONTO FUERA DE RANGO';
    END IF;

    -- Ajuste para casos como 10.995 que redondean centavos a 100.
    IF v_centavos = 100 THEN
        v_entero := v_entero + 1;
        v_centavos := 0;
    END IF;

    v_texto_entero := convertir(v_entero);

    IF v_centavos > 0 THEN
        -- LPAD para asegurar que siempre tenga 2 dígitos (ej: 5 -> '05')
        v_texto_centavos := LPAD(v_centavos, 2, '0') || '/100';
        RETURN v_texto_entero || ' CON ' || v_texto_centavos;
    END IF;

    RETURN v_texto_entero;
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
