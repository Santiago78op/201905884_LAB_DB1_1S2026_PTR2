# 📘 Análisis del Proyecto 1 – Fase 1  
## Sistema de Control Académico – Facultad de Ingeniería en Ciencias y Sistemas (USAC)

---

## Introducción
Este manual documenta las **entidades principales**, las **tablas intermedias** y la lógica conceptual del **Modelo Entidad–Relación (ER)** para el sistema de control académico de la Facultad de Ingeniería en Ciencias y Sistemas de la Universidad de San Carlos de Guatemala.

El objetivo es dejar claramente definida la función de cada tabla dentro del sistema, su propósito, sus atributos más relevantes y la forma en que participa en las relaciones del modelo.

---

## Objetivo General
Realizar el **análisis, diseño e implementación** de un sistema de información para el **control académico**, que permita llevar el registro integral de la población estudiantil de la Facultad de Ingeniería en Ciencias y Sistemas de la Universidad de San Carlos de Guatemala (USAC).

**Solicitantes:**
- Decana de la Facultad de Ingeniería en Ciencias y Sistemas – USAC  
- Directora de Control Académico – Facultad de Ingeniería en Ciencias y Sistemas – USAC  

---

## Objetivos Específicos
Este documento tiene como propósito:

- Identificar las tablas principales del sistema.
- Explicar cuáles tablas son intermedias o asociativas.
- Describir la función de cada tabla.
- Aclarar qué relaciones son **1:N** y cuáles son **N:M**.
- Servir de base para el **modelo ER**, el **modelo relacional** y posteriormente el **script SQL (DDL)**.


## Clasificación general de tablas
Dentro del sistema se identifican dos grandes grupos:

### Tablas principales
Son aquellas que representan entidades propias del negocio académico y que existen por sí mismas.

### Tablas intermedias o asociativas
Son aquellas que aparecen para resolver relaciones **muchos a muchos (N:M)** o para registrar hechos académicos específicos dentro del sistema.

---

## Alcance del Sistema
El sistema debe gestionar información relacionada con:

- Carreras
- Estudiantes
- Docentes
- Cursos
- Planes de estudio (Pensum)
- Inscripciones
- Asignaciones
- Horarios
- Infraestructura (Edificios y Salones)

---

## Modelo Conceptual
[Modelo Conceptual](Modelo_Conceptual.pdf)

## Tablas principales del sistema

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
| `nombre`          | Nombre del salón | VARCHAR(100) |
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

## Tablas intermedias o asociativas

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

## Relaciones que parecen N:M pero no deben modelarse así directamente

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

## Reglas de Negocio (CHECK Constraints)

### Aprobación de Curso
Se determina con datos de:
- **ASIGNACION**: zona, nota
- **PENSUM**: zona mínima, nota de aprobación
- **PRERREQUISITO**: cursos previos requeridos

- zona >= zona_minima
- nota >= nota_aprobacion
- cumplir prerrequisitos

---

### Promedios
- Solo se consideran cursos aprobados

---

### Cierre de Carrera
Se valida usando:
- **PLAN**
- **PENSUM**
- **ASIGNACION**
- **INSCRIPCION**

- Aprobar todos los cursos obligatorios
- Cumplir créditos requeridos
- Dentro del plan vigente

---

### Mejor Estudiante
Se calcula usando:
- **ASIGNACION**
- cursos aprobados
- promedio
- historial sin cursos perdidos

- Mejor promedio
- Sin cursos reprobados
