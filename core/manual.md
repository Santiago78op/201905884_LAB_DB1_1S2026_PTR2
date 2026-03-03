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
    - [Prerequisites](#prerequisites)
- [Tabla Centro](#tabla-centro)


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

## Tabla Centro

Creación de la tabla **Centro** utilizando el comando `CREATE TABLE` en Oracle Database. Esta tabla se utilizará para almacenar información relacionada con los centros de tránsito, incluyendo su identificación, nombre, ubicación y otros detalles relevantes.

```sql
-- ? Crear Tabla Centro
/*
* La tabla Centro se utiliza para almacenar información 
* sobre los centros de evaluación.
* Campos:
* - ID_CENTRO: Identificador único del centro (clave primaria).
* - NOMBRE: Nombre del centro (único y no nulo), de debe duplicar
*   en la tabla Centro.
* Restricciones:
* - La columna ID_CENTRO es una clave primaria que se genera 
*   automáticamente.
* - La columna NOMBRE debe ser única y no puede ser nula.
*/
CREATE TABLE CENTRO
(
    ID_CENTRO INTEGER GENERATED BY DEFAULT ON NULL AS IDENTITY,
    NOMBRE VARCHAR(50) NOT NULL,
    CONSTRAINT PK_CENTRO PRIMARY KEY (ID_CENTRO),
    CONSTRAINT UQ_CENTRO_NOMBRE UNIQUE (NOMBRE)
)

-- ? Insertar datos en la tabla Centro
INSERT INTO CENTRO (NOMBRE) VALUES ('CENTRO 1');
INSERT INTO CENTRO (NOMBRE) VALUES ('CENTRO 2');
INSERT INTO CENTRO (NOMBRE) VALUES ('CENTRO 3');
INSERT INTO CENTRO (NOMBRE) VALUES ('CENTRO 4');
INSERT INTO CENTRO (NOMBRE) VALUES ('CENTRO 5');

-- ? Insertar un nuevo centro con un ID_CENTRO específico
INSERT INTO CENTRO (ID_CENTRO, NOMBRE) VALUES (6, 'CENTRO 6');

-- ? Reiniciar el contador en el valor maximo actual ++1.
/*
* Corrige el desfase depués de una inserción manual de un ID_CENTRO específico.
* START WITH se utiliza para establecer el valor incial del contador de la columna ID_CENTRO.
* validando si este ya fue insertado manualmente, sino se mantiene el valor actual del contador.
*/
ALTER TABLE CENTRO MODIFY ID_CENTRO GENERATED BY DEFAULT 
ON NULL AS IDENTITY (START WITH LIMIT VALUE)

-- ? Eliminar la tabla Centro
/*
* El comando DROP TABLE se utiliza para eliminar la tabla Centro de la base de datos.
* El indice de la tabla Centro se eliminará automáticamente al eliminar la tabla.
* a diferencia de TRUNCATE TABLE, DROP TABLE elimina la estructura de la tabla y sus datos,
* mientras que TRUNCATE TABLE solo elimina los datos pero mantiene la estructura de la tabla.
*/
DROP TABLE CENTRO;

-- ? Consultar datos de la tabla Centro
SELECT * FROM CENTRO;
```

