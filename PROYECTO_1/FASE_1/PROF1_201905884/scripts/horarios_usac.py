import csv
import requests
from bs4 import BeautifulSoup
import urllib3

urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

URL = "https://usuarios.ingenieria.usac.edu.gt/horarios/semestre/1"
OUTPUT = "horario_primer_semestre_usac.csv"

resp = requests.get(URL, verify=False, timeout=30)
resp.raise_for_status()

soup = BeautifulSoup(resp.text, "html.parser")

# Buscar la tabla principal
table = soup.find("table")
if table is None:
    raise RuntimeError("No se encontró la tabla de horarios.")

rows = table.find_all("tr")
if not rows:
    raise RuntimeError("La tabla no contiene filas.")

# Encabezados deseados
headers = [
    "codigo",
    "curso",
    "seccion",
    "modalidad",
    "edificio",
    "salon",
    "inicio",
    "final",
    "dias",
    "catedratico",
    "auxiliar",
    "detalle",
]

data = []

for tr in rows[1:]:  # saltar encabezado
    cols = [td.get_text(" ", strip=True) for td in tr.find_all("td")]
    if not cols:
        continue

    # El sitio muestra estas columnas:
    # codigo+curso, seccion, modalidad, edificio, salon, inicio, final,
    # dias, catedratico, auxiliar, detalle
    #
    # En algunos casos el código y nombre vienen juntos en la primera columna.
    first = cols[0] if len(cols) > 0 else ""
    parts = first.split(maxsplit=1)
    codigo = parts[0] if parts else ""
    curso = parts[1] if len(parts) > 1 else ""

    row = [
        codigo,
        curso,
        cols[1] if len(cols) > 1 else "",
        cols[2] if len(cols) > 2 else "",
        cols[3] if len(cols) > 3 else "",
        cols[4] if len(cols) > 4 else "",
        cols[5] if len(cols) > 5 else "",
        cols[6] if len(cols) > 6 else "",
        cols[7] if len(cols) > 7 else "",
        cols[8] if len(cols) > 8 else "",
        cols[9] if len(cols) > 9 else "",
        cols[10] if len(cols) > 10 else "",
    ]
    data.append(row)

with open(OUTPUT, "w", newline="", encoding="utf-8-sig") as f:
    writer = csv.writer(f)
    writer.writerow(headers)
    writer.writerows(data)

print(f"CSV generado: {OUTPUT}")
print(f"Filas exportadas: {len(data)}")