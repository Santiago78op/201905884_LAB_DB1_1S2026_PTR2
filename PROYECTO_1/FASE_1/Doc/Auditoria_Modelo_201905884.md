# Auditoría del Modelo – Registro Académico USAC
**Carné:** 201905884
**Proyecto:** Bases de Datos 1 – FASE 1 / FASE 2
**Fecha de auditoría:** 2026-03-24
**Auditor:** Claude Sonnet 4.6 (arquitecto senior de BD)
**Modelos revisados:** Logical.png · Relational_1.png · análisis conceptual

---

## 1. Reglas detectadas del enunciado

### 1.1 Reglas estructurales (afectan al modelo)

| # | Regla | Clasificación |
|---|-------|---------------|
| RE-01 | Un estudiante tiene: carnet, nombre completo, ingreso familiar, fecha de nacimiento | Estructural |
| RE-02 | Una carrera tiene: código, nombre, unidad académica | Estructural |
| RE-03 | Un curso tiene: código de curso, nombre (identidad global, independiente del plan) | Estructural |
| RE-04 | Un plan tiene: código de carrera + código de plan, nombre, año/ciclo inicio, año/ciclo fin, créditos requeridos para cierre | Estructural |
| RE-05 | Un docente tiene: código, nombre completo, sueldo mensual | Estructural |
| RE-06 | Una sección tiene: código de sección, docente asignado, año, ciclo | Estructural |
| RE-07 | Un período tiene: código, hora inicio, hora fin | Estructural |
| RE-08 | Un día tiene: número de día, nombre del día | Estructural |
| RE-09 | Un salón tiene: código de edificio + código de salón, capacidad | Estructural (clave compuesta) |
| RE-10 | Existen 10 carreras distintas | Estructural (dato de cardinalidad) |
| RE-11 | El mismo horario puede tener múltiples cursos con diferentes docentes (no hay conflicto por hora/carrera) | Estructural |
| RE-12 | Un salón puede ser usado por diferentes docentes en diferentes horas | Estructural |
| RE-13 | El sueldo del docente es mensual | Estructural (tipo de dato) |

### 1.2 Reglas de negocio (requieren validación)

| # | Regla | Clasificación |
|---|-------|---------------|
| RN-01 | Un estudiante puede inscribirse en **máximo 2 carreras** de forma simultánea | Negocio (TRIGGER) |
| RN-02 | La aprobación de un curso requiere: zona ≥ zona_mínima del PENSUM **Y** nota ≥ nota_aprobación del PENSUM | Negocio (CHECK parcial) |
| RN-03 | La aprobación de un curso requiere cumplir todos los prerrequisitos del plan correspondiente | Negocio (TRIGGER) |
| RN-04 | El promedio académico (GPA) se calcula **solo con cursos aprobados**, basándose en el pensum en que se tomó el curso | Negocio (lógica de consulta) |
| RN-05 | El cierre de carrera requiere aprobar todos los cursos obligatorios **antes del fin de vigencia del plan** | Negocio (lógica de consulta) |
| RN-06 | El cierre de carrera puede incluir cursos aprobados en planes anteriores | Negocio (lógica de consulta) |
| RN-07 | El cierre de carrera requiere cumplir el mínimo de créditos del plan | Negocio (lógica de consulta) |
| RN-08 | El "mejor estudiante" es el de mayor GPA **sin ningún curso reprobado en su historial** | Negocio (lógica de consulta) |
| RN-09 | Una sección se cierra cuando alcanza capacidad o por acción explícita | Negocio (TRIGGER / estado) |

### 1.3 Reglas candidatas a CHECK CONSTRAINT

| # | Regla |
|---|-------|
| RC-01 | ZONA en ASIGNACION debe estar entre 0 y 100 |
| RC-02 | NOTA en ASIGNACION debe estar entre 0 y 100 |
| RC-03 | NOTA_APROBACION en PENSUM debe estar entre 0 y 100 |
| RC-04 | ZONA_MINIMA en PENSUM debe estar entre 0 y 100 |
| RC-05 | CREDITOS en PENSUM debe ser > 0 |
| RC-06 | CREDITOS_CIERRE en PLAN debe ser > 0 |
| RC-07 | CICLO_INICIO y CICLO_FIN en PLAN deben ser 1 o 2 (semestre guatemalteco) |
| RC-08 | La fecha/año de fin del plan no puede ser anterior al inicio |
| RC-09 | HORA_FIN en PERIODO debe ser posterior a HORA_INICIO |
| RC-10 | CAPACIDAD en SALON debe ser > 0 |
| RC-11 | SUELDO_MENSUAL en DOCENTE debe ser > 0 |
| RC-12 | INGRESO_FAMILIAR en ESTUDIANTE debe ser ≥ 0 |
| RC-13 | CICLO en SECCION debe ser 1 o 2 |
| RC-14 | NUMERO_DIA en DIA debe estar entre 1 y 7 |
| RC-15 | OBLIGATORIEDAD en PENSUM debe ser un valor controlado ('S'/'N' o similar) |

