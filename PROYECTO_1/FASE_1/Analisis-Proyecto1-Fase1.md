# 📘 Análisis del Proyecto 1 – Fase 1  
## Sistema de Control Académico – Facultad de Ingeniería en Ciencias y Sistemas (USAC)

---

## 🎯 Objetivo

Realizar el **análisis, diseño e implementación** de un sistema de información para el **control académico**, que permita llevar el registro integral de la población estudiantil de la Facultad de Ingeniería en Ciencias y Sistemas de la Universidad de San Carlos de Guatemala (USAC).

**Solicitantes:**
- Decana de la Facultad de Ingeniería en Ciencias y Sistemas – USAC  
- Directora de Control Académico – Facultad de Ingeniería en Ciencias y Sistemas – USAC  

---

## 📋 Alcance del Sistema

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

## 📌 Modelo Conceptual

### 🏫 EDIFICIO
- codigo_edificio (PK)
- nombre

---

### 🏛️ SALON
- codigo_edificio (PK, FK)
- codigo_salon (PK)
- nombre
- capacidad_maxima

---

### 🎓 CARRERA
- codigo_carrera (PK)
- nombre
- unidad_academica

---

### 👨‍🏫 DOCENTE
- codigo_docente (PK)
- nombre_completo
- sueldo_mensual

---

### 📘 CURSO
- codigo_curso (PK)
- nombre

---

### 📅 PERIODO
- codigo_periodo (PK)
- hora_inicio
- hora_fin

---

### 📆 DIA
- codigo_dia (PK)
- nombre

---

### 👨‍🎓 ESTUDIANTE
- carne (PK)
- nombre_completo
- ingreso_familiar
- fecha_nacimiento

---

### 📝 INSCRIPCION
- carne (PK, FK)
- codigo_carrera (PK, FK)
- fecha_inscripcion

---

### 📚 PLAN
- codigo_carrera (PK, FK)
- codigo_plan (PK)
- nombre
- anio_inicio
- ciclo_inicio
- anio_fin
- ciclo_fin
- creditos_cierre

---

### 📖 PENSUM (DETALLE_PLAN)
- codigo_carrera (PK, FK)
- codigo_plan (PK, FK)
- codigo_curso (PK, FK)
- obligatorio
- creditos
- nota_aprobacion
- zona_minima

---

### 🔁 PRERREQUISITO
- codigo_carrera (PK, FK)
- codigo_plan (PK, FK)
- codigo_curso (PK, FK)
- codigo_curso_prerreq (PK)

---

### 📑 SECCION
- codigo_seccion (PK)
- codigo_curso (FK)
- codigo_docente (FK)
- anio
- ciclo

---

### 🗓️ HORARIO
- codigo_curso (PK, FK)
- codigo_seccion (PK, FK)
- anio (PK)
- ciclo (PK)
- codigo_periodo (FK)
- codigo_dia (FK)
- codigo_edificio (FK)
- codigo_salon (FK)

---

### 📊 ASIGNACION
- carne (PK, FK)
- codigo_curso (PK, FK)
- codigo_seccion (PK, FK)
- anio (PK)
- ciclo (PK)
- zona
- nota

---

### 🔗 DOCENTE_CURSO (Relación N:M)
- codigo_docente (PK, FK)
- codigo_curso (PK, FK)

---

## ⚖️ Reglas de Negocio (CHECK Constraints)

### 1. Aprobación de Curso
- zona >= zona_minima
- nota >= nota_aprobacion
- cumplir prerrequisitos

---

### 2. Promedios
- Solo se consideran cursos aprobados

---

### 3. Cierre de Carrera
- Aprobar todos los cursos obligatorios
- Cumplir créditos requeridos
- Dentro del plan vigente

---

### 4. Mejor Estudiante
- Mejor promedio
- Sin cursos reprobados
