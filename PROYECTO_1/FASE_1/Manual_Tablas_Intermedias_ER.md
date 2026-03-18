# 📘 Manual – Tablas Intermedias (Modelo ER)
## Sistema de Control Académico – USAC

---

## 🎯 Objetivo

Definir y documentar las **tablas intermedias (relaciones N:M)** dentro del modelo entidad-relación del sistema de control académico.

---

## 🧠 Concepto

Las **tablas intermedias** se utilizan para resolver relaciones **muchos a muchos (N:M)** entre entidades.

---

## 📌 Tablas Intermedias Identificadas

---

## 1. 🧑‍🎓 ESTUDIANTE ↔ 🎓 CARRERA

### 📊 Tipo de relación:
N:M

### 📌 Descripción:
- Un estudiante puede estar inscrito en hasta **2 carreras**
- Una carrera puede tener **muchos estudiantes**

### 🗂️ Tabla intermedia:
**INSCRIPCION**

### 🧾 Atributos:
- carne (FK)
- codigo_carrera (FK)
- fecha_inscripcion

---

## 2. 📚 PLAN ↔ 📘 CURSO

### 📊 Tipo de relación:
N:M

### 📌 Descripción:
- Un plan contiene múltiples cursos
- Un curso puede existir en varios planes

### 🗂️ Tabla intermedia:
**PENSUM**

### 🧾 Atributos:
- codigo_carrera (FK)
- codigo_plan (FK)
- codigo_curso (FK)
- obligatorio
- creditos
- nota_aprobacion
- zona_minima

---

## 3. 🧑‍🎓 ESTUDIANTE ↔ 📑 SECCION / CURSO

### 📊 Tipo de relación:
N:M

### 📌 Descripción:
- Un estudiante puede asignarse a varios cursos
- Un curso/sección puede tener muchos estudiantes

### 🗂️ Tabla intermedia:
**ASIGNACION**

### 🧾 Atributos:
- carne (FK)
- codigo_curso (FK)
- codigo_seccion (FK)
- anio
- ciclo
- zona
- nota

---

## ⚠️ Relaciones que NO se modelan como N:M directo

---

## ❌ DOCENTE ↔ CURSO

### ✔️ Solución correcta:
Se resuelve mediante la entidad **SECCION**

### 📌 Explicación:
- Un docente imparte secciones
- Cada sección pertenece a un curso

### 🗂️ Tabla:
**SECCION**
- codigo_seccion
- codigo_curso (FK)
- codigo_docente (FK)
- anio
- ciclo

---

## ❌ CURSO ↔ HORARIO

### ✔️ Solución correcta:
Se resuelve mediante **SECCION + HORARIO**

### 📌 Explicación:
- El horario depende de la sección
- No del curso directamente

### 🗂️ Tabla:
**HORARIO**
- codigo_curso (FK)
- codigo_seccion (FK)
- anio
- ciclo
- codigo_periodo (FK)
- codigo_dia (FK)
- codigo_edificio (FK)
- codigo_salon (FK)

---

## 📊 Resumen Final

| Relación | Tipo | Tabla |
|----------|------|------|
| Estudiante ↔ Carrera | N:M | INSCRIPCION |
| Plan ↔ Curso | N:M | PENSUM |
| Estudiante ↔ Sección | N:M | ASIGNACION |
| Docente ↔ Curso | 1:N (vía SECCION) | SECCION |
| Curso ↔ Horario | 1:N (vía SECCION) | HORARIO |

---

## 🚀 Conclusión

- No todas las relaciones aparentes N:M deben modelarse como tablas intermedias directas.
- Algunas se resuelven mediante **entidades de negocio más completas** como:
  - SECCION
  - HORARIO
- Este enfoque garantiza:
  - Normalización correcta
  - Integridad de datos
  - Escalabilidad del modelo

---

## 📌 Siguiente paso recomendado

1. Modelo ER gráfico
2. Modelo relacional
3. Script SQL (DDL)