---

## 2. Reglas implícitas importantes

Estas reglas no están escritas explícitamente en el enunciado pero se derivan del contexto del sistema:

| # | Regla implícita | Justificación |
|---|-----------------|---------------|
| RI-01 | Un estudiante debe estar **inscrito en una carrera** antes de asignarse a secciones de esa carrera | Flujo lógico del proceso académico |
| RI-02 | Una sección solo puede asignarse en **un salón que exista** en el edificio indicado | Integridad referencial (HORARIO → SALON compuesto) |
| RI-03 | Un mismo salón **no puede tener dos secciones** en el mismo día, período, año y ciclo | Conflicto físico de infraestructura |
| RI-04 | Un docente **no puede impartir dos secciones** en el mismo día, período, año y ciclo | Conflicto de agenda del docente |
| RI-05 | El curso prerrequisito **debe pertenecer al mismo plan** (PENSUM) para el que se define como prerrequisito | Coherencia curricular |
| RI-06 | Una sección tiene capacidad implícita del salón asignado; si hay múltiples salones por sección, el cupo es indefinido | Ambigüedad del enunciado |
| RI-07 | Para calcular el GPA correctamente, cada ASIGNACION debe saber a qué plan corresponde la nota | El enunciado especifica "basado en el pensum en que se tomó el curso" |

---

## 3. Check Constraints identificados

### Implementables con CHECK directo en Oracle

```
CK_ASIGNACION_ZONA
  Tabla:   ASIGNACION
  Lógica:  ZONA BETWEEN 0 AND 100
  Tipo:    CHECK
  Nota:    Aplicar también NOT NULL. Si zona es parcial antes del final, revisar si puede ser NULL temporal.

CK_ASIGNACION_NOTA
  Tabla:   ASIGNACION
  Lógica:  NOTA BETWEEN 0 AND 100
  Tipo:    CHECK
  Nota:    Puede ser NULL hasta que se registre el examen final.

CK_PENSUM_NOTA_APROBACION
  Tabla:   PENSUM
  Lógica:  NOTA_APROBACION BETWEEN 1 AND 100
  Tipo:    CHECK

CK_PENSUM_ZONA_MINIMA
  Tabla:   PENSUM
  Lógica:  ZONA_MINIMA BETWEEN 0 AND 100
  Tipo:    CHECK

CK_PENSUM_CREDITOS
  Tabla:   PENSUM
  Lógica:  CREDITOS > 0
  Tipo:    CHECK

CK_PENSUM_OBLIGATORIEDAD
  Tabla:   PENSUM
  Lógica:  OBLIGATORIEDAD IN ('S', 'N')   -- o IN ('SI', 'NO'), elegir uno
  Tipo:    CHECK
  Nota:    El tipo de dato debe ser CHAR(1) o VARCHAR2(2), NO VARCHAR2(25).

CK_PLAN_CICLO_INICIO
  Tabla:   PLAN
  Lógica:  CICLO_INICIO IN (1, 2)
  Tipo:    CHECK

CK_PLAN_CICLO_FIN
  Tabla:   PLAN
  Lógica:  CICLO_FIN IN (1, 2)
  Tipo:    CHECK

CK_PLAN_VIGENCIA
  Tabla:   PLAN
  Lógica:  (ANO_FIN > ANO_INICIO) OR (ANO_FIN = ANO_INICIO AND CICLO_FIN >= CICLO_INICIO)
  Tipo:    CHECK
  Nota:    Evita planes con fecha fin anterior a fecha inicio.

CK_PLAN_CREDITOS_CIERRE
  Tabla:   PLAN
  Lógica:  CREDITOS_CIERRE > 0
  Tipo:    CHECK

CK_SALON_CAPACIDAD
  Tabla:   SALON
  Lógica:  CAPACIDAD > 0
  Tipo:    CHECK

CK_SECCION_CICLO
  Tabla:   SECCION
  Lógica:  CICLO IN (1, 2)
  Tipo:    CHECK

CK_HORARIO_CICLO
  Tabla:   HORARIO
  Lógica:  SECCION_CICLO IN (1, 2)
  Tipo:    CHECK
  Nota:    Redundante si SECCION ya lo valida, pero útil como defensa en profundidad.

CK_DIA_NUMERO
  Tabla:   DIA
  Lógica:  ID_DIA BETWEEN 1 AND 7
  Tipo:    CHECK

CK_DOCENTE_SUELDO
  Tabla:   DOCENTE
  Lógica:  SUELDO_MENSUAL > 0
  Tipo:    CHECK

CK_ESTUDIANTE_INGRESO
  Tabla:   ESTUDIANTE
  Lógica:  INGRESO_FAMILIAR >= 0
  Tipo:    CHECK
  Nota:    Puede ser 0 (estudiante sin ingreso familiar declarado).
```

