# Análisis Conceptual — Registro Académico Facultad de Ingeniería USAC

**Curso:** Sistemas de Bases de Datos 1 — Sección N
**Carné:** 201905884
**Semestre:** Primero 2026

---

## 1. Resumen del Sistema

El sistema es un **registro académico** para la Facultad de Ingeniería de la USAC. Debe controlar la estructura curricular (carreras, planes, pensum, cursos, prerrequisitos), la planta docente (docentes, secciones asignadas), la infraestructura física (edificios, salones), la programación de clases (horarios por periodo y día), y el ciclo de vida académico del estudiante (inscripción a carrera, asignación de cursos, registro de notas y zona).

---

## 2. Objetivo del Sistema

Administrar de forma íntegra el control académico de la población estudiantil de la Facultad de Ingeniería: desde la inscripción del estudiante en una carrera y un plan, hasta la asignación de cursos por sección con su respectivo docente, horario, salón y registro de calificaciones.

---

## 3. Lista de Entidades

| # | Entidad | Tipo |
|---|---------|------|
| 1 | CARRERA | Principal |
| 2 | ESTUDIANTE | Principal |
| 3 | DOCENTE | Principal |
| 4 | CURSO | Principal |
| 5 | EDIFICIO | Principal |
| 6 | SALON | Principal (dependiente de EDIFICIO) |
| 7 | PERIODO | Principal (catálogo) |
| 8 | DIA | Principal (catálogo) |
| 9 | JORNADA | Principal (catálogo) |
| 10 | UNIDAD_ACADEMICA | Principal (catálogo) |
| 11 | PLAN | Principal (dependiente de CARRERA) |
| 12 | SECCION | Principal (dependiente de CURSO) |
| 13 | INSCRIPCION | Intermedia (ESTUDIANTE ↔ CARRERA) |
| 14 | PENSUM | Intermedia (PLAN ↔ CURSO) |
| 15 | PRERREQUISITO | Intermedia (PENSUM ↔ CURSO, autoreferencial) |
| 16 | ASIGNACION | Intermedia (ESTUDIANTE ↔ SECCION) |
| 17 | HORARIO | Intermedia (SECCION ↔ DIA ↔ PERIODO ↔ SALON) |

---

## 4. Desarrollo de Cada Entidad

---

### Entidad: CARRERA

- **Propósito:** Representa cada programa de estudios ofrecido por la Facultad. Un estudiante puede estar inscrito en máximo dos carreras de forma simultánea.
- **Clave primaria:** `CODIGO_CARRERA` — simple.

| Campo | Tipo sugerido | Descripción |
|-------|--------------|-------------|
| `CODIGO_CARRERA` | `VARCHAR2` | Identificador único de la carrera. Actúa como clave primaria. Ejemplo: `'SIS'`, `'ING-MEC'`. |
| `NOMBRE` | `VARCHAR2` | Nombre completo de la carrera. Ejemplo: `'Ingeniería en Ciencias y Sistemas'`. |
| `ID_UNIDAD_A` | `INTEGER` | FK → UNIDAD_ACADEMICA. Unidad académica a la que pertenece la carrera. Normalizado como entidad propia porque múltiples carreras pueden pertenecer a la misma unidad (ej. varias carreras dentro de la Escuela de Ingeniería). |

> **Decisión de diseño:** `UNIDAD_ACADEMICA` se modela como entidad independiente (no como atributo VARCHAR2 en CARRERA) para evitar redundancia cuando varias carreras pertenecen a la misma unidad. Esto es correcto por normalización (3FN).

---

### Entidad: ESTUDIANTE

- **Propósito:** Registra a cada alumno de la facultad con sus datos personales y académicos básicos.
- **Clave primaria:** `NUMERO_CARNET` — simple.

| Campo | Tipo sugerido | Descripción |
|-------|--------------|-------------|
| `NUMERO_CARNET` | `VARCHAR2` | Número de carné universitario. Identificador único del estudiante. Ejemplo: `'201905884'`. |
| `NOMBRE_COMPLETO` | `VARCHAR2` | Nombre y apellidos completos del estudiante. |
| `INGRESO_FAMILIAR` | `NUMBER` | Ingreso familiar mensual declarado por el estudiante, expresado en quetzales. Puede ser 0 (sin ingreso declarado). `CK_ESTUDIANTE_INGRESO: CHECK (INGRESO_FAMILIAR >= 0)`. |
| `FECHA_NACIMIENTO` | `DATE` | Fecha de nacimiento del estudiante. Permite calcular edad y validar requisitos de ingreso. |

