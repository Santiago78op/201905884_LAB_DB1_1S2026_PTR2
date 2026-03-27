# Genera archivo con INSERT de docentes del archivo horario_primer_semestre_usac.csv
# Mantine el nombre del docente, del csv, pero genera un id_docente aleatorio entre 1000 y 9999, y un sueldo mensual aleatorio entre 5000 y 10000.
import csv
import random

with open("horario_primer_semestre_usac.csv", "r", encoding="utf-8-sig") as f:
    reader = csv.DictReader(f)
    docentes = set()
    for row in reader:
        docente = row["catedratico"]
        if docente:
            docentes.add(docente)

with open("./sql/docentes_insert.sql", "w") as f:
    for docente in docentes:
        id_docente = random.randint(1000, 9999)
        sueldo_mensual = random.randint(5000, 10000)
        f.write(f"INSERT INTO DOCENTE (ID_DOCENTE, NOMBRE, SUELDO_MENSUAL) VALUES ({id_docente}, '{docente}', {sueldo_mensual});\n")