### Reglas que requieren TRIGGER (no implementables con CHECK simple)

```
TRIG_MAX_CARRERAS_POR_ESTUDIANTE
  Tabla:   INSCRIPCION (BEFORE INSERT / BEFORE UPDATE)
  Lógica:  Contar inscripciones activas del estudiante. Si COUNT >= 2, lanzar error.
  Tipo:    TRIGGER OBLIGATORIO
  Razón:   CHECK no puede referenciar agregados (COUNT) sobre la misma tabla.

TRIG_VALIDAR_PRERREQUISITOS
  Tabla:   ASIGNACION (BEFORE INSERT)
  Lógica:  Para cada prerrequisito del plan del estudiante para ese curso, verificar que exista
           una ASIGNACION aprobada previa. Si falta alguno, lanzar error.
  Tipo:    TRIGGER OBLIGATORIO
  Razón:   Requiere JOIN entre varias tablas.

TRIG_CONFLICTO_SALON
  Tabla:   HORARIO (BEFORE INSERT)
  Lógica:  Verificar que no exista otra fila con mismo SALON, DIA, PERIODO, ANO, CICLO.
  Tipo:    UNIQUE CONSTRAINT (alternativa más eficiente que trigger)
  Solución: UNIQUE(SALON_ID_SALON, SALON_EDIFICIO_ID_EDIFICIO, DIA_ID_DIA,
                    PERIODO_ID_PERIODO, SECCION_ANO, SECCION_CICLO)

TRIG_CONFLICTO_DOCENTE
  Tabla:   HORARIO (BEFORE INSERT)
  Lógica:  Verificar que el docente de la sección no esté ya asignado en mismo DIA/PERIODO/ANO/CICLO.
  Tipo:    TRIGGER OBLIGATORIO
  Razón:   Requiere JOIN con SECCION para obtener el DOCENTE_ID.

TRIG_CUPO_SECCION
  Tabla:   ASIGNACION (BEFORE INSERT)
  Lógica:  Verificar que la sección no esté cerrada y que el número de asignados no supere el cupo.
  Tipo:    TRIGGER OBLIGATORIO
  Razón:   Requiere COUNT sobre ASIGNACION y comparar con SECCION.CUPO.
  Prerequisito: SECCION debe tener columna ESTADO y CUPO (actualmente AUSENTES).
```

---

## 4. Cómo implementarlos en Oracle Data Modeler

### 4.1 Agregar un CHECK CONSTRAINT en una tabla

1. En el panel **Logical Model** o **Relational Model**, hacer **doble clic** sobre la tabla deseada (ej. PENSUM).
2. Se abre la ventana **"Table Properties"**.
3. Ir a la pestaña **"Constraints"** (columna izquierda del diálogo).
4. Hacer clic en el ícono **"+"** (Add Constraint) en la sección de constraints.
5. En el campo **"Name"**, escribir el nombre del constraint (ej. `CK_PENSUM_ZONA_MINIMA`).
6. En el campo **"Type"**, seleccionar **"Check"**.
7. En el campo **"Condition"** (o "Expression"), escribir la expresión:
   ```
   ZONA_MINIMA BETWEEN 0 AND 100
   ```
8. Hacer clic en **"OK"** para confirmar.
9. Guardar el modelo con **Ctrl+S**.

### 4.2 Nomenclatura correcta para constraints

