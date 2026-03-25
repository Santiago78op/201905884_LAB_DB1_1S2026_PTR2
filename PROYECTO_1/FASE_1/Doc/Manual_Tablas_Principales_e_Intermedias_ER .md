# 📘 Manual de Entidades, Tablas Principales e Intermedias
## Sistema de Control Académico – Facultad de Ingeniería en Ciencias y Sistemas, USAC

---

## 1. Introducción

Este manual documenta las **entidades principales**, las **tablas intermedias** y la lógica conceptual del **Modelo Entidad–Relación (ER)** para el sistema de control académico de la Facultad de Ingeniería en Ciencias y Sistemas de la Universidad de San Carlos de Guatemala.

El objetivo es dejar claramente definida la función de cada tabla dentro del sistema, su propósito, sus atributos más relevantes y la forma en que participa en las relaciones del modelo.

---

## 2. Objetivo del manual

Este documento tiene como propósito:

- Identificar las tablas principales del sistema.
- Explicar cuáles tablas son intermedias o asociativas.
- Describir la función de cada tabla.
- Aclarar qué relaciones son **1:N** y cuáles son **N:M**.
- Servir de base para el **modelo ER**, el **modelo relacional** y posteriormente el **script SQL (DDL)**.

---

## 3. Clasificación general de tablas

Dentro del sistema se identifican dos grandes grupos:

### 3.1 Tablas principales
Son aquellas que representan entidades propias del negocio académico y que existen por sí mismas.

### 3.2 Tablas intermedias o asociativas
Son aquellas que aparecen para resolver relaciones **muchos a muchos (N:M)** o para registrar hechos académicos específicos dentro del sistema.

---

# 4. Tablas principales del sistema

---

## 4.1 EDIFICIO

### Descripción
Representa los edificios físicos de la facultad donde se encuentran los salones.

### Propósito
Permitir organizar la infraestructura física donde se imparten los cursos.

### Atributos principales
- `codigo_edificio` **(PK)**
- `nombre`

### Relación principal
- Un **EDIFICIO** tiene uno o muchos **SALONES**.

### Cardinalidad
- **EDIFICIO 1 : N SALON**

---

## 4.2 SALON

### Descripción
Representa los salones o aulas disponibles dentro de los edificios.

### Propósito
Registrar el espacio físico en el que se desarrollan las clases.

### Atributos principales
- `codigo_edificio` **(PK, FK)**
- `codigo_salon` **(PK)**
- `nombre`
- `capacidad_maxima`

### Observación
Según el enunciado, el salón se identifica por:
- código de edificio
- código de salón

Por lo tanto, su clave primaria es compuesta.

### Relación principal
- Un **SALON** pertenece a un **EDIFICIO**.
- Un **SALON** puede aparecer en muchos **HORARIOS**.

---

## 4.3 CARRERA

### Descripción
Representa cada carrera que ofrece la facultad.

### Propósito
Registrar las diferentes opciones académicas que puede cursar un estudiante.

### Atributos principales
- `codigo_carrera` **(PK)**
- `nombre`
- `unidad_academica`

### Relación principal
- Una **CARRERA** puede tener muchos **PLANES**.
- Una **CARRERA** puede tener muchos estudiantes mediante **INSCRIPCION**.

---

## 4.4 DOCENTE

### Descripción
Representa a los catedráticos de la facultad.

### Propósito
Llevar el control del personal docente asignado a secciones y cursos.

### Atributos principales
- `codigo_docente` **(PK)**
- `nombre_completo`
- `sueldo_mensual`

### Relación principal
- Un **DOCENTE** puede impartir muchas **SECCIONES**.

---

## 4.5 CURSO

### Descripción
Representa los cursos del sistema académico.

### Propósito
Definir las unidades académicas que forman parte de los planes de estudio.

### Atributos principales
- `codigo_curso` **(PK)**
- `nombre`

### Relación principal
- Un **CURSO** puede aparecer en muchos **PLANES** mediante **PENSUM**.
- Un **CURSO** puede tener muchas **SECCIONES**.
- Un **CURSO** puede tener prerrequisitos.

---

## 4.6 PERIODO

### Descripción
Representa el bloque horario en que puede impartirse una clase.

