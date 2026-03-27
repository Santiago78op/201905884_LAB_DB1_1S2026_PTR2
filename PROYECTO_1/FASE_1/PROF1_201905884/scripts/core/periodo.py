"""
* Genera archivo csv de periodos del archivo horario_primer_semestre_usac.csv
* Genera de forma secuencial los periodos
* Almacena la HORA_INICIO y HORA_FIN del archivo horario_primer_semestre_usac.csv
"""
import csv
with open("../horario_primer_semestre_usac.csv", "r", encoding="utf-8-sig") as f:
    reader = csv.DictReader(f)
    periodos = set()
    for row in reader:
        hora_inicio = row["inicio"]
        hora_fin = row["final"]
        if hora_inicio and hora_fin:
            periodos.add((hora_inicio, hora_fin))

# Genera el archivo csv de periodos
with open("../csv/8_periodos.csv", "w") as f:
    for i, (hora_inicio, hora_fin) in enumerate(periodos, start=1):
        f.write(f"{i},{hora_inicio},{hora_fin}\n")