```
CHECK:   CK_<TABLA>_<COLUMNA_O_DESCRIPCION>
         Ejemplo: CK_ASIGNACION_ZONA, CK_PLAN_CICLO_INICIO

UNIQUE:  UQ_<TABLA>_<COLUMNAS>
         Ejemplo: UQ_HORARIO_SALON_DIA_PERIODO

PRIMARY: PK_<TABLA>
         Ejemplo: PK_PENSUM

FOREIGN: FK_<TABLA_HIJO>_<TABLA_PADRE>
         Ejemplo: FK_PENSUM_PLAN, FK_SECCION_DOCENTE
```

### 4.3 Agregar un UNIQUE constraint (conflicto de salón)

1. Doble clic sobre tabla **HORARIO** → **"Table Properties"**.
2. Ir a **"Unique Constraints"** (pestaña separada o sección dentro de Constraints).
3. Hacer clic en **"+"**, nombrar: `UQ_HORARIO_SALON_DIA_PERIODO`.
4. Seleccionar las columnas que forman el unique:
   - `SALON_ID_SALON`
   - `SALON_EDIFICIO_ID_EDIFICIO`
   - `DIA_ID_DIA`
   - `PERIODO_ID_PERIODO`
   - `SECCION_ANO`
   - `SECCION_CICLO`
5. Confirmar con **OK**.

### 4.4 Verificar que aparece en el DDL generado

1. Menú **File** → **Export** → **DDL File...** (o botón "Generate DDL").
2. Revisar que el DDL incluye las cláusulas `CONSTRAINT CK_... CHECK (...)`.
3. Si no aparece, volver a verificar que el constraint fue guardado en la pestaña correcta.

### 4.5 Constraints que NO se pueden hacer en Data Modeler directamente

Los siguientes no pueden ser CHECK en Data Modeler porque requieren lógica procedimental:

| Constraint | Razón | Alternativa |
|-----------|-------|-------------|
| Máximo 2 carreras | Requiere COUNT sobre misma tabla | TRIGGER en DDL |
| Validación prerrequisitos | Requiere JOIN multi-tabla | TRIGGER en DDL |
| Conflicto horario docente | Requiere JOIN HORARIO→SECCION | TRIGGER en DDL |
| Cupo de sección | Requiere COUNT + comparación | TRIGGER en DDL |

Para estos, la estrategia es:
1. Modelar la estructura en Data Modeler (columnas y FKs).
2. Exportar el DDL.
3. Añadir manualmente los `CREATE OR REPLACE TRIGGER` al final del script.

---

## 5. Auditoría del modelo actual

### 5.1 Entidades – Estado de cada una

| Entidad | Estado | Observación |
|---------|--------|-------------|
| ESTUDIANTE | ✅ Correcto | Atributos completos: ID, NOMBRE, INGRESO_FAMILIAR, FECHA_NACIMIENTO |
| CARRERA | ⚠️ Incompleto | Falta UNIDAD_ACADEMICA como atributo propio (ver Hallazgo 1) |
| UNIDAD_ACADEMICA | ⚠️ Ambiguo | Modelada como entidad separada. El enunciado la describe como atributo de CARRERA. Puede justificarse por normalización pero requiere análisis (ver Hallazgo 1) |
| DOCENTE | ✅ Correcto | ID, NOMBRE, SUELDO_MENSUAL |
| CURSO | ✅ Correcto | ID, NOMBRE – identidad global correcta |
| EDIFICIO | ✅ Correcto | ID, NOMBRE |
| SALON | ✅ Correcto | PK compuesta (ID_SALON, EDIFICIO_ID_EDIFICIO), CAPACIDAD |
| PERIODO | ✅ Correcto | ID, HORA_INICIO, HORA_FIN – tipos VARCHAR2 (ver Hallazgo 9) |
| DIA | ✅ Correcto | ID, NOMBRE |
| PLAN | ⚠️ Incompleto | Tiene FK a JORNADA que no existe en el enunciado (ver Hallazgo 2) |
| JORNADA | ❌ Incorrecto | Entidad no requerida por el enunciado (ver Hallazgo 2) |
| SECCION | ❌ Incompleto | Falta ESTADO (abierta/cerrada) y CUPO (ver Hallazgo 3) |
| INSCRIPCION | ❌ Incompleto | Falta ESTADO (activa/cerrada) y FECHA_CIERRE (ver Hallazgo 4) |
| PENSUM | ⚠️ Incompleto | OBLIGATORIEDAD es VARCHAR2(25) sin CHECK; datos numéricos sin precisión decimal adecuada |
| PRERREQUISITO | ⚠️ Incorrecto | FK del curso prerrequisito va a CURSO global, no al PENSUM del mismo plan (ver Hallazgo 5) |
| ASIGNACION | ❌ Incompleto | No vincula al PLAN activo del estudiante (ver Hallazgo 6) |
| HORARIO | ⚠️ Incompleto | Falta UNIQUE constraint para evitar conflicto de salón (ver Hallazgo 7) |

