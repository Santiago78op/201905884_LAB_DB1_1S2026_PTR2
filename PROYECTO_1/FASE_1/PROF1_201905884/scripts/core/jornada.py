"""
* Generar archivo CSV con los datos de la tabla JORNADA, con el formato: ID_JORNADA,NOMBRE_JORNADA
* El ID_JORNADA se asigna de forma incremental a partir de 1
* Las Jornadas son "Matutina", "Vespertina", "Nocturna" y "Mixta"
"""
import csv
jornadas = ["Matutina", "Vespertina", "Nocturna", "Mixta"]
with open("../csv/10_jornadas.csv", "w") as f:
    for i, nombre in enumerate(jornadas, start=1):
        f.write(f"{i},{nombre}\n")