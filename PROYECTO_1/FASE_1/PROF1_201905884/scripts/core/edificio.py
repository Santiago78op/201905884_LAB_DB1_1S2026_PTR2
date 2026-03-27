# Genera archivo csv de edificios del archivo horario_primer_semestre_usac.csv
# Mantine el nombre del edificio del archivo csv. y asigna un ID único a cada edificio.
import csv
with open("../horario_primer_semestre_usac.csv", "r", encoding="utf-8-sig") as f:
    reader = csv.DictReader(f)
    edificios = set()
    for row in reader:
        nombre = row["edificio"]
        if nombre:
            edificios.add(nombre)

with open("../csv/5_edificios.csv", "w") as f:
    for i, nombre in enumerate(edificios, start=1):
        f.write(f"{i},{nombre}\n")