### 5.2 Cardinalidades

| Relación | Estado | Observación |
|----------|--------|-------------|
| ESTUDIANTE N:M CARRERA (via INSCRIPCION) | ✅ Correcto | |
| CARRERA 1:N PLAN | ✅ Correcto | |
| PLAN N:M CURSO (via PENSUM) | ✅ Correcto | |
| CURSO auto-referencial (via PRERREQUISITO) | ✅ Correcto en estructura | Ver Hallazgo 5 |
| EDIFICIO 1:N SALON | ✅ Correcto | |
| CURSO 1:N SECCION | ✅ Correcto | |
| DOCENTE 1:N SECCION | ✅ Correcto | |
| ESTUDIANTE N:M SECCION (via ASIGNACION) | ✅ Correcto | |
| SECCION N:M (DIA+PERIODO+SALON) (via HORARIO) | ✅ Correcto | Relación 4-aria bien resuelta |
| PLAN → JORNADA | ❌ Incorrecto | No requerida por el enunciado |
| CARRERA → UNIDAD_ACADEMICA | ⚠️ Ambiguo | Ver Hallazgo 1 |

### 5.3 Claves primarias

| Tabla | PK en el modelo | Estado |
|-------|-----------------|--------|
| PLAN | (ID_PLAN, CARRERA_ID_CARRERA) | ✅ Correcto – clave compuesta |
| SALON | (ID_SALON, EDIFICIO_ID_EDIFICIO) | ✅ Correcto – entidad débil |
| SECCION | (ID_SECCION, CURSO_ID_CURSO, ANO, CICLO) | ✅ Correcto |
| PENSUM | (PLAN_ID_PLAN, PLAN_ID_CARRERA, CURSO_ID_CURSO) | ✅ Correcto |
| ASIGNACION | (SECCION_CICLO, SECCION_ID_SECCION, SECCION_CURSO_ID_CURSO, ESTUDIANTE_ID_ESTUDIANTE, SECCION_ANO) | ✅ Correcto |
| HORARIO | (SECCION_ID+coords, PERIODO, DIA, SALON_ID+EDIFICIO) | ✅ Correcto – relación 4-aria |
| PRERREQUISITO | (PENSUM keys, CURSO_ID_CURSO) | ⚠️ Ver Hallazgo 5 |

### 5.4 Tipos de datos detectados con problemas

| Tabla.Columna | Tipo actual | Tipo recomendado | Razón |
|---------------|-------------|-----------------|-------|
| PENSUM.OBLIGATORIEDAD | VARCHAR2(25) | CHAR(1) CHECK IN ('S','N') | Valor binario sin CHECK |
| PENSUM.CREDITOS | NUMBER(3) | NUMBER(3) | Sin precisión decimal, aceptable si entero |
| PENSUM.NOTA_APROBACION | NUMBER(3) | NUMBER(5,2) | Permite decimales (ej. 60.5) |
| PENSUM.ZONA_MINIMA | NUMBER(3) | NUMBER(5,2) | Permite decimales |
| ASIGNACION.ZONA | NUMBER(2) | NUMBER(5,2) | Máximo 2 dígitos es insuficiente (99 max, sin decimales) |
| ASIGNACION.NOTA | NUMBER(3) | NUMBER(5,2) | Permite decimales |
| PERIODO.HORA_INICIO | VARCHAR2(2) | VARCHAR2(5) CHECK LIKE... | Oracle no tiene tipo TIME; VARCHAR2(5) para 'HH:MM' o usar DATE |
| PERIODO.HORA_FIN | VARCHAR2(2) | VARCHAR2(5) | Misma razón |

---

## 6. Hallazgos críticos

### HALLAZGO 1 — UNIDAD_ACADEMICA como entidad separada (ambiguo)

- **Hallazgo:** El modelo crea UNIDAD_ACADEMICA como entidad independiente con PK ID_UNIDAD_A y NOMBRE, y CARRERA tiene FK hacia ella.
- **Evidencia:** El enunciado dice "Carreras identificadas por: código, nombre, **unidad académica**". UNIDAD_ACADEMICA es descrita como un atributo de CARRERA, no como una entidad con vida propia.
- **Impacto:** Moderado. La normalización es válida si múltiples carreras comparten la misma unidad académica (ej. tres carreras de la FIUSAC). Si no se justifica con datos reales, agrega complejidad innecesaria.
- **Solución recomendada:** Verificar si en el dominio del problema múltiples carreras comparten UNIDAD_ACADEMICA. Si sí → mantener como entidad (está bien). Si cada carrera tiene su propia unidad → regresarla a atributo de CARRERA. Documentar la decisión.