---

### Entidad: DOCENTE

- **Propósito:** Representa a los catedráticos de la facultad, quienes imparten uno o más cursos en una o más secciones.
- **Clave primaria:** `CODIGO_DOCENTE` — simple.

| Campo | Tipo sugerido | Descripción |
|-------|--------------|-------------|
| `CODIGO_DOCENTE` | `VARCHAR2` | Identificador único del docente dentro de la facultad. Ejemplo: `'DOC-001'`. |
| `NOMBRE_COMPLETO` | `VARCHAR2` | Nombre y apellidos completos del docente. |
| `SUELDO_MENSUAL` | `NUMBER(10,2)` | Remuneración mensual del docente expresada en quetzales. Atributo propio del docente, no de la sección ni del curso. `CK_DOCENTE_SUELDO: CHECK (SUELDO_MENSUAL > 0)`. |

---

### Entidad: CURSO

- **Propósito:** Representa la unidad académica de estudio que puede estar incluida en uno o más planes de una o más carreras. Sus condiciones de aprobación varían según el plan, por lo que se definen en PENSUM.
- **Clave primaria:** `CODIGO_CURSO` — simple.

| Campo | Tipo sugerido | Descripción |
|-------|--------------|-------------|
| `CODIGO_CURSO` | `VARCHAR2` | Identificador único del curso a nivel de toda la facultad. Ejemplo: `'BD1'`, `'CALC1'`. |
| `NOMBRE` | `VARCHAR2` | Nombre descriptivo del curso. Ejemplo: `'Sistemas de Bases de Datos 1'`. |

---

### Entidad: EDIFICIO

- **Propósito:** Representa la infraestructura física que agrupa salones. Un edificio puede contener uno o más salones.
- **Clave primaria:** `CODIGO_EDIFICIO` — simple.

| Campo | Tipo sugerido | Descripción |
|-------|--------------|-------------|
| `CODIGO_EDIFICIO` | `VARCHAR2` | Identificador único del edificio dentro del campus. Ejemplo: `'T1'`, `'S11'`. |
| `NOMBRE` | `VARCHAR2` | Nombre o denominación del edificio. Ejemplo: `'Edificio T-1'`. No definido explícitamente en el enunciado, pero necesario para identificarlo de forma descriptiva. |

---

### Entidad: SALON

- **Propósito:** Representa cada aula o espacio físico donde se imparten clases. Pertenece a un edificio.
- **Clave primaria:** `(CODIGO_EDIFICIO, CODIGO_SALON)` — compuesta.

| Campo | Tipo sugerido | Descripción |
|-------|--------------|-------------|
| `CODIGO_EDIFICIO` | `VARCHAR2` | Parte 1 de la clave primaria compuesta. Referencia al edificio al que pertenece el salón. FK → EDIFICIO. |
| `CODIGO_SALON` | `VARCHAR2` | Parte 2 de la clave primaria compuesta. Identifica el salón dentro de su edificio. Ejemplo: `'101'`, `'A'`. |
| `CAPACIDAD` | `NUMBER(4)` | Número máximo de estudiantes que puede albergar el salón. Utilizado para controlar el aforo de secciones asignadas. `CK_SALON_CAPACIDAD: CHECK (CAPACIDAD > 0)`. |

---

### Entidad: PERIODO

- **Propósito:** Catálogo de franjas horarias en las que se imparten los cursos. Sus valores son reutilizados por múltiples registros de HORARIO.
- **Clave primaria:** `CODIGO_PERIODO` — simple.

| Campo | Tipo sugerido | Descripción |
|-------|--------------|-------------|
| `CODIGO_PERIODO` | `VARCHAR2` | Identificador único de la franja horaria. Ejemplo: `'P1'`, `'P2'`. |
| `HORA_INICIO` | `VARCHAR2(5)` | Hora en que comienza el periodo de clase. Formato `'HH:MM'`. Ejemplo: `'07:00'`. `CK_PERIODO_HORA_INICIO: CHECK (REGEXP_LIKE(HORA_INICIO, '^\d{2}:\d{2}$'))`. |
| `HORA_FIN` | `VARCHAR2(5)` | Hora en que termina el periodo de clase. Formato `'HH:MM'`. Ejemplo: `'08:50'`. `CK_PERIODO_HORA_FIN: CHECK (REGEXP_LIKE(HORA_FIN, '^\d{2}:\d{2}$'))`. |

