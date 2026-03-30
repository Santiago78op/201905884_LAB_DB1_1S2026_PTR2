import csv

with open("../csv/5_cursos.csv", "r", encoding="utf-8-sig") as f:
    reader = csv.DictReader(f)
    cursos = set()
    for row in reader:
        codigo_curso = row["ID_CURSO"]
        nombre_curso = row["NOMBRE"]
        cursos.add((codigo_curso, nombre_curso))
        

# Leer pensum de ingeniería electronica y validar que los cursos del pensum estén en el archivo 5_cursos.csv
with open("../pensum_ingenieria_en_ciencias_y_sistemas.csv", "r", encoding="utf-8-sig") as f:
    reader = csv.DictReader(f)
#$    print([pepito[0] for pepito in cursos])
    for row in reader:
        codigo_curso = row["CODIGO"]
        nombre_curso = row["NOMBRE"]
        if codigo_curso not in [c[0] for c in cursos]:
            print(f"El curso {codigo_curso} del pensum de ingeniería electronica no se encuentra en el archivo 5_cursos.csv")
            # write en un archivo de texto los cursos del pensum que no se encuentran en el archivo 5_cursos.csv
            with open("../csv/5_cursos.csv", "a", encoding="utf-8-sig") as f:
                f.write(f"{codigo_curso}, {nombre_curso}\n")
            # Agregar codigo a la tupla
            cursos.add((codigo_curso, nombre_curso))
        