---

### HALLAZGO 2 — JORNADA: entidad no requerida por el enunciado ❌

- **Hallazgo:** El modelo incluye la entidad JORNADA (ID_JORNADA, NOMBRE) con FK desde PLAN.
- **Evidencia:** El enunciado **no menciona JORNADA en ningún punto**. El enunciado describe PLAN con: código de carrera, código de plan, nombre, año/ciclo inicio, año/ciclo fin, créditos requeridos. No hay referencia a jornada.
- **Impacto:** Alto. Se agrega un atributo no solicitado al PLAN, lo que puede ser penalizado como desvío del enunciado. Además, conceptualmente "jornada" aplica más a una SECCION (jornada matutina/vespertina/sabatina) que a un PLAN.
- **Solución recomendada:** Eliminar JORNADA del modelo. Si el evaluador la considera un enriquecimiento válido, justificarla explícitamente en la documentación, o moverla como atributo de SECCION (donde tiene más sentido semántico).

---

### HALLAZGO 3 — SECCION sin ESTADO ni CUPO ❌

- **Hallazgo:** La tabla SECCION solo tiene (ID_SECCION, ANO, CICLO, CURSO_ID_CURSO, DOCENTE_ID_DOCENTE). No tiene campo de estado ni de capacidad.
- **Evidencia:** El proyecto especifica: *"Una SECCION se cierra cuando alcanza capacidad o por acción explícita."* Esta regla no puede implementarse sin estos campos.
- **Impacto:** Alto. La regla de cierre de sección es completamente inoperable. Tampoco se puede controlar el cupo máximo de estudiantes por sección.
- **Solución recomendada:**
  ```
  Agregar a SECCION:
    ESTADO    VARCHAR2(10) NOT NULL DEFAULT 'ABIERTA'
               CONSTRAINT CK_SECCION_ESTADO CHECK (ESTADO IN ('ABIERTA', 'CERRADA'))
    CUPO      NUMBER(3)    NOT NULL
               CONSTRAINT CK_SECCION_CUPO CHECK (CUPO > 0)
  ```

---

### HALLAZGO 4 — INSCRIPCION sin estado de cierre de carrera ❌

- **Hallazgo:** INSCRIPCION solo tiene (FECHA_INSCRIPCION, ESTUDIANTE_ID_ESTUDIANTE, CARRERA_ID_CARRERA). No tiene campo para registrar si la carrera fue cerrada/completada.
- **Evidencia:** Las consultas 1 y 2 del enunciado piden estudiantes que **completaron** una carrera. Sin este dato, las consultas no pueden ejecutarse correctamente.
- **Impacto:** Crítico. Dos de las cuatro consultas requeridas fallan en el modelo actual. El concepto de "cierre de carrera" es central en el sistema.
- **Solución recomendada:**
  ```
  Agregar a INSCRIPCION:
    ESTADO        VARCHAR2(10) NOT NULL DEFAULT 'ACTIVA'
                   CONSTRAINT CK_INSCRIPCION_ESTADO CHECK (ESTADO IN ('ACTIVA', 'CERRADA'))
    FECHA_CIERRE  DATE NULL   -- NULL mientras no se haya cerrado
  ```

---

### HALLAZGO 5 — PRERREQUISITO: FK al curso prereq apunta a CURSO global, no al PENSUM ⚠️

- **Hallazgo:** En PRERREQUISITO, la FK `PRERREQUISITO_CURSO_FK` apunta a `CURSO(ID_CURSO)`. Esto solo valida que el curso prerrequisito exista globalmente, no que esté definido **en el mismo plan**.
- **Evidencia:** El enunciado establece que los prerrequisitos son **dependientes del plan**. Un curso puede ser prerrequisito en Plan A pero no en Plan B. Si el curso prerrequisito no está en el PENSUM del plan, se crea una regla de negocio inconsistente.
- **Impacto:** Moderado-Alto. Se pueden definir prerrequisitos de cursos que no pertenecen al plan, haciendo imposible que un estudiante los cumpla.
- **Solución recomendada:**
  ```
  Cambiar FK PRERREQUISITO_CURSO_FK para que apunte a:
  PENSUM(PLAN_ID_PLAN, PLAN_ID_CARRERA, CURSO_ID_CURSO)

  Esto requiere agregar columnas PLAN_ID_PLAN_PREREQ, PLAN_ID_CARRERA_PREREQ en PRERREQUISITO
  y un FK compuesto a PENSUM con esas tres columnas.
  ```
  Esto garantiza que tanto el curso principal como el prerrequisito existan en el mismo plan.

