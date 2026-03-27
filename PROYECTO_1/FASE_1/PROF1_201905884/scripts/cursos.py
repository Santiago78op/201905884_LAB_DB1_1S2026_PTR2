# Genera archivo con INSERT de cursos del archivo horario_primer_semestre_usac.csv
# Mantine el codigo y nombre del curso del archivo csv.
import csv

with open("horario_primer_semestre_usac.csv", "r", encoding="utf-8-sig") as f:
    reader = csv.DictReader(f)
    cursos = set()
    for row in reader:
        codigo = row["codigo"]
        nombre = row["curso"]
        if codigo and nombre:
            cursos.add((codigo, nombre))

with open("./sql/cursos_insert.sql", "w") as f:
    for codigo, nombre in cursos:
        f.write(f"INSERT INTO CURSO (ID_CURSO, NOMBRE) VALUES ({codigo}, '{nombre}');\n")

