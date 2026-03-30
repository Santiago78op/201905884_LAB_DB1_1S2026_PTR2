"""
* Genera archivo csv de secciones del archivo horario_primer_semestre_usac.csv
* Genera secciones para todos los cursos del pensum de ingeniería ambiental, con cupo variado y estado "DISPONIBLE"
"""
import csv
with open("../horario_primer_semestre_usac.csv", "r", encoding="utf-8-sig") as f:
    reader = csv.DictReader(f)
    secciones = set()
    # Ciclo para obtener Nombre de la seccion y Generar el ID de la seccion de manera secuencial entre 1000 y 9999
    for row in reader:
        # Generar el ID de la seccion de manera secuencial entre 1000 y 9999
        id_seccion = 1000 + len(secciones)
        # Obtener el nombre de la seccion
        nombre_seccion = row["seccion"]
        # Obtiene codigo del curso 
        codigo_curso = row["codigo"]
        # Obtiene nombre del Catedratico
        nombre_catedratico = row["catedratico"]
    