---

### HALLAZGO 6 — ASIGNACION no vincula al PLAN activo del estudiante ❌

- **Hallazgo:** ASIGNACION registra qué sección tomó un estudiante y sus calificaciones, pero **no registra bajo qué plan** se tomó el curso.
- **Evidencia:** El enunciado dice: *"El GPA se calcula basándose en el plan/pensum en que se tomó el curso."* Un estudiante puede cambiar de Plan 2000 a Plan 2011 dentro de la misma carrera. Las reglas de aprobación (nota mínima, zona mínima, créditos) son diferentes entre planes. Sin el vínculo al PLAN, no se puede determinar cuál regla aplicar.
- **Impacto:** Crítico. El GPA es incalculable correctamente. El cierre de carrera tampoco puede validarse. Las consultas 1, 2, 3 y 4 del enunciado dependen indirectamente de esta información.
- **Solución recomendada:**
  ```
  Agregar a ASIGNACION:
    PLAN_ID_PLAN     NUMBER(10) NOT NULL
    PLAN_ID_CARRERA  NUMBER(10) NOT NULL

  Con FK: FK_ASIGNACION_PENSUM → PENSUM(PLAN_ID_PLAN, PLAN_ID_CARRERA, SECCION_CURSO_ID_CURSO)
  ```
  Esto crea el triángulo: ASIGNACION sabe qué sección tomó el estudiante Y bajo qué plan se evaluó.

---

### HALLAZGO 7 — HORARIO sin UNIQUE constraint de conflicto de salón ⚠️

- **Hallazgo:** No existe ningún UNIQUE constraint en HORARIO que impida asignar dos secciones en el mismo salón, el mismo día, en el mismo período.
- **Evidencia:** El enunciado dice *"un salón puede ser usado por diferentes docentes en **diferentes horas**"* — esto implica que en la misma hora NO puede haber dos secciones en el mismo salón.
- **Impacto:** Moderado. La integridad física del scheduling no se garantiza. Dos secciones pueden quedar programadas en el mismo espacio al mismo tiempo.
- **Solución recomendada:**
  ```sql
  CONSTRAINT UQ_HORARIO_SALON_DIA_PERIODO
  UNIQUE (SALON_ID_SALON, SALON_EDIFICIO_ID_EDIFICIO, DIA_ID_DIA, PERIODO_ID_PERIODO, SECCION_ANO, SECCION_CICLO)
  ```

---

### HALLAZGO 8 — Ausencia total de CHECK constraints en el modelo ❌

- **Hallazgo:** El modelo relacional (Relational_1.png y DDL implícito) no define ningún CHECK constraint sobre ninguna tabla.
- **Evidencia:** 15 tablas, 0 constraints CHECK definidos. Las 15+ reglas candidatas identificadas en la Sección 3 están completamente ausentes.
- **Impacto:** Alto. La integridad de los datos depende enteramente de la aplicación. Valores como ZONA = -5, NOTA = 200, CICLO = 7, SUELDO_MENSUAL = -1000 serían aceptados por la base de datos.
- **Solución recomendada:** Implementar los 16 CHECK constraints listados en la Sección 3 usando Oracle Data Modeler (ver Sección 4).

---

### HALLAZGO 9 — PERIODO.HORA_INICIO y HORA_FIN como VARCHAR2(2) ⚠️

- **Hallazgo:** Los campos de hora del período tienen tipo VARCHAR2(2), que solo puede almacenar 2 caracteres (ej. "07"). No puede representar "07:30".
- **Evidencia:** Una hora con minutos requiere mínimo 5 caracteres ("07:30"). VARCHAR2(2) trunca la información.
- **Impacto:** Moderado. Imposible almacenar horarios con minutos. Además, no hay CHECK que valide el formato de hora.
- **Solución recomendada:**
  ```
  HORA_INICIO  VARCHAR2(5) CONSTRAINT CK_PERIODO_HORA_INICIO CHECK (REGEXP_LIKE(HORA_INICIO, '^\d{2}:\d{2}$'))
  HORA_FIN     VARCHAR2(5) CONSTRAINT CK_PERIODO_HORA_FIN    CHECK (REGEXP_LIKE(HORA_FIN,    '^\d{2}:\d{2}$'))
  ```
  Alternativa: usar `DATE` con hora fija (ej. 01-JAN-1900 HH24:MI) y comparar con TO_DATE.