> **Constraint de tabla:** `CK_PERIODO_VIGENCIA: CHECK (HORA_FIN > HORA_INICIO)` — la hora de fin debe ser posterior a la hora de inicio. En Oracle, siendo ambas `VARCHAR2`, este CHECK funciona correctamente solo si el formato `'HH:MM'` se respeta. Alternativa: usar `DATE` con fecha dummy (`01-JAN-2000 HH24:MI`) para comparación nativa.

---

### Entidad: DIA

- **Propósito:** Catálogo de los días de la semana en que se imparten cursos. Sus valores son reutilizados por múltiples registros de HORARIO.
- **Clave primaria:** `NUMERO_DIA` — simple.

| Campo | Tipo sugerido | Descripción |
|-------|--------------|-------------|
| `NUMERO_DIA` | `NUMBER(1)` | Identificador numérico del día de la semana. Ejemplo: `1` = Lunes, `7` = Domingo. `CK_DIA_NUMERO: CHECK (NUMERO_DIA BETWEEN 1 AND 7)`. |
| `NOMBRE` | `VARCHAR2` | Nombre del día. Ejemplo: `'Lunes'`, `'Martes'`. |

---

### Entidad: JORNADA

- **Propósito:** Catálogo de jornadas académicas en que se ofrecen los planes de estudio. Permite identificar si un plan corresponde a jornada matutina, vespertina, nocturna, sabatina, etc.
- **Clave primaria:** `ID_JORNADA` — simple (surrogate key).

| Campo | Tipo sugerido | Descripción |
|-------|--------------|-------------|
| `ID_JORNADA` | `INTEGER GENERATED BY DEFAULT ON NULL AS IDENTITY` | Identificador único de la jornada. PK surrogate. |
| `NOMBRE` | `VARCHAR2` | Nombre descriptivo de la jornada. Ejemplo: `'Matutina'`, `'Vespertina'`, `'Nocturna'`, `'Sabatina'`. |

> **Decisión de diseño:** JORNADA se modela como entidad catálogo independiente vinculada a PLAN. Conceptualmente también podría asociarse a SECCION (una sección específica puede tener jornada propia), pero se vincula al PLAN para reflejar que la jornada es una característica del plan de estudios como un todo (ej. "Plan Nocturno 2010"). Si en el futuro se necesita granularidad por sección, se puede agregar FK en SECCION también.

---

### Entidad: UNIDAD_ACADEMICA

- **Propósito:** Catálogo de unidades académicas (escuelas, departamentos) que agrupan carreras dentro de la Facultad de Ingeniería. Se normaliza como entidad propia para evitar redundancia cuando múltiples carreras pertenecen a la misma unidad.
- **Clave primaria:** `ID_UNIDAD_A` — simple (surrogate key).

| Campo | Tipo sugerido | Descripción |
|-------|--------------|-------------|
| `ID_UNIDAD_A` | `INTEGER GENERATED BY DEFAULT ON NULL AS IDENTITY` | Identificador único de la unidad académica. PK surrogate. |
| `NOMBRE` | `VARCHAR2` | Nombre de la unidad académica. Ejemplo: `'Escuela de Ciencias y Sistemas'`, `'Escuela de Ingeniería Mecánica'`. |

> **Decisión de diseño:** El enunciado describe `UNIDAD_ACADEMICA` como atributo de CARRERA. Se normaliza a entidad independiente porque en la FIUSAC existen múltiples carreras bajo la misma escuela (ej. Ingeniería Civil y Arquitectura pueden pertenecer a una misma unidad). Esto elimina la redundancia del nombre de la unidad en cada fila de CARRERA.

---

### Entidad: PLAN

- **Propósito:** Representa un plan de estudios vigente dentro de una carrera (ej. plan nocturno 2010, plan matutino 2020). Un mismo curso puede tener distintas condiciones de aprobación según el plan.
- **Clave primaria:** `(CODIGO_CARRERA, CODIGO_PLAN)` — compuesta. Entidad dependiente de CARRERA.

