# 📕 Manual de Procedimiento de la carga de datos a la DB.

## Indice
- [Objetivo General](#objetivo-general)
- [Objetivos Específicos](#objetivos-específicos)
- [Introducción](#introducción)
- [Requisitos previos](#requisitos-previos)
- [Configuración del entorno](#configuración-del-entorno)
- [Que es SQL DDL y DML](#que-es-sql-ddl-y-dml)
    - [SQL DLL Commands](#sql-dll-commands)
        - [CREATE](#create)
        - [ALTER](#alter)
        - [DROP](#drop) 
- [SQL CREATE TABLE](#sql-create-table)
- [CREATE TABLE](#create-table)
    - [Purpose](#purpose)
- [Creación de la Tablas](#creación-de-la-tablas)
    - [Tablas Padre](#tablas-padre)
        - [Tabla Departamento](#tabla-departamento)
        - [Tabla Escuela](#tabla-escuela)
        - [Tabla Centro](#tabla-centro)
        - [Tabla Correlativo](#tabla-correlativo)
        - [Tabla Preguntas](#tabla-preguntas)
        - [Tabla Preguntas Practico](#tabla-preguntas-practico)
    - [Tablas Hija Nivel 1](#tablas-hija)
        - [Tabla Municipio](#tabla-municipio)
        - [Tabla Ubicacion](#tabla-ubicacion)
        - [Tabla Registro](#tabla-registro)
        - [Tabla Examen](#tabla-examen)
        - [Tabla Respuesta Usuario](#tabla-respuesta-usuario)
        - [Tabla Respuesta Practico Usuario](#tabla-respuesta-practico-usuario)


## Objetivo General

- En base al modelo presentado, nos solicitan realizar una serie de reportes para cumplir con informes que 
solicita el departamento de tránsito de Guatemala.

## Objetivos Específicos

- Configurar servidor de base de datos para la creación del modelo diseñado anteriormente.
- Cargar datostransaccionales al modelo presentado.
- Generar consultas SQL según lo solicitado.

## Introducción

Este manual abarca hasta el objetivo específico de cargar datos transaccionales al modelo presentado. Para esto se detallará el proceso de carga de datos a la base de datos, incluyendo la preparación de los datos, la conexión a la base de datos y la ejecución de las consultas SQL necesarias para insertar los datos.

## Requisitos previos

- Tener acceso a un servidor de base de datos "Se debe de utilizar el motor de base de datos Oracle".
- Tener permisos de escritura en la base de datos.
- Tener instalado el software de administración de base de datos Oracle (por ejemplo, SQL Developer).
- Tener los datos transaccionales preparados en un formato compatible (por ejemplo, CSV, Excel, etc.).

***Nota:*** El archivo a utilizar para la carga de datos se encuentra en el siguiente enlace: [Datos Transaccionales](../data/DATA_inicial.xlsx)

## Configuración del entorno

1. **Instalación de Oracle Database**: Asegúrate de tener Oracle Database instalado y configurado en tu sistema. Puedes descargarlo desde el sitio oficial de Oracle.

***Nota:*** El link para descargar Oracle Database es el siguiente: [Oracle Database](https://www.oracle.com/es/database/technologies/appdev/xe.html)

2. **Instalación de Oracle SQL Developer**: Descarga e instala Oracle SQL Developer, que es una herramienta gráfica para administrar tu base de datos Oracle.

***Nota:*** El link para descargar Oracle SQL Developer es el siguiente: [Oracle SQL Developer](https://www.oracle.com/database/sqldeveloper/technologies/download/)

3. **Conexión a la base de datos**: Abre Oracle SQL Developer y crea una nueva conexión a tu base de datos Oracle utilizando las credenciales proporcionadas durante la instalación.

4. **Preparación de los datos**: Asegúrate de que los datos transaccionales estén en un formato compatible para la carga. Si es necesario, convierte los datos a un formato como CSV o Excel.

## Que es SQL DDL y DML

- **SQL DDL (Data Definition Language)**: Es un subconjunto de SQL que se utiliza para definir y administrar la estructura de la base de datos. Incluye comandos como `CREATE`, `ALTER`, `DROP`, entre otros, que permiten crear, modificar y eliminar tablas, índices, vistas, etc.

- **SQL DML (Data Manipulation Language)**: Es un subconjunto de SQL que se utiliza para manipular los datos dentro de las tablas de la base de datos. Incluye comandos como `INSERT`, `UPDATE`, `DELETE`, entre otros, que permiten agregar, modificar y eliminar registros en las tablas.

### SQL DLL Commands

#### CREATE
- El comando `CREATE` se utiliza para crear objetos en la base de datos, como tablas, vistas, índices, etc. Por ejemplo, para crear una tabla llamada "Clientes", se puede usar el siguiente comando:

```sql
CREATE TABLE Clientes (
    ID INT PRIMARY KEY,
    Nombre VARCHAR(50),
    Apellido VARCHAR(50),
    Email VARCHAR(100)
);
```

#### ALTER
- El comando `ALTER` se utiliza para modificar la estructura de una tabla existente. Por ejemplo, para agregar una nueva columna "Telefono" a la tabla "Clientes", se puede usar el siguiente comando:

```sql
ALTER TABLE Clientes
ADD Telefono VARCHAR(20);
```

#### DROP
- El comando `DROP` se utiliza para eliminar objetos de la base de datos, como tablas, vistas, índices, etc. Por ejemplo, para eliminar la tabla "Clientes", se puede usar el siguiente comando:

```sql  
DROP TABLE Clientes;
```

## SQL CREATE TABLE

Nos centraremos en el comando `CREATE TABLE`, que es fundamental para definir la estructura de nuestras tablas en la base de datos. Este comando nos permite especificar los nombres de las columnas, sus tipos de datos, restricciones, claves primarias, entre otros aspectos importantes para garantizar la integridad y eficiencia de nuestra base de datos.

***Nota:*** Nos apoyaremos en la documentacion oficial de Oracle para aplicar el comando `CREATE TABLE` con la documentación: [Oracle CREATE TABLE Documentation](https://docs.oracle.com/en/database/oracle/oracle-database/19/sqlrf/CREATE-TABLE.html)

## CREATE TABLE

### Purpose

Utilizar la sentencia **CREATE TABLE** para crear uno de los siguientes tipos de tablas:

- **Una tabla relacional**, que es la estructura básica para almacenar datos de usuario.

- **Una tabla de objetos (object table)**, que es una tabla que utiliza un **object type** como definición para una columna.  
  Una **object table** se define explícitamente para almacenar instancias de objetos de un tipo específico.

También puede crear un **object type** y luego utilizarlo en una columna al momento de crear una **tabla relacional**.

Las tablas se crean sin datos, a menos que se especifique una **subquery**.  
Puede agregar filas a una tabla utilizando la sentencia **INSERT**.

Después de crear una tabla, se puede definir columnas adicionales, particiones y **integrity constraints** utilizando la cláusula **ADD** de la sentencia **ALTER TABLE**.

Puede cambiar la definición de una columna o partición existente utilizando la cláusula **MODIFY** de la sentencia **ALTER TABLE**.

## Creación de la Tablas

### Tablas Padre

![Tablas Padre](./img/Padre_Hija.jpg)

```bash
DEPARTAMENTO
ESCUELA
CENTRO
│
├── MUNICIPIO
│
├── UBICACION
│
├── REGISTRO
│
CORRELATIVO
│
└── EXAMEN
     │
     ├── RESPUESTA_USUARIO
     └── RESPUESTA_PRACTICO_USUARIO

PREGUNTAS
└── PREGUNTAS_PRACTICO
     │
     ├── RESPUESTA_USUARIO
     └── RESPUESTA_PRACTICO_USUARIO
```

#### Tabla Departamento

La tabla DEPARTAMENTO es una tabla padre que almacena información sobre los departamentos de Guatemala.

Contiene los campos de:

- **ID_DEPARTAMENTO:** Es la clave primaria de la tabla, un número entero que se genera automáticamente.
- **NOMBRE_DEPARTAMENTO:** Es un campo de texto que almacena el nombre del departamento.
- **CODIGO:** es un campo numérico que almacena el código del departamento.

Restricciones:
- El campo CODIGO es un código único que identifica al departamento, por lo que se establece una restricción de clave única en este campo.
- El campo NOMBRE_DEPARTAMENTO también es un campo único que identifica al departamento, por lo que se establece una restricción de clave única en este campo.

```SQL
CREATE TABLE DEPARTAMENTO 
(
    ID_DEPARTAMENTO INTEGER       GENERATED BY DEFAULT ON NULL AS IDENTITY,
    NOMBRE          VARCHAR2(100) NOT NULL,
    CODIGO          NUMBER(3)     NOT NULL,

    CONSTRAINT PK_DEPARTAMENTO 
    PRIMARY KEY (ID_DEPARTAMENTO),

    CONSTRAINT UQ_DEPARTAMENTO_NOMBRE 
    UNIQUE (NOMBRE),

    CONSTRAINT UQ_DEPARTAMENTO_CODIGO 
    UNIQUE (CODIGO)
);
```

#### Tabla Escuela
La tabla ESCUELA es una tabla padre que almacena información sobre las escuelas de conducción en Guatemala.

Contiene los campos de:

- **ID_ESCUELA:** Es la clave primaria de la tabla, un número entero que se genera automáticamente.
- **NOMBRE_ESCUELA:** Es un campo de texto que almacena el nombre de la escuela de conducción.
- **DIRECCION:** Es un campo de texto que almacena la dirección de la escuela de conducción.
- **ACUERDO:** Es un campo de texto que almacena el acuerdo de la escuela de conducción con el departamento de tránsito.

Restricciones:
- El campo NOMBRE_ESCUELA es un campo único que identifica a la escuela de conducción, por lo que se establece una restricción de clave única en este campo.

```SQL
CREATE TABLE ESCUELA 
(
    ID_ESCUELA INTEGER       GENERATED BY DEFAULT ON NULL AS IDENTITY,
    NOMBRE     VARCHAR2(100) NOT NULL,
    DIRECCION  VARCHAR2(200) NOT NULL,
    ACUERDO    VARCHAR2(100) NOT NULL,

    CONSTRAINT PK_ESCUELA 
    PRIMARY KEY (ID_ESCUELA),

    CONSTRAINT UQ_ESCUELA_NOMBRE 
    UNIQUE (NOMBRE)
);
```

#### Tabla Centro
La tabla CENTRO es una tabla padre que almacena información sobre los centros de evaluación en Guatemala.

Contiene los campos de:

- **ID_CENTRO:** Es la clave primaria de la tabla, un número entero que se genera automáticamente.
- **NOMBRE_CENTRO:** Es un campo de texto que almacena el nombre del centro de evaluación.

Restricciones:
- El campo NOMBRE_CENTRO es un campo único que identifica al centro de evaluación, por lo que se establece una restricción de clave única en este campo.

```SQL
CREATE TABLE CENTRO 
(
    ID_CENTRO INTEGER       GENERATED BY DEFAULT ON NULL AS IDENTITY,
    NOMBRE    VARCHAR2(100) NOT NULL,

    CONSTRAINT PK_CENTRO 
    PRIMARY KEY (ID_CENTRO),

    CONSTRAINT UQ_CENTRO_NOMBRE 
    UNIQUE (NOMBRE)
);
```

#### Tabla Correlativo

La tabla CORRELATIVO es una tabla padre que almacena información sobre los correlativos de los exámenes en Guatemala.

Contiene los campos de:
- **ID_CORRELATIVO:** Es la clave primaria de la tabla, un número entero que se genera automáticamente.
- **FECHA:** Es un campo de fecha que almacena la fecha del examen.
- **NO_EXAMEN:** Es un campo numérico que almacena el número del examen.

Restricciones:

El campo NO_EXAMEN es un correlativo que pertence a un solo examen, por lo que en la tabla padre se dejará un campo de NO_EXAMEN con una restricción de clave única.

```SQL
CREATE TABLE CORRELATIVO 
(
    ID_CORRELATIVO     INTEGER    GENERATED BY DEFAULT ON NULL AS IDENTITY,
    FECHA              DATE       NOT NULL,
    NUMERO_CORRELATIVO NUMBER(10) NOT NULL,

    
    CONSTRAINT PK_CORRELATIVO 
    PRIMARY KEY (ID_CORRELATIVO),

    CONSTRAINT UQ_CORRELATIVO_NUMERO 
    UNIQUE (NUMERO_CORRELATIVO)
);
```

#### Tabla Preguntas

La tabla PREGUNTAS es una tabla padre que almacena información sobre las preguntas del examen teórico en Guatemala.

Contiene los campos de:

- **ID_PREGUNTA:** Es la clave primaria de la tabla, un número entero que se genera automáticamente.
- **PREGUNTA_TEXTO:** Es un campo de texto que almacena el texto de la pregunta del examen teórico.
- **RESPUESTA**: Es un campo numérico que almacena la respuesta correcta de la pregunta del examen teórico.
- **RES1:**, **RES2**, **RES3** y **RES4**: Son campos de texto que almacenan las opciones de respuesta de la pregunta del examen teórico, respectivamente.

Restricciones:
- El campo PREGUNTA_TEXTO es un campo único que identifica a la pregunta del examen teórico, por lo que se establece una restricción de clave única en este campo.

```SQL
CREATE TABLE PREGUNTAS 
(
    ID_PREGUNTA    INTEGER       GENERATED BY DEFAULT ON NULL AS IDENTITY,
    PREGUNTA_TEXTO VARCHAR2(200) NOT NULL,
    RESPUESTA      NUMBER(1)     NOT NULL,
    RES1           VARCHAR2(100) NOT NULL,
    RES2           VARCHAR2(100) NOT NULL,
    RES3           VARCHAR2(100) NOT NULL,
    RES4           VARCHAR2(100) NOT NULL,

    CONSTRAINT PK_PREGUNTAS 
    PRIMARY KEY (ID_PREGUNTA),

    CONSTRAINT UQ_PREGUNTAS_TEXTO 
    UNIQUE (PREGUNTA_TEXTO)
);
```

#### Tabla Preguntas Practico

La tabla PREGUNTAS_PRACTICO es una tabla padre que almacena información sobre las preguntas del examen práctico en Guatemala.

Contiene los campos de:
- **ID_PREGUNTA_PRACTICO:** Es la clave primaria de la tabla, un número entero que se genera automáticamente.
- **PREGUNTA_TEXTO:** Es un campo de texto que almacena el texto de la pregunta del examen práctico.
- **PUNTEO:** Es un campo numérico que almacena el puntaje de la pregunta del examen práctico.

Restricciones:
- El campo PREGUNTA_TEXTO es un campo único que identifica a la pregunta del examen práctico, por lo que se establece una restricción de clave única en este campo.

```SQL
CREATE TABLE PREGUNTAS_PRACTICO 
(
    ID_PREGUNTA_PRACTICO INTEGER       GENERATED BY DEFAULT ON NULL AS IDENTITY,
    PREGUNTA_TEXTO       VARCHAR2(200) NOT NULL,
    PUNTEO               NUMBER(2)     NOT NULL,

    CONSTRAINT PK_PREGUNTAS_PRACTICO 
    PRIMARY KEY (ID_PREGUNTA_PRACTICO),

    CONSTRAINT UQ_PREGUNTAS_PRACTICO_TEXTO
    UNIQUE (PREGUNTA_TEXTO)
);
```

### Tablas Hija Nivel 1

#### Tabla Municipio
La tabla MUNICIPIO es una tabla hija que almacena información sobre los municipios de Guatemala.

Contiene los campos de:
- **ID_MUNICIPIO:** Es la clave primaria de la tabla, un número entero que se genera automáticamente.
- **DEPARTAMENTO_ID_DEPARTAMENTO:** Es un campo numérico que almacena el ID del departamento al que pertenece el municipio, es una clave foránea que referencia a la tabla DEPARTAMENTO.
- **NOMBRE:** Es un campo de texto que almacena el nombre del municipio.
- **CODIGO:** Es un campo numérico que almacena el código del departamento al que pertenece el municipio.

Restricciones:

- El campo DEPARTAMENTO_ID_DEPARTAMENTO es una clave foránea que referencia a la tabla DEPARTAMENTO, por lo que se establece una restricción de clave foránea en este campo. Se establece ON DELETE CASCADE para que al eliminar un departamento, se eliminen automáticamente los municipios relacionados.

- El campo CODIGO es un código único que identifica al municipio dentro de su departamento, por lo que se establece una restricción de clave única en la combinación de los campos DEPARTAMENTO_ID_DEPARTAMENTO y CODIGO.

- El campo NOMBRE también es un campo único que identifica al municipio dentro de su departamento, por lo que se establece una restricción de clave única en la combinación de los campos DEPARTAMENTO_ID_DEPARTAMENTO y NOMBRE.

```SQL
CREATE TABLE MUNICIPIO 
(
    ID_MUNICIPIO                 INTEGER GENERATED BY DEFAULT ON NULL AS IDENTITY,
    DEPARTAMENTO_ID_DEPARTAMENTO INTEGER NOT NULL,
    NOMBRE                       VARCHAR2(100) NOT NULL,
    CODIGO                       NUMBER(3) NOT NULL,
    
    CONSTRAINT PK_MUNICIPIO PRIMARY KEY (ID_MUNICIPIO),

    CONSTRAINT FK_MUNICIPIO_DEPARTAMENTO 
            FOREIGN KEY (DEPARTAMENTO_ID_DEPARTAMENTO) 
            REFERENCES DEPARTAMENTO(ID_DEPARTAMENTO)
            ON DELETE CASCADE,
    
    CONSTRAINT UQ_MUNICIPIO_DEPARTAMENTO_CODIGO 
            UNIQUE (DEPARTAMENTO_ID_DEPARTAMENTO, CODIGO)

    CONSTRAINT UQ_MUNICIPIO_DEPARTAMENTO_NOMBRE 
            UNIQUE (DEPARTAMENTO_ID_DEPARTAMENTO, NOMBRE)
);
```

#### Tabla Ubicacion

La tabla UBICACION es una tabla hija que almacena información sobre las ubicaciones de los centros de evaluación en Guatemala.