### Propósito
Controlar la hora de inicio y fin de una actividad académica.

### Atributos principales
- `codigo_periodo` **(PK)**
- `hora_inicio`
- `hora_fin`

### Relación principal
- Un **PERIODO** puede estar asociado a muchos **HORARIOS**.

---

## 4.7 DIA

### Descripción
Representa los días de la semana en que puede impartirse un curso.

### Propósito
Permitir la programación académica por día.

### Atributos principales
- `codigo_dia` **(PK)**
- `nombre`

### Relación principal
- Un **DIA** puede aparecer en muchos **HORARIOS**.

---

## 4.8 ESTUDIANTE

### Descripción
Representa a los estudiantes registrados en el sistema.

### Propósito
Llevar el control de la población estudiantil.

### Atributos principales
- `carne` **(PK)**
- `nombre_completo`
- `ingreso_familiar`
- `fecha_nacimiento`

### Relación principal
- Un **ESTUDIANTE** puede inscribirse en hasta dos carreras.
- Un **ESTUDIANTE** puede asignarse a muchos cursos mediante **ASIGNACION**.

---

## 4.9 PLAN

### Descripción
Representa un plan de estudios de una carrera.

### Propósito
Definir la vigencia y estructura académica que aplica a una carrera.

### Atributos principales
- `codigo_carrera` **(PK, FK)**
- `codigo_plan` **(PK)**
- `nombre`
- `anio_inicio`
- `ciclo_inicio`
- `anio_fin`
- `ciclo_fin`
- `creditos_cierre`

### Observación
Un plan depende directamente de una carrera, por lo que su clave es compuesta.

### Relación principal
- Una **CARRERA** tiene uno o varios **PLANES**.
- Un **PLAN** contiene muchos cursos mediante **PENSUM**.

---

## 4.10 SECCION

### Descripción
Representa una sección específica de un curso en determinado año y ciclo.

### Propósito
Identificar la oferta concreta de un curso, asociada a un docente y a un periodo académico.

### Atributos principales
- `codigo_seccion` **(PK)**
- `codigo_curso` **(FK)**
- `codigo_docente` **(FK)**
- `anio`
- `ciclo`

### Relación principal
- Una **SECCION** pertenece a un **CURSO**.
- Una **SECCION** está asignada a un **DOCENTE**.
- Una **SECCION** tiene uno o varios **HORARIOS**.
- Una **SECCION** puede tener muchos estudiantes mediante **ASIGNACION**.

### Importancia
La tabla **SECCION** es fundamental porque resuelve de forma más precisa la relación entre curso, docente y periodo académico.

---

# 5. Tablas intermedias o asociativas

Estas tablas existen para resolver relaciones N:M o para registrar eventos académicos del sistema.

---

## 5.1 INSCRIPCION

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

### Atributos principales
- `carne` **(PK, FK)**
- `codigo_carrera` **(PK, FK)**
- `fecha_inscripcion`

### Observación
Además de resolver la relación N:M, esta tabla conserva un dato propio del hecho de inscripción: la fecha.

---

## 5.2 PENSUM

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

### Atributos principales
- `codigo_carrera` **(PK, FK)**
- `codigo_plan` **(PK, FK)**
- `codigo_curso` **(PK, FK)**
- `obligatorio`
- `creditos`
- `nota_aprobacion`
- `zona_minima`

### Importancia
Esta tabla es una de las más importantes del modelo, porque controla:
- obligatoriedad
- créditos
- nota mínima de aprobación
- zona mínima

Todo ello depende del plan vigente.

---

## 5.3 PRERREQUISITO

### Tipo
Tabla asociativa especializada

### Relación que resuelve
**CURSO ↔ CURSO** dentro de un **PLAN**

### Tipo de relación
Autorrelación contextualizada

### Descripción
Registra qué curso debe aprobarse previamente para poder llevar otro curso dentro de un plan específico.

### Atributos principales
- `codigo_carrera` **(PK, FK)**
- `codigo_plan` **(PK, FK)**
- `codigo_curso` **(PK, FK)**
- `codigo_curso_prerreq` **(PK, FK)**

### Observación
No es una tabla intermedia N:M genérica, pero sí una tabla asociativa muy importante, porque modela una relación recursiva entre cursos dentro del pensum.

