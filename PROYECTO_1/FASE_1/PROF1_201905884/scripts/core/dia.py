"""
* Genera archivo csv de dias
* Genera un ID único para cada día de la semana y su nombre
"""
import csv
dias = [
    "Lunes",
    "Martes",
    "Miércoles",
    "Jueves",
    "Viernes",
    "Sábado",
    "Domingo"
]
with open("../csv/9_dias.csv", "w") as f:
    for i, dia in enumerate(dias, start=1):
        f.write(f"{i},{dia}\n")