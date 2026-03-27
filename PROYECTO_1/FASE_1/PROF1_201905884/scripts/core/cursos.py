# Genera archivo csv de cursos del archivo horario_primer_semestre_usac.csv
# Mantine el codigo y nombre del curso del archivo csv.
import csv
with open("../horario_primer_semestre_usac.csv", "r", encoding="utf-8-sig") as f:
    reader = csv.DictReader(f)
    cursos = set()
    for row in reader:
        codigo = row["codigo"]
        nombre = row["curso"]
        if codigo and nombre:
            cursos.add((codigo, nombre))

with open("../csv/5_cursos.csv", "w") as f:
    for codigo, nombre in cursos:
        f.write(f"{codigo},{nombre}\n")