---

## 5.4 ASIGNACION

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

### Atributos principales
- `carne` **(PK, FK)**
- `codigo_curso` **(PK, FK)**
- `codigo_seccion` **(PK, FK)**
- `anio` **(PK)**
- `ciclo` **(PK)**
- `zona`
- `nota`

### Importancia
Aquí se registra el rendimiento académico del estudiante.

### Significado de atributos clave
- **zona**: acumulado previo al examen final o evaluación continua.
- **nota**: resultado final del curso.

---

## 5.5 HORARIO

### Tipo
Tabla asociativa / entidad de programación

### Relación que resuelve
**SECCION ↔ DIA / PERIODO / SALON**

### Tipo de relación
Entidad dependiente de la programación académica

### Descripción
Registra cuándo y dónde se imparte una sección específica.

### Atributos principales
- `codigo_curso` **(PK, FK)**
- `codigo_seccion` **(PK, FK)**
- `anio` **(PK)**
- `ciclo` **(PK)**
- `codigo_periodo` **(FK)**
- `codigo_dia` **(FK)**
- `codigo_edificio` **(FK)**
- `codigo_salon` **(FK)**

### Observación importante
Aunque a veces se menciona “Curso ↔ Horario”, la interpretación correcta es que el horario no depende solo del curso, sino de una **SECCION** específica.

### Conclusión
Por ello, **HORARIO** no debe verse como una simple tabla intermedia N:M de curso, sino como una entidad propia que modela la programación académica.

---

# 6. Relaciones que parecen N:M pero no deben modelarse así directamente

---

## 6.1 DOCENTE ↔ CURSO

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

## 6.2 CURSO ↔ HORARIO

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

# 7. Resumen general de tablas

## 7.1 Tablas principales
- EDIFICIO
- SALON
- CARRERA
- DOCENTE
- CURSO
- PERIODO
- DIA
- ESTUDIANTE
- PLAN
- SECCION

## 7.2 Tablas intermedias o asociativas
- INSCRIPCION
- PENSUM
- PRERREQUISITO
- ASIGNACION
- HORARIO

---

# 8. Resumen de relaciones principales

| Relación | Tipo | Tabla que la resuelve |
|---|---|---|
| Estudiante ↔ Carrera | N:M | INSCRIPCION |
| Plan ↔ Curso | N:M | PENSUM |
| Curso ↔ Curso (prerrequisito) | Autorrelación | PRERREQUISITO |
| Estudiante ↔ Sección | N:M | ASIGNACION |
| Sección ↔ Día / Periodo / Salón | Asociativa | HORARIO |
| Docente ↔ Curso | Se modela vía sección | SECCION |

---

# 9. Reglas del negocio relacionadas con las tablas

## 9.1 Máximo 2 carreras por estudiante
Se controla a partir de **INSCRIPCION**.

## 9.2 Aprobación de curso
Se determina con datos de:
- **ASIGNACION**: zona, nota
- **PENSUM**: zona mínima, nota de aprobación
- **PRERREQUISITO**: cursos previos requeridos

## 9.3 Cierre de carrera
Se valida usando:
- **PLAN**
- **PENSUM**
- **ASIGNACION**
- **INSCRIPCION**

## 9.4 Mejor estudiante
Se calcula usando:
- **ASIGNACION**
- cursos aprobados
- promedio
- historial sin cursos perdidos

---

# 10. Conclusión

El modelo propuesto distingue correctamente entre:

- **tablas principales**, que representan entidades base del sistema;
- **tablas intermedias**, que resuelven relaciones N:M;
- **tablas asociativas especializadas**, que modelan reglas académicas y programación.

Este enfoque permite construir un sistema académico sólido, normalizado y preparado para evolucionar hacia:

1. **Modelo ER gráfico**
2. **Modelo relacional**
3. **Script SQL (DDL)**
4. **Implementación física en Oracle**

---

# 11. Siguiente paso recomendado

El siguiente paso lógico es construir el **Modelo Entidad–Relación completo**, indicando:

- entidades
- atributos
- claves primarias
- claves foráneas
- cardinalidades
- relaciones obligatorias y opcionales

