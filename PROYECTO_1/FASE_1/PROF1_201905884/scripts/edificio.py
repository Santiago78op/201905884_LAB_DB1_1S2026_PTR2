# Genera archivo con INSERT de edificios del archivo horario_primer_semestre_usac.csv
# Mantine el nombre del edificio del archivo csv. y asigna un ID único a cada edificio.
import csv
with open("horario_primer_semestre_usac.csv", "r", encoding="utf-8-sig") as f:
    reader = csv.DictReader(f)
    edificios = set()
    for row in reader:
        edificio = row["edificio"]
        if edificio:
            edificios.add(edificio)

with open("./sql/edificio_insert.sql", "w") as f:
    for idx, edificio in enumerate(edificios, start=1):
        f.write(f"INSERT INTO EDIFICIO (ID_EDIFICIO, NOMBRE) VALUES ({idx}, '{edificio}');\n")  
    