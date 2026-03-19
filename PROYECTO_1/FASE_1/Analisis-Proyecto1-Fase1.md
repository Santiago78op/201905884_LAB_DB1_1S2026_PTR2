# 📘 ANÁLISIS DEL PROYECTO 1 – FASE 1
## Sistema de Control Académico – USAC
### Facultad de Ingeniería en Ciencias y Sistemas

---

## 📋 Información del Documento

| Campo | Detalle |
|:------|:--------|
| **Sistema** | Control Académico - Facultad de Ingeniería en Ciencias y Sistemas (USAC) |
| **Proyecto** | Proyecto 1 - Fase 1 |
| **Carné** | 201905884 |
| **Solicitantes** | Decana de la Facultad; Directora de Control Académico |
| **Fecha de Elaboración** | Guatemala, marzo de 2026 |
| **Versión del Documento** | 1.0 |
| **Estado** | Análisis Completado |

---

## 📑 Tabla de Contenidos

### 📖 Contexto y Fundamentos
1. [Introducción](#introducción)
2. [Objetivo General](#objetivo-general)
3. [Objetivos Específicos](#objetivos-específicos)
4. [Alcance del Sistema](#alcance-del-sistema)
5. [Modelo Conceptual](#modelo-conceptual)

### 🗂️ Estructura de Base de Datos
6. [Clasificación General de Tablas](#clasificación-general-de-tablas)
7. [Tablas Principales del Sistema](#tablas-principales-del-sistema)
   - [EDIFICIO](#edificio)
   - [SALON](#salon)
   - [CARRERA](#carrera)
   - [DOCENTE](#docente)
   - [CURSO](#curso)
   - [PERIODO](#periodo)
   - [DIA](#dia)
   - [ESTUDIANTE](#estudiante)
   - [PLAN](#plan)
   - [SECCION](#seccion)

### 🔗 Relaciones y Tablas Intermedias
8. [Tablas Intermedias o Asociativas](#tablas-intermedias-o-asociativas)
   - [INSCRIPCION](#inscripcion)
   - [PENSUM](#pensum)
   - [PRERREQUISITO](#prerrequisito)
   - [ASIGNACION](#asignacion)
   - [HORARIO](#horario)

### ⚖️ Validaciones y Reglas
9. [Relaciones N:M Especiales](#relaciones-que-parecen-nm-pero-no-deben-modelarse-así-directamente)
10. [Reglas de Eliminación](#reglas-de-eliminacion)
11. [Reglas de Negocio](#reglas-de-negocio-check-constraints)

---

## 📖 Introducción

Este documento proporciona un **análisis exhaustivo y detallado** de la estructura de base de datos para el sistema de control académico de la Facultad de Ingeniería en Ciencias y Sistemas (USAC). 

### Propósito del Documento

El objetivo principal es documentar:
- **Entidades principales**: Las tablas que representan conceptos centrales del negocio académico
- **Tablas intermedias**: Las tablas asociativas que resuelven relaciones muchos-a-muchos (N:M)
- **Lógica conceptual**: El Modelo Entidad-Relación (ER) y sus implicaciones de diseño

Este análisis sirve como **base fundamental** para:
- ✅ Desarrollo del Modelo Conceptual ER
- ✅ Implementación del Modelo Relacional
- ✅ Generación de scripts SQL (DDL)
- ✅ Validación de la integridad del diseño
- ✅ Documentación técnica del sistema

---

## 🎯 Objetivo General

Realizar el **análisis, diseño e implementación** de un sistema de información integral para el **control académico y gestión administrativa**, que permita llevar el registro exhaustivo de la población estudiantil, docentes, carreras y recursos académicos de la Facultad de Ingeniería en Ciencias y Sistemas de la Universidad de San Carlos de Guatemala (USAC).

**Solicitud Oficial:**
- 📌 Decana de la Facultad de Ingeniería en Ciencias y Sistemas – USAC  
- 📌 Directora de Control Académico – Facultad de Ingeniería en Ciencias y Sistemas – USAC

---

## 📌 Objetivos Específicos

Este análisis se enfoca en lograr los siguientes objetivos específicos:

1. ✔️ **Identificar y documentar** las tablas principales del sistema académico
2. ✔️ **Clasificar y explicar** cuáles tablas son intermedias o asociativas
3. ✔️ **Describir la función** de cada tabla y su propósito en el sistema
4. ✔️ **Aclarar las relaciones**: diferenciar entre relaciones 1:N y relaciones N:M
5. ✔️ **Documentar cardinalidades**: especificar la multiplicidad de cada relación
6. ✔️ **Servir de base técnica** para el modelo ER, modelo relacional e implementación SQL (DDL)
7. ✔️ **Definir reglas de negocio**: documentar validaciones y constraints de integridad


---

## 🗂️ Clasificación General de Tablas

La estructura de la base de datos se divide en **dos categorías principales**, cada una con características y propósitos distintos:

### 📦 Tablas Principales (Entidades Independientes)

**Definición:** Son aquellas tablas que **representan entidades propias del negocio académico** y que existen de forma **independiente** sin depender de otras tablas.

**Características:**
- Representan conceptos fundamentales de la institución
- No dependen de otras tablas mediante claves foráneas
- Sus claves primarias son referenciadas por otras tablas
- Incluyen datos de configuración y maestros del sistema
- Ejemplos: EDIFICIO, CARRERA, DOCENTE, ESTUDIANTE, CURSO

**Importancia:** Estas tablas forman la **base estructural** del modelo relacional.

---

### 🔗 Tablas Intermedias o Asociativas

**Definición:** Son aquellas tablas que **aparecen para resolver relaciones muchos-a-muchos (N:M)** o para registrar **hechos académicos específicos** dentro del sistema.

**Características:**
- Contienen referencias (claves foráneas) a dos o más tablas padre
- Resuelven relaciones N:M entre entidades
- Pueden contener atributos propios del hecho que representan
- Permiten registrar detalles de transacciones académicas
- Ejemplos: INSCRIPCION, PENSUM, ASIGNACION, HORARIO

**Importancia:** Estas tablas son **esenciales** para modelar correctamente la complejidad de las relaciones académicas.

---

## 📚 Alcance del Sistema

El sistema de control académico debe gestionar de forma integral los siguientes aspectos:

### 🏢 Infraestructura Académica
- Edificios y ubicación física
- Salones y aulas disponibles
- Capacidades y recursos

### 👨‍🎓 Población Académica
- **Estudiantes**: Registro de población estudiantil, datos demográficos
- **Docentes**: Información de catedráticos, asignaciones y sueldos
- **Carreras**: Programas académicos ofrecidos

### 📖 Estructura Curricular
- Cursos y asignaturas
- Planes de estudio (Pensum)
- Secciones y ofertas académicas
- Horarios y calendarios

### 📊 Procesos Académicos
- Inscripciones de estudiantes
- Asignaciones a cursos
- Evaluaciones y calificaciones
- Registros académicos
- Control de prerrequisitos

---

## 📊 Modelo Conceptual

**Referencia:** [Modelo Conceptual ER](Modelo-Conceptual.md)

*Este documento complementa el modelo conceptual proporcionando análisis detallado de cada entidad y relación.*

---

## 🗂️ Tablas Principales del Sistema

Esta sección documenta detalladamente cada tabla principal, incluyendo su descripción, propósito, atributos y relaciones.

---

### EDIFICIO

### Descripción
Representa los edificios físicos de la facultad donde se encuentran los salones.

### Propósito
Permitir organizar la infraestructura física donde se imparten los cursos.

### Atributos principales

| Atributo           | Descripción             | Tipo    |
|--------------------|-------------------------|---------|
| `codigo_edificio`  | Identificador único del edificio (PK) | NUMERIC(10,0) |
| `nombre`          | Nombre del edificio | VARCHAR(100) |

### Relación principal
- Un **EDIFICIO** tiene uno o muchos **SALONES**.

### Cardinalidad
- **EDIFICIO 1 : N SALON**

---

### SALON

### Descripción
Representa los salones o aulas disponibles dentro de los edificios.

### Propósito
Registrar el espacio físico en el que se desarrollan las clases.

### Atributos principales
| Atributo           | Descripción             | Tipo    |
|--------------------|-------------------------|---------|
| `codigo_edificio`  | Identificador del edificio al que pertenece el salón (PK, FK) | NUMERIC(10,0) |
| `codigo_salon`     | Identificador único del salón (PK) | NUMERIC(10,0) |
| `nombre`          | Nombre del salón | VARCHAR(50) |
| `capacidad_maxima` | Capacidad máxima del salón | NUMERIC(5,0) |

### Observación
Según el enunciado, el salón se identifica por:
- código de edificio
- código de salón

Por lo tanto, su clave primaria es compuesta.

### Relación principal
- Un **SALON** pertenece a un **EDIFICIO**.
- Un **SALON** puede aparecer en muchos **HORARIOS**.

### Cardinalidad
- **SALON N : 1 EDIFICIO**
- **SALON 1 : N HORARIO**

---

### CARRERA

### Descripción
Representa cada carrera que ofrece la facultad.

### Propósito
Registrar las diferentes opciones académicas que puede cursar un estudiante.

### Atributos principales

| Atributo           | Descripción             | Tipo    |
|--------------------|-------------------------|---------|
| `codigo_carrera`   | Identificador único de la carrera (PK) | NUMERIC(10,0) |
| `nombre`           | Nombre de la carrera | VARCHAR(100) |
| `unidad_academica` | Unidad académica a la que pertenece la carrera | VARCHAR(100) |

### Relación principal
- Una **CARRERA** puede tener muchos **PLANES**.
- Una **CARRERA** puede tener muchos estudiantes mediante **INSCRIPCION**.

### Cardinalidad
- **CARRERA 1 : N PLAN**
- **CARRERA N : M ESTUDIANTE** (a través de INSCRIPCION)

---

### DOCENTE

### Descripción
Representa a los catedráticos de la facultad.

### Propósito
Llevar el control del personal docente asignado a secciones y cursos.

### Atributos principales

| Atributo           | Descripción             | Tipo    |
|--------------------|-------------------------|---------|
| `codigo_docente`   | Identificador único del docente (PK) | NUMERIC(10,0) |
| `nombre_completo`  | Nombre completo del docente | VARCHAR(100) |
| `sueldo_mensual`   | Sueldo mensual del docente | NUMERIC(10,2) |

### Relación principal
- Un **DOCENTE** puede impartir muchas **SECCIONES**.

### Cardinalidad
- **DOCENTE 1 : N SECCION**

---

### CURSO

### Descripción
Representa los cursos del sistema académico.

### Propósito
Definir las unidades académicas que forman parte de los planes de estudio.

### Atributos principales
| Atributo           | Descripción             | Tipo    |
|--------------------|-------------------------|---------|
| `codigo_curso`     | Identificador único del curso (PK) | NUMERIC(10,0) |
| `nombre`           | Nombre del curso | VARCHAR(100) |

### Relación principal
- Un **CURSO** puede aparecer en muchos **PLANES** mediante **PENSUM**.
- Un **CURSO** puede tener muchas **SECCIONES**.
- Un **CURSO** puede tener prerrequisitos.

### Cardinalidad
- **CURSO N : M PLAN** (a través de PENSUM)
- **CURSO 1 : N SECCION**
- **CURSO N : M CURSO** (prerrequisitos)

---

### PERIODO

### Descripción
Representa el bloque horario en que puede impartirse una clase.

### Propósito
Controlar la hora de inicio y fin de una actividad académica.

### Atributos principales
| Atributo           | Descripción             | Tipo    |
|--------------------|-------------------------|---------|
| `codigo_periodo`   | Identificador único del periodo (PK) | NUMERIC(10,0) |
| `hora_inicio`      | Hora de inicio del periodo | TIME |
| `hora_fin`        | Hora de fin del periodo | TIME |

### Relación principal
- Un **PERIODO** puede estar asociado a muchos **HORARIOS**.

### Cardinalidad
- **PERIODO 1 : N HORARIO**

---

### DIA

### Descripción
Representa los días de la semana en que puede impartirse un curso.

### Propósito
Permitir la programación académica por día.

### Atributos principales
| Atributo           | Descripción             | Tipo    |
|--------------------|-------------------------|---------|
| `codigo_dia`       | Identificador único del día (PK) | NUMERIC(10,0) |
| `nombre`           | Nombre del día | VARCHAR(20) |

### Relación principal
- Un **DIA** puede aparecer en muchos **HORARIOS**.

### Cardinalidad
- **DIA 1 : N HORARIO**

---

### ESTUDIANTE

### Descripción
Representa a los estudiantes registrados en el sistema.

### Propósito
Llevar el control de la población estudiantil.

### Atributos principales
| Atributo           | Descripción             | Tipo    |
|--------------------|-------------------------|---------|
| `carne`            | Identificador único del estudiante (PK) | NUMERIC(10,0) |
| `nombre_completo`  | Nombre completo del estudiante | VARCHAR(100) |
| `ingreso_familiar` | Ingreso familiar del estudiante | NUMERIC(15,2) |
| `fecha_nacimiento` | Fecha de nacimiento del estudiante | DATE |

### Relación principal
- Un **ESTUDIANTE** puede inscribirse en hasta dos carreras.
- Un **ESTUDIANTE** puede asignarse a muchos cursos mediante **ASIGNACION**.

### Cardinalidad
- **ESTUDIANTE N : M CARRERA** (a través de INSCRIPCION)
- **ESTUDIANTE N : M CURSO** (a través de ASIGNACION)

---

### PLAN

### Descripción
Representa un plan de estudios de una carrera.

### Propósito
Definir la vigencia y estructura académica que aplica a una carrera.

### Atributos principales
| Atributo           | Descripción             | Tipo    |
|--------------------|-------------------------|---------|
| `codigo_carrera`   | Identificador de la carrera a la que pertenece el plan (PK, FK) | NUMERIC(10,0) |
| `codigo_plan`      | Identificador único del plan (PK) | NUMERIC(10,0) |
| `nombre`           | Nombre del plan | VARCHAR(100) |
| `anio_inicio`      | Año de inicio del plan | NUMERIC(4,0) |
| `ciclo_inicio`     | Ciclo de inicio del plan | NUMERIC(1,0) |
| `anio_fin`         | Año de finalización del plan | NUMERIC(4,0) |
| `ciclo_fin`        | Ciclo de finalización del plan | NUMERIC(1,0) |
| `creditos_cierre`  | Créditos requeridos para cierre de carrera | NUMERIC(10,0) |

### Observación
Un plan depende directamente de una carrera, por lo que su clave es compuesta.

### Relación principal
- Una **CARRERA** tiene uno o varios **PLANES**.
- Un **PLAN** contiene muchos cursos mediante **PENSUM**.

### Cardinalidad
- **CARRERA 1 : N PLAN**
- **PLAN 1 : N CURSO** (a través de PENSUM)

---

### SECCION

### Descripción
Representa una sección específica de un curso en determinado año y ciclo.

### Propósito
Identificar la oferta concreta de un curso, asociada a un docente y a un periodo académico.

### Atributos principales
| Atributo           | Descripción             | Tipo    |
|--------------------|-------------------------|---------|
| `codigo_seccion`  | Identificador único de la sección (PK) | NUMERIC(10,0) |
| `codigo_curso`     | Identificador del curso al que pertenece la sección (FK) | NUMERIC(10,0) |
| `codigo_docente`   | Identificador del docente asignado a la sección (FK) | NUMERIC(10,0) |
| `anio`             | Año en que se ofrece la sección | NUMERIC(4,0) |
| `ciclo`            | Ciclo en que se ofrece la sección | NUMERIC(1,0) |

### Relación principal
- Una **SECCION** pertenece a un **CURSO**.
- Una **SECCION** está asignada a un **DOCENTE**.
- Una **SECCION** tiene uno o varios **HORARIOS**.
- Una **SECCION** puede tener muchos estudiantes mediante **ASIGNACION**.

### Importancia
La tabla **SECCION** es fundamental porque resuelve de forma más precisa la relación entre curso, docente y periodo académico.

### Cardinalidad
- **SECCION 1 : 1 CURSO**
- **SECCION 1 : 1 DOCENTE**
- **SECCION 1 : N HORARIO**
- **SECCION N : M ESTUDIANTE** (a través de ASIGNACION)

---

## 🔗 Tablas Intermedias o Asociativas

Esta sección documenta las tablas que implementan relaciones N:M y registran hechos académicos específicos.

---

### INSCRIPCION

### Tipo
Tabla intermedia / asociativa

### Relación que resuelve
**ESTUDIANTE ↔ CARRERA**

### Tipo de relación
**N:M**

### Descripción
Permite registrar en qué carrera o carreras está inscrito un estudiante.

### Justificación
- Un estudiante puede estar inscrito en hasta **2 carreras**.
- Una carrera puede tener **muchos estudiantes**.


### Atributos Principales
| Atributo           | Descripción             | Tipo    |
|--------------------|-------------------------|---------|
| `carne`            | Identificador del estudiante (PK, FK) | NUMERIC(10,0) |
| `codigo_carrera`   | Identificador de la carrera (PK, FK) | NUMERIC(10,0) |
| `fecha_inscripcion`| Fecha en que el estudiante se inscribió en la carrera | DATE |

### Observación
Además de resolver la relación N:M, esta tabla conserva un dato propio del hecho de inscripción: la fecha.

--- 

### PENSUM

### Tipo
Tabla intermedia / asociativa

### Relación que resuelve
**PLAN ↔ CURSO**

### Tipo de relación
**N:M**

### Descripción
Define qué cursos pertenecen a un plan de estudios y bajo qué reglas académicas deben cursarse.

### Justificación
- Un **PLAN** contiene muchos **CURSOS**.
- Un **CURSO** puede existir en más de un **PLAN**.

### Atributos Principales
| Atributo           | Descripción             | Tipo    |
|--------------------|-------------------------|---------|
| `codigo_carrera`   | Identificador de la carrera (PK, FK) | NUMERIC(10,0) |
| `codigo_plan`      | Identificador del plan (PK, FK) | NUMERIC(10,0) |
| `codigo_curso`     | Identificador del curso (PK, FK) | NUMERIC(10,0) |
| `obligatorio`      | Indica si el curso es obligatorio u opcional | BOOLEAN |
| `creditos`        | Créditos del curso | NUMERIC(10,0) |
| `nota_aprobacion` | Nota mínima para aprobar el curso | NUMERIC(5,2) |
| `zona_minima`       | Zona mínima para aprobar el curso | NUMERIC(5,2) |

### Importancia
Esta tabla es una de las más importantes del modelo, porque controla:
- obligatoriedad
- créditos
- nota mínima de aprobación
- zona mínima

Todo ello depende del plan vigente.

### Cardinalidad
- **PLAN N : M CURSO** (a través de PENSUM)

---

### PRERREQUISITO

### Tipo
Tabla asociativa especializada

### Relación que resuelve
**CURSO ↔ CURSO** dentro de un **PLAN**

### Tipo de relación
Autorrelación contextualizada

### Descripción
Registra qué curso debe aprobarse previamente para poder llevar otro curso dentro de un plan específico.

### Atributos Principales
| Atributo           | Descripción             | Tipo    |
|--------------------|-------------------------|---------|
| `codigo_carrera`   | Identificador de la carrera a la que pertenecen los cursos (PK, FK) | NUMERIC(10,0) |
| `codigo_plan`      | Identificador del plan al que pertenecen los cursos (PK, FK) | NUMERIC(10,0) |
| `codigo_curso`     | Identificador del curso que tiene el prerrequisito (PK, FK) | NUMERIC(10,0) |
| `codigo_curso_prerreq` | Identificador del curso que es prerrequisito (PK, FK) | NUMERIC(10,0) |

### Observación
No es una tabla intermedia N:M genérica, pero sí una tabla asociativa muy importante, porque modela una relación recursiva entre cursos dentro del pensum.

---

## ASIGNACION

### Tipo
Tabla intermedia / asociativa de negocio

### Relación que resuelve
**ESTUDIANTE ↔ SECCION/CURSO**

### Tipo de relación
**N:M**

### Descripción
Registra la asignación de un estudiante a un curso específico, en una sección, año y ciclo determinados.

### Justificación
- Un estudiante puede llevar varios cursos.
- Una sección puede tener muchos estudiantes.

### Atributos Principales
| Atributo           | Descripción             | Tipo    |
|--------------------|-------------------------|---------|
| `carne`            | Identificador del estudiante (PK, FK) | NUMERIC(10,0) |
| `codigo_curso`     | Identificador del curso (PK, FK) | NUMERIC(10,0) |
| `codigo_seccion`  | Identificador de la sección (PK, FK) | NUMERIC(10,0) |
| `anio`             | Año en que se ofrece la sección (PK) | NUMERIC(4,0) |
| `ciclo`            | Ciclo en que se ofrece la sección (PK) | NUMERIC(1,0) |
| `zona`             | Acumulado previo al examen final o evaluación continua | NUMERIC(5,2) |
| `nota`             | Resultado final del curso | NUMERIC(5,2) |

### Importancia
Aquí se registra el rendimiento académico del estudiante.

### Significado de atributos clave
- **zona**: acumulado previo al examen final o evaluación continua.
- **nota**: resultado final del curso.

### Cardinalidad
- **ESTUDIANTE N : M SECCION** (a través de ASIGNACION)

---

### HORARIO

### Tipo
Tabla asociativa / entidad de programación

### Relación que resuelve
**SECCION ↔ DIA / PERIODO / SALON**

### Tipo de relación
Entidad dependiente de la programación académica

### Descripción
Registra cuándo y dónde se imparte una sección específica.

### Atributos Principales
| Atributo           | Descripción             | Tipo    |
|--------------------|-------------------------|---------|
| `codigo_curso`     | Identificador del curso (PK, FK) | NUMERIC(10,0) |
| `codigo_seccion`  | Identificador de la sección (PK, FK) | NUMERIC(10,0) |
| `anio`             | Año en que se ofrece la sección (PK) | NUMERIC(4,0) |
| `ciclo`            | Ciclo en que se ofrece la sección (PK) | NUMERIC(1,0) |
| `codigo_periodo` | Identificador del periodo (FK) | NUMERIC(10,0) |
| `codigo_dia`       | Identificador del día (FK) | NUMERIC(10,0) |
| `codigo_edificio`  | Identificador del edificio (FK) | NUMERIC(10,0) |
| `codigo_salon`     | Identificador del salón (FK) | NUMERIC(10,0) |

### Observación importante
Aunque a veces se menciona “Curso ↔ Horario”, la interpretación correcta es que el horario no depende solo del curso, sino de una **SECCION** específica.

### Conclusión
Por ello, **HORARIO** no debe verse como una simple tabla intermedia N:M de curso, sino como una entidad propia que modela la programación académica.

### Cardinalidad
- **SECCION 1 : N HORARIO**
- **HORARIO N : 1 PERIODO**
- **HORARIO N : 1 DIA**
- **HORARIO N : 1 SALON**

---

## ⚖️ Relaciones que Parecen N:M pero No Deben Modelarse Así Directamente

Esta sección aclara patrones de relaciones que **podrían parecer N:M a primera vista**, pero que tienen **soluciones de diseño más apropiadas** para el contexto académico.

---

## DOCENTE ↔ CURSO

### Apariencia inicial
Podría parecer una relación N:M porque:
- un docente puede impartir varios cursos
- un curso puede ser impartido por varios docentes

### Solución correcta
No conviene resolverla con una tabla `DOCENTE_CURSO` independiente si ya existe **SECCION**.

### Razón
La relación real no es solo entre docente y curso, sino entre:
- docente
- curso
- año
- ciclo
- sección

### Tabla que resuelve la relación
**SECCION**

### Conclusión
La relación **DOCENTE ↔ CURSO** queda mejor modelada mediante **SECCION**.

---

## CURSO ↔ HORARIO

### Apariencia inicial
Podría parecer una relación N:M.

### Solución correcta
No debe modelarse como relación directa entre curso y horario.

### Razón
El horario se asigna a una **SECCION** concreta, no al curso en abstracto.

### Tabla que resuelve la relación
**HORARIO**, dependiente de **SECCION**

### Conclusión
La relación correcta es:
- **CURSO 1:N SECCION**
- **SECCION 1:N HORARIO**

---

## ✅ Reglas de Eliminacion

| Tabla hija    | FK hacia   | Regla recomendada   |
| ------------- | ---------- | ------------------- |
| SALON         | EDIFICIO   | CASCADE             |
| PLAN          | CARRERA    | CASCADE             |
| INSCRIPCION   | ESTUDIANTE | CASCADE o RESTRICT  |
| INSCRIPCION   | CARRERA    | CASCADE o RESTRICT  |
| PENSUM        | PLAN       | CASCADE             |
| PENSUM        | CURSO      | RESTRICT            |
| PRERREQUISITO | PENSUM     | CASCADE             |
| PRERREQUISITO | CURSO      | RESTRICT            |
| SECCION       | CURSO      | RESTRICT            |
| SECCION       | DOCENTE    | RESTRICT o SET NULL |
| HORARIO       | SECCION    | CASCADE             |
| HORARIO       | PERIODO    | RESTRICT            |
| HORARIO       | DIA        | RESTRICT            |
| HORARIO       | SALON      | RESTRICT            |
| ASIGNACION    | ESTUDIANTE | RESTRICT            |
| ASIGNACION    | SECCION    | RESTRICT            |


---

## ✅ Reglas de Negocio (CHECK Constraints)

Las siguientes reglas de negocio deben implementarse como constraints y validaciones en la base de datos para garantizar la integridad académica.

---

### 1. Aprobación de Curso
Se determina con datos de:
- **ASIGNACION**: zona, nota
- **PENSUM**: zona mínima, nota de aprobación
- **PRERREQUISITO**: cursos previos requeridos

- zona >= zona_minima
- nota >= nota_aprobacion
- cumplir prerrequisitos

---

### 2. Cálculo de Promedios

**Regla:** Solo se consideran cursos aprobados para el cálculo de promedios.

**Implementación:** Las consultas de promedio deben filtrar únicamente registros en ASIGNACION donde `nota >= nota_aprobacion`.

---

### 3. Cierre de Carrera
Se valida usando:
- **PLAN**
- **PENSUM**
- **ASIGNACION**
- **INSCRIPCION**

- Aprobar todos los cursos obligatorios
- Cumplir créditos requeridos
- Dentro del plan vigente

---

### 4. Identificación del Mejor Estudiante

**Criterios:**
- Mejor promedio académico
- Sin cursos reprobados en su historial
- Todos los cursos obligatorios aprobados

**Fuentes de Datos:**
- **ASIGNACION**: Para obtener notas y cursos aprobados
- **PENSUM**: Para identificar cursos obligatorios
- **INSCRIPCION**: Para determinar el historial académico

---