| Campo | Tipo sugerido | Descripción |
|-------|--------------|-------------|
| `CODIGO_CARRERA` | `VARCHAR2` | Parte 1 de la clave primaria. FK → CARRERA. Identifica a qué carrera pertenece este plan. |
| `CODIGO_PLAN` | `VARCHAR2` | Parte 2 de la clave primaria. Identifica el plan dentro de la carrera. Ejemplo: `'2010'`, `'2021'`. |
| `NOMBRE_PLAN` | `VARCHAR2` | Nombre descriptivo del plan. Ejemplo: `'Plan Matutino 2021'`. |
| `ANIO_INICIO` | `NUMBER(4)` | Año en que inicia la vigencia del plan. Ejemplo: `2010`. |
| `CICLO_INICIO` | `NUMBER(1)` | Ciclo del año de inicio en que comienza el plan. `CK_PLAN_CICLO_INICIO: CHECK (CICLO_INICIO IN (1, 2))`. |
| `ANIO_FIN` | `NUMBER(4)` | Año en que finaliza la vigencia del plan. Ejemplo: `2025`. |
| `CICLO_FIN` | `NUMBER(1)` | Ciclo del año de fin en que termina el plan. `CK_PLAN_CICLO_FIN: CHECK (CICLO_FIN IN (1, 2))`. |
| `CREDITOS_NECESARIOS_CIERRE` | `NUMBER(5)` | Total de créditos que un estudiante debe acumular para cerrar la carrera bajo este plan. `CK_PLAN_CREDITOS_CIERRE: CHECK (CREDITOS_NECESARIOS_CIERRE > 0)`. |
| `ID_JORNADA` | `INTEGER` | FK → JORNADA. Jornada académica bajo la que se imparte este plan. Ejemplo: jornada nocturna, matutina. |

> **Constraint de tabla:** `CK_PLAN_VIGENCIA: CHECK ((ANIO_FIN > ANIO_INICIO) OR (ANIO_FIN = ANIO_INICIO AND CICLO_FIN >= CICLO_INICIO))` — evita planes con fecha de fin anterior a la fecha de inicio.

---

### Entidad: SECCION

- **Propósito:** Representa una apertura específica de un curso en un año y ciclo determinado, asignada a un docente. Es la unidad a la que los estudiantes se asignan.
- **Clave primaria:** `(CODIGO_CURSO, CODIGO_SECCION, ANIO, CICLO)` — compuesta. Entidad dependiente de CURSO.

| Campo | Tipo sugerido | Descripción |
|-------|--------------|-------------|
| `CODIGO_CURSO` | `VARCHAR2` | Parte 1 de la clave primaria. FK → CURSO. Identifica a qué curso pertenece esta sección. |
| `CODIGO_SECCION` | `VARCHAR2` | Parte 2 de la clave primaria. Código que distingue la sección dentro de un mismo curso, año y ciclo. Ejemplo: `'A'`, `'B'`, `'N1'`. |
| `ANIO` | `NUMBER` | Parte 3 de la clave primaria. Año académico en que se imparte la sección. Ejemplo: `2026`. |
| `CICLO` | `NUMBER(1)` | Parte 4 de la clave primaria. Ciclo semestral en que se imparte la sección. `CK_SECCION_CICLO: CHECK (CICLO IN (1, 2))`. |
| `CODIGO_DOCENTE` | `VARCHAR2` | FK → DOCENTE. Catedrático asignado a impartir esta sección. Un docente puede tener múltiples secciones. |
| `CUPO` | `NUMBER(3)` | Capacidad máxima de estudiantes permitidos en la sección. `CK_SECCION_CUPO: CHECK (CUPO > 0)`. |
| `ESTADO` | `VARCHAR2(10)` | Estado actual de la sección. Valores: `'ABIERTA'` o `'CERRADA'`. `CK_SECCION_ESTADO: CHECK (ESTADO IN ('ABIERTA', 'CERRADA'))`. Se cierra automáticamente al alcanzar el cupo o por acción explícita. |

---

## 5. Lista de Relaciones