---

### HALLAZGO 10 — Trigger de máximo 2 carreras no está documentado ni modelado ⚠️

- **Hallazgo:** La regla "máximo 2 carreras simultáneas por estudiante" no tiene representación en el modelo (no hay CHECK, no hay nota de trigger, no hay constraint visible).
- **Evidencia:** Es una de las reglas más importantes del enunciado ("students can take up to 2 careers simultaneously").
- **Impacto:** Alto en producción; sin este trigger, un estudiante puede inscribirse en 10 carreras.
- **Solución recomendada:** Documentar en el diccionario de datos y en los scripts DDL el trigger correspondiente:
  ```sql
  -- Referencia de diseño: implementar BEFORE INSERT ON INSCRIPCION
  -- Validar: SELECT COUNT(*) FROM INSCRIPCION WHERE ID_ESTUDIANTE = :NEW.ID_ESTUDIANTE
  -- Si COUNT >= 2, RAISE_APPLICATION_ERROR(-20001, 'Máximo 2 carreras por estudiante')
  ```

---

## 7. Recomendaciones prioritarias

Ordenadas de mayor a menor impacto en la evaluación del proyecto:

### Prioridad ALTA (afectan consultas requeridas o integridad fundamental)

1. **Agregar ESTADO y FECHA_CIERRE a INSCRIPCION** → Las consultas 1 y 2 dependen de saber si una carrera fue completada.

2. **Agregar PLAN_ID al ASIGNACION** → Sin este vínculo, el cálculo de GPA "por plan" es imposible. Afecta consultas 1, 2, 3 y 4.

3. **Agregar ESTADO y CUPO a SECCION** → Regla explícita del enunciado. Sin esto, el cierre de sección no puede implementarse.

4. **Eliminar o justificar JORNADA** → Entidad inventada que no aparece en el enunciado. Riesgo de penalización.

### Prioridad MEDIA (afectan integridad de datos)

5. **Implementar los 16 CHECK constraints** en Oracle Data Modeler (Sección 3). Especialmente: CICLO IN (1,2), ZONA/NOTA BETWEEN 0 AND 100, SUELDO > 0.

6. **Corregir FK de PRERREQUISITO** para apuntar a PENSUM en lugar de CURSO global.

7. **Agregar UNIQUE constraint en HORARIO** para evitar conflictos de salón.

8. **Corregir VARCHAR2(2) en PERIODO.HORA** a VARCHAR2(5) con CHECK de formato.

### Prioridad BAJA (calidad y buenas prácticas)

9. **Cambiar PENSUM.OBLIGATORIEDAD** de VARCHAR2(25) a CHAR(1) CHECK IN ('S', 'N').

10. **Revisar precisión decimal** en ZONA, NOTA, NOTA_APROBACION, ZONA_MINIMA → usar NUMBER(5,2).

11. **Documentar decisión sobre UNIDAD_ACADEMICA** (entidad vs atributo) con justificación explícita.

12. **Documentar el trigger de máximo 2 carreras** aunque no se implemente en Data Modeler directamente.

---

## Resumen ejecutivo

| Categoría | Hallazgos |
|-----------|-----------|
| ❌ Incorrecto / Crítico | 4 (JORNADA inventada, SECCION sin estado, INSCRIPCION sin cierre, ASIGNACION sin plan) |
| ⚠️ Incompleto / Requiere corrección | 5 (PRERREQUISITO FK, HORARIO sin UNIQUE, PERIODO tipo, OBLIGATORIEDAD, max 2 carreras) |
| ✅ Correcto | 8 (estructura general, mayoría de PKs, cardinalidades N:M, entidades base) |
| CHECK constraints implementados | 0 de 16 requeridos |
| Triggers documentados | 0 de 4 requeridos |

**El modelo tiene una base conceptual sólida y las relaciones N:M están bien identificadas. Los problemas críticos se concentran en reglas de negocio no implementadas y dos entidades problemáticas (JORNADA y el vínculo ASIGNACION-PLAN). Corregir los hallazgos 2, 4, 5 y 6 es suficiente para elevar significativamente la calidad del modelo.**
