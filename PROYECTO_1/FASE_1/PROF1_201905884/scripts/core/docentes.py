# Genera archivo csv de docentes del archivo horario_primer_semestre_usac.csv
# Mantine el nombre del docente, del csv, pero genera un id_docente aleatorio entre 1000 y 9999, y un sueldo mensual aleatorio entre 5000 y 10000.
import csv
import random
with open("../horario_primer_semestre_usac.csv", "r", encoding="utf-8-sig") as f:
    reader = csv.DictReader(f)
    docentes = set()
    for row in reader:
        nombre = row["catedratico"]
        if nombre:
            id_docente = random.randint(1000, 9999)
            sueldo_mensual = random.randint(5000, 10000)
            docentes.add((id_docente, nombre, sueldo_mensual))

with open("../csv/4_docentes.csv", "w") as f:
    for id_docente, nombre, sueldo_mensual in docentes:
        f.write(f"{id_docente},{nombre},{sueldo_mensual}\n")