| # | Entidad Origen | Entidad Destino | Nombre de la Relación | Cardinalidad |
|---|---------------|-----------------|----------------------|-------------|
| 1 | ESTUDIANTE | CARRERA | INSCRIPCION | N:M |
| 2 | CARRERA | PLAN | tiene | 1:N |
| 3 | PLAN | CURSO | PENSUM | N:M |
| 4 | PENSUM | CURSO | PRERREQUISITO (autoreferencial sobre CURSO en el contexto del plan) | N:M |
| 5 | EDIFICIO | SALON | contiene | 1:N |
| 6 | CURSO | SECCION | abre sección de | 1:N |
| 7 | DOCENTE | SECCION | imparte | 1:N |
| 8 | ESTUDIANTE | SECCION | ASIGNACION | N:M |
| 9 | SECCION | SALON | HORARIO | N:M |
| 10 | SECCION | PERIODO | HORARIO | N:M |
| 11 | SECCION | DIA | HORARIO | N:M |
| 12 | UNIDAD_ACADEMICA | CARRERA | agrupa | 1:N |
| 13 | JORNADA | PLAN | clasifica | 1:N |

---

## 6. Cardinalidades Detalladas

**ESTUDIANTE — CARRERA** `(N:M)`
> Un estudiante puede inscribirse en una o dos carreras. Una carrera puede tener muchos estudiantes inscritos.

**CARRERA — PLAN** `(1:N)`
> Una carrera tiene uno o más planes de estudio. Un plan pertenece a exactamente una carrera (PK compuesta lo confirma).

**PLAN — CURSO** `(N:M)`
> Un plan contiene muchos cursos. Un mismo curso puede aparecer en múltiples planes y múltiples carreras con condiciones distintas.

**CURSO — CURSO** `(N:M autoreferencial, dentro del contexto PLAN)`
> Un curso puede tener cero o más cursos prerrequisito. Un curso puede ser prerrequisito de cero o más cursos. Esta relación siempre está acotada al contexto de un plan específico.

**EDIFICIO — SALON** `(1:N)`
> Un edificio contiene uno o más salones. Un salón pertenece a exactamente un edificio.

**CURSO — SECCION** `(1:N)`
> Un curso puede tener una o más secciones abiertas en distintos ciclos. Una sección pertenece a un único curso.

**DOCENTE — SECCION** `(1:N)`
> Un docente puede impartir una o más secciones. Cada sección tiene exactamente un docente asignado.

**ESTUDIANTE — SECCION** `(N:M)`
> Un estudiante puede asignarse a una o más secciones. Una sección puede tener muchos estudiantes asignados.

**SECCION — SALON / PERIODO / DIA** `(N:M combinado)`
> Una sección puede tener múltiples entradas de horario (distintos días, periodos o salones). Un salón puede ser usado por múltiples secciones en distintos horarios. Igual para periodo y día.

**UNIDAD_ACADEMICA — CARRERA** `(1:N)`
> Una unidad académica puede agrupar una o más carreras. Una carrera pertenece a exactamente una unidad académica. FK en CARRERA → UNIDAD_ACADEMICA.

**JORNADA — PLAN** `(1:N)`
> Una jornada puede corresponder a uno o más planes (ej. varios planes nocturnos en distintas carreras). Un plan tiene exactamente una jornada asignada. FK en PLAN → JORNADA.

---

## 7. Tablas Intermedias Necesarias

---

### Tabla intermedia: INSCRIPCION
**Resuelve:** ESTUDIANTE (N:M) CARRERA
**PK compuesta:** `(NUMERO_CARNET, CODIGO_CARRERA)`

| Campo | Tipo sugerido | FK apunta a | Descripción |
|-------|--------------|-------------|-------------|
| `NUMERO_CARNET` | `VARCHAR2` | → ESTUDIANTE | Parte 1 de la PK. Identifica al estudiante que se inscribe. |
| `CODIGO_CARRERA` | `VARCHAR2` | → CARRERA | Parte 2 de la PK. Identifica la carrera en la que se inscribe el estudiante. |
| `FECHA_INSCRIPCION` | `DATE` | — | Fecha en que el estudiante formalizó su inscripción en esta carrera. Atributo propio de la relación. |
| `ESTADO` | `VARCHAR2(10)` | — | Estado de la inscripción. Valores: `'ACTIVA'` o `'CERRADA'`. Requerido por las consultas de cierre de carrera. `CK_INSCRIPCION_ESTADO: CHECK (ESTADO IN ('ACTIVA', 'CERRADA'))`. |
| `FECHA_CIERRE` | `DATE` | — | Fecha en que el estudiante completó/cerró la carrera. `NULL` mientras la carrera esté activa. |

---

### Tabla intermedia: PENSUM
**Resuelve:** PLAN (N:M) CURSO
**PK compuesta:** `(CODIGO_CARRERA, CODIGO_PLAN, CODIGO_CURSO)`

