"""
* Genera archivo csv de salones del archivo horario_primer_semestre_usac.csv
* Mantine el codigo del salon del archivo csv.
* Busca el nombre del edificio en el csv edificios.csv, si lo encuentra 
* asigna el ID del edificio.
"""
import csv
import random
with open("../horario_primer_semestre_usac.csv", "r", encoding="utf-8-sig") as f:
    reader = csv.DictReader(f)
    salones = set()
    # Ciclo para obtener el salon y el edificio del archivo horario_primer_semestre_usac.csv
    for row in reader:
        salon = row["salon"]
        edificio = row["edificio"]
        if salon and edificio:
            salones.add((salon, edificio))
    
# Ciclo para obtener el ID del edificio del archivo edificios.csv
salones_con_id = set() 
with open("../csv/6_edificios.csv", "r") as f:
    reader = csv.DictReader(f)
    for row in reader:
        nombre_edificio = row["NOMBRE"]
        id_edificio = row["ID_EDIFICIO"]
        for salon, edificio in salones:
            if edificio == nombre_edificio:
                salones_con_id.add((salon, id_edificio))

# Genera el archivo csv de salones con el ID del edificio
# Estructura del csv: salon, capacidad (Numero Random entre 20 y 100), id_edificio
# Se genera ID_SALON de forma autoincremental a partir del numero de salones encontrados en el archivo horario_primer_semestre_usac.csv
id_salon = 1
with open("../csv/7_salones.csv", "w") as f:
    for salon, id_edificio in salones_con_id:
        capacidad = random.randint(20, 100)
        f.write(f"{id_salon},{salon},{capacidad},{id_edificio}\n")
        id_salon += 1