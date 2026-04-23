/*
*Insertar una nueva columna en la tabla catedráticos en la que se grabe el salario que ganan, pero en letras. Pueden usar tablas auxiliares (no mayor a Q99,000 sin centavos, menor a Q99,000 con centavos)
*/
ALTER TABLE CATEDRATICO
ADD SUELDO_LETRAS VARCHAR2(255);

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
    v_entero := TRUNC(p_numero);
    v_centavos := ROUND((p_numero - v_entero) * 100);

    IF p_numero > 99999.99 THEN
        RETURN 'MONTO FUERA DE RANGO';
    END IF;

    RETURN 'QUETZALES ' || miles(v_entero) || 
           ' CON ' || LPAD(v_centavos, 2, '0') || '/100';
END;
/
