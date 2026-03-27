# Genera archivo con INSERT de salones del archivo horario_primer_semestre_usac.csv
# Mantine el codigo del salon del archivo csv.
# Genera de forma aleatoria la capacidad del salon entre 20 y 200.
# Para el campo EDIFICIO_ID_EDIFICIO utiliza los numeros del 1 al 12, que corresponden a los edificios de la USAC.
""" 1	S-12
2	S-11
3	MEET
4	EXT
5	0000
6	T-3
7	T-1
8	T-5
9	EPS
10	ET
11	T-7
12	HIBR """
# Valida si el nombre del edificio es T-7 o cualquiera del comentario
import csv
import random
with open("horario_primer_semestre_usac.csv", "r", encoding="utf-8-sig") as f:
    reader = csv.DictReader(f)
    salones = set()
    edificios = {
                "S-12": 1,
                "S-11": 2,
                "MEET": 3,
                "EXT": 4,
                "0000": 5,
                "T-3": 6,
                "T-1": 7,
                "T-5": 8,
                "EPS": 9,
                "ET": 10,
                "T-7": 11,
                "HIBR": 12
            }
    for row in reader:
        nombre_edificio = row["edificio"]
        codigo = row["salon"]
        edificio_id = edificios.get(nombre_edificio)
        if codigo:
            if edificio_id is not None:
                salones.add((codigo, edificio_id))

with open("./sql/salon_insert.sql", "w") as f:
    for codigo, edificio_id in salones:
        capacidad = random.randint(20, 200)
        f.write(f"INSERT INTO SALON (ID_SALON, CAPACIDAD, EDIFICIO_ID_EDIFICIO) VALUES ('{codigo}', {capacidad}, {edificio_id});\n")