| Campo | Tipo sugerido | FK apunta a | Descripción |
|-------|--------------|-------------|-------------|
| `CODIGO_CARRERA` | `VARCHAR2` | → PLAN (parte 1) | Parte 1 de la PK. Identifica la carrera a la que pertenece el plan. |
| `CODIGO_PLAN` | `VARCHAR2` | → PLAN (parte 2) | Parte 2 de la PK. Identifica el plan dentro de la carrera. |
| `CODIGO_CURSO` | `VARCHAR2` | → CURSO | Parte 3 de la PK. Identifica el curso que forma parte del pensum. |
| `OBLIGATORIEDAD` | `CHAR(1)` | — | Indica si el curso es obligatorio u optativo en este plan. Valores: `'S'` (obligatorio) o `'N'` (optativo). `CK_PENSUM_OBLIGATORIEDAD: CHECK (OBLIGATORIEDAD IN ('S', 'N'))`. |
| `CREDITOS` | `NUMBER(3)` | — | Créditos académicos que el estudiante obtiene al ganar este curso en este plan. `CK_PENSUM_CREDITOS: CHECK (CREDITOS > 0)`. |
| `NOTA_APROBACION` | `NUMBER(5,2)` | — | Nota mínima para aprobar el examen final en este curso bajo este plan. Permite decimales (ej. `60.5`). `CK_PENSUM_NOTA_APROBACION: CHECK (NOTA_APROBACION BETWEEN 1 AND 100)`. |
| `ZONA_MINIMA` | `NUMBER(5,2)` | — | Zona mínima requerida para tener derecho al examen final en este plan. `CK_PENSUM_ZONA_MINIMA: CHECK (ZONA_MINIMA BETWEEN 0 AND 100)`. |

---

### Tabla intermedia: PRERREQUISITO
**Resuelve:** autoreferencia N:M de CURSO dentro del contexto de un PLAN
**PK compuesta:** `(CODIGO_CARRERA, CODIGO_PLAN, CODIGO_CURSO, CODIGO_CURSO_PRERREQUISITO)`

| Campo | Tipo sugerido | FK apunta a | Descripción |
|-------|--------------|-------------|-------------|
| `CODIGO_CARRERA` | `VARCHAR2` | → PENSUM (parte 1) | Parte 1 de la PK. Identifica la carrera del plan al que pertenece esta regla de prerrequisito. |
| `CODIGO_PLAN` | `VARCHAR2` | → PENSUM (parte 2) | Parte 2 de la PK. Identifica el plan al que pertenece esta regla de prerrequisito. |
| `CODIGO_CURSO` | `VARCHAR2` | → PENSUM (parte 3) | Parte 3 de la PK. El curso que tiene definido un prerrequisito en este plan. |
| `CODIGO_CURSO_PRERREQUISITO` | `VARCHAR2` | → CURSO | Parte 4 de la PK. El curso que debe haberse aprobado previamente para poder llevar `CODIGO_CURSO` en este plan. |

> **Nota de diseño:** `CODIGO_CURSO_PRERREQUISITO` referencia directamente a CURSO (no a PENSUM), dado que el prerrequisito es un curso identificable de forma global. Permite que un curso tenga múltiples prerrequisitos dentro del mismo plan.

---

### Tabla intermedia: ASIGNACION
**Resuelve:** ESTUDIANTE (N:M) SECCION
**PK compuesta:** `(NUMERO_CARNET, CODIGO_CURSO, CODIGO_SECCION, ANIO, CICLO)`

| Campo | Tipo sugerido | FK apunta a | Descripción |
|-------|--------------|-------------|-------------|
| `NUMERO_CARNET` | `VARCHAR2` | → ESTUDIANTE | Parte 1 de la PK. Identifica al estudiante que se asignó al curso. |
| `CODIGO_CURSO` | `VARCHAR2` | → SECCION (parte 1) | Parte 2 de la PK. Identifica el curso de la sección asignada. |
| `CODIGO_SECCION` | `VARCHAR2` | → SECCION (parte 2) | Parte 3 de la PK. Identifica la sección específica dentro del curso. |
| `ANIO` | `NUMBER(4)` | → SECCION (parte 3) | Parte 4 de la PK. Año académico en que el estudiante realizó la asignación. |
| `CICLO` | `NUMBER(1)` | → SECCION (parte 4) | Parte 5 de la PK. Ciclo semestral en que el estudiante realizó la asignación. `CK_ASIGNACION_CICLO: CHECK (CICLO IN (1, 2))`. |
| `ZONA` | `NUMBER(5,2)` | — | Punteo parcial acumulado obtenido por el estudiante durante el ciclo (laboratorios, parciales, etc.). `CK_ASIGNACION_ZONA: CHECK (ZONA BETWEEN 0 AND 100)`. |
| `NOTA` | `NUMBER(5,2)` | — | Nota obtenida por el estudiante en el examen final del curso. `CK_ASIGNACION_NOTA: CHECK (NOTA BETWEEN 0 AND 100)`. |
| `CODIGO_CARRERA` | `VARCHAR2` | → PENSUM (parte 1) | FK hacia PENSUM. Identifica la carrera del plan bajo el que se evaluó este curso. Necesario para calcular el GPA correctamente. |
| `CODIGO_PLAN` | `VARCHAR2` | → PENSUM (parte 2) | FK hacia PENSUM. Identifica el plan específico bajo el que se tomó el curso. Un estudiante puede cambiar de plan y las reglas de aprobación (nota mínima, zona mínima) varían por plan. |

---

### Tabla intermedia: HORARIO
**Resuelve:** SECCION (N:M) DIA + PERIODO + SALON simultáneamente
**PK compuesta:** `(CODIGO_CURSO, CODIGO_SECCION, ANIO, CICLO, CODIGO_PERIODO, NUMERO_DIA, CODIGO_EDIFICIO, CODIGO_SALON)`

| Campo | Tipo sugerido | FK apunta a | Descripción |
|-------|--------------|-------------|-------------|
| `CODIGO_CURSO` | `VARCHAR2` | → SECCION (parte 1) | Parte 1 de la PK. Identifica el curso de la sección programada. |
| `CODIGO_SECCION` | `VARCHAR2` | → SECCION (parte 2) | Parte 2 de la PK. Identifica la sección dentro del curso. |
| `ANIO` | `NUMBER(4)` | → SECCION (parte 3) | Parte 3 de la PK. Año académico de la sección programada. |
| `CICLO` | `NUMBER(1)` | → SECCION (parte 4) | Parte 4 de la PK. Ciclo semestral de la sección programada. `CK_HORARIO_CICLO: CHECK (CICLO IN (1, 2))`. |
| `CODIGO_PERIODO` | `VARCHAR2` | → PERIODO | Parte 5 de la PK. Franja horaria (hora inicio–fin) en que se imparte la clase. |
| `NUMERO_DIA` | `NUMBER(1)` | → DIA | Parte 6 de la PK. Día de la semana en que se imparte la clase. |
| `CODIGO_EDIFICIO` | `VARCHAR2` | → SALON (parte 1) | Parte 7 de la PK. Edificio donde se imparte la clase. |
| `CODIGO_SALON` | `VARCHAR2` | → SALON (parte 2) | Parte 8 de la PK. Salón específico dentro del edificio donde se imparte la clase. |

> **Nota de diseño:** Esta tabla resuelve una relación de grado 4 (SECCION, DIA, PERIODO, SALON). No puede descomponerse sin perder el significado completo de "en qué día, en qué hora y en qué salón se imparte esta sección".

> **Constraint UNIQUE:** `UQ_HORARIO_SALON_DIA_PERIODO: UNIQUE (CODIGO_EDIFICIO, CODIGO_SALON, NUMERO_DIA, CODIGO_PERIODO, ANIO, CICLO)` — impide que dos secciones ocupen el mismo salón en el mismo día, periodo, año y ciclo.

---

## 8. Observaciones de Diseño Conceptual

1. **PLAN es dependiente de CARRERA.** Su PK compuesta `(CODIGO_CARRERA, CODIGO_PLAN)` lo convierte en una entidad débil que no existe fuera del contexto de una carrera.

2. **PENSUM es el núcleo del modelo.** Actúa como resolutor N:M entre PLAN y CURSO, pero además transporta los atributos académicos más críticos del sistema (créditos, nota de aprobación, zona mínima, obligatoriedad). No es una tabla de paso vacía.

3. **PRERREQUISITO depende de PENSUM, no directamente de CURSO.** Un curso es prerrequisito solo dentro del contexto de un plan específico de una carrera. La FK hacia PENSUM `(CODIGO_CARRERA, CODIGO_PLAN, CODIGO_CURSO)` es obligatoria para garantizar la integridad de esa dependencia.

4. **SECCION tiene PK compuesta de cuatro campos.** El enunciado la referencia siempre con curso + sección + año + ciclo. Esta composición refleja que una sección es una apertura temporal de un curso, y la misma sección "A" del mismo curso puede existir en distintos años y ciclos. Adicionalmente, SECCION requiere `ESTADO` y `CUPO` para implementar la regla de cierre de sección.

5. **HORARIO es una relación de grado 4.** Involucra SECCION, DIA, PERIODO y SALON al mismo tiempo. Cualquier simplificación (separar el día del periodo, o el salón del horario) rompe la semántica del enunciado. Requiere UNIQUE constraint `(SALON, DIA, PERIODO, ANO, CICLO)` para evitar conflictos físicos de aula.

6. **INSCRIPCION lleva la fecha como atributo propio.** La relación entre ESTUDIANTE y CARRERA no es solo una asociación, tiene un dato temporal propio. Adicionalmente, se agregan `ESTADO` (`'ACTIVA'/'CERRADA'`) y `FECHA_CIERRE` porque las consultas del enunciado requieren saber si un estudiante completó su carrera.

7. **ASIGNACION registra el resultado académico y el plan activo.** La zona y la nota son atributos de la asignación. Se agrega la referencia al plan `(CODIGO_CARRERA, CODIGO_PLAN)` porque el GPA y las reglas de aprobación dependen del plan bajo el que se cursó la sección, no del plan actual del estudiante.

8. **EDIFICIO debe tratarse como entidad independiente**, aunque el enunciado solo lo mencione como parte de la identificación del SALON. Su existencia como entidad propia permite asociar un salón a su edificio sin redundar el código del edificio como dato aislado en HORARIO.

9. **UNIDAD_ACADEMICA se normaliza como entidad catálogo** en lugar de ser un atributo VARCHAR2 de CARRERA. Esto evita redundancia cuando múltiples carreras pertenecen a la misma unidad (ej. Escuela de Ciencias y Sistemas alberga varias carreras). La FK `ID_UNIDAD_A` en CARRERA mantiene la integridad referencial.

10. **JORNADA se normaliza como entidad catálogo** vinculada a PLAN para identificar si un plan es nocturno, matutino, sabatino, etc. Se coloca en PLAN (no en SECCION) porque la jornada es una propiedad del plan de estudios completo. Si en el futuro se necesita jornada a nivel de sección individual, se puede agregar FK en SECCION también.

---

## 9. Correcciones Pendientes en el Modelo (Diccionario y Data Modeler)

> Estas correcciones deben aplicarse al modelo Oracle Data Modeler (PT1.dmd) y regenerarse el Diccionario de Datos.

| # | Tabla | Corrección | Impacto |
|---|-------|------------|---------|
| C-01 | SECCION | Agregar columnas `ESTADO VARCHAR2(10)` y `CUPO NUMBER(3)` | Alto — regla de cierre de sección inoperable sin estos campos |
| C-02 | INSCRIPCION | Agregar columnas `ESTADO VARCHAR2(10)` y `FECHA_CIERRE DATE` | Crítico — consultas de cierre de carrera fallan sin estos campos |
| C-03 | ASIGNACION | Agregar columnas `CODIGO_CARRERA` y `CODIGO_PLAN` con FK → PENSUM | Crítico — GPA por plan incalculable sin el vínculo al plan |
| C-04 | PENSUM.OBLIGATORIEDAD | Cambiar de `VARCHAR2(25)` a `CHAR(1)` con `CHECK IN ('S','N')` | Medio — integridad de datos |
| C-05 | PERIODO.HORA_INICIO / HORA_FIN | Cambiar de `VARCHAR2(2)` a `VARCHAR2(5)` con CHECK de formato `'HH:MM'` | Medio — imposible almacenar horarios con minutos |
| C-06 | Todas las tablas | Implementar los 16 CHECK constraints identificados en la auditoría | Alto — sin CHECKs la BD acepta valores inválidos |
| C-07 | PENSUM.ZONA/NOTA | Cambiar `NUMBER(3)` y `NUMBER(2)` a `NUMBER(5,2)` para permitir decimales | Bajo — precisión de calificaciones |
