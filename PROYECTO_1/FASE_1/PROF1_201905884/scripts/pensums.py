import csv
import re
import warnings
from typing import List, Dict, Optional

import requests
from bs4 import BeautifulSoup, Tag
from urllib3.exceptions import InsecureRequestWarning


URL = "https://redesestudio.ingenieria.usac.edu.gt/redesDeEstudio/ingenieriaEnCienciasYSistemas/28/clar"
OUTPUT_CSV = "pensum_ingenieria_en_ciencias_y_sistemas_3.csv"

SEMESTRES = {
    "PRIMER SEMESTRE": 1,
    "SEGUNDO SEMESTRE": 2,
    "TERCER SEMESTRE": 3,
    "CUARTO SEMESTRE": 4,
    "QUINTO SEMESTRE": 5,
    "SEXTO SEMESTRE": 6,
    "SÉPTIMO SEMESTRE": 7,
    "SEPTIMO SEMESTRE": 7,
    "OCTAVO SEMESTRE": 8,
    "NOVENO SEMESTRE": 9,
    "DÉCIMO SEMESTRE": 10,
    "DECIMO SEMESTRE": 10,
}


def fetch_html(url: str, verify=False, timeout: int = 30) -> str:
    if verify is False:
        warnings.simplefilter("ignore", InsecureRequestWarning)

    headers = {
        "User-Agent": (
            "Mozilla/5.0 (Windows NT 10.0; Win64; x64) "
            "AppleWebKit/537.36 (KHTML, like Gecko) "
            "Chrome/122.0.0.0 Safari/537.36"
        )
    }

    response = requests.get(url, headers=headers, timeout=timeout, verify=verify)
    response.raise_for_status()
    response.encoding = response.apparent_encoding or "utf-8"
    return response.text


def clean_text(value: str) -> str:
    return re.sub(r"\s+", " ", value).strip()


def find_course_container(desc_div: Tag) -> Optional[Tag]:
    """
    Sube en el DOM hasta encontrar el contenedor del curso.
    """
    current = desc_div
    for _ in range(10):
        if not current or not isinstance(current, Tag):
            return None

        has_desc = current.find("div", class_=lambda c: c and "body-red-descripcion" in c)
        has_tipo = current.find("div", class_=lambda c: c and "body-red-diplomado" in c)

        if has_desc and has_tipo:
            return current

        current = current.parent

    return None


def extract_nombre(container: Tag) -> str:
    desc_div = container.find("div", class_=lambda c: c and "body-red-descripcion" in c)
    if not desc_div:
        return ""
    return clean_text(desc_div.get_text(" ", strip=True))


def extract_codigo(container: Tag) -> str:
    # Primero clases específicas
    codigo_div = container.find(
        "div",
        class_=lambda c: c and (
            "body-red-codigo" in c
            or "body-red-cod" in c
            or "body-red-curso-codigo" in c
        )
    )
    if codigo_div:
        text = clean_text(codigo_div.get_text(" ", strip=True))
        m = re.search(r"\b\d{4}\b", text)
        if m:
            return m.group(0)

    # Fallback: small de 4 dígitos que no esté dentro de prerrequisitos
    for small in container.find_all("small"):
        if small.find_parent("div", class_=lambda c: c and "body-red-prerrequisito-item" in c):
            continue
        text = clean_text(small.get_text(" ", strip=True))
        if re.fullmatch(r"\d{4}", text):
            return text

    return ""


def extract_creditos(container: Tag, codigo: str, nombre: str) -> str:
    # Busca un bloque de créditos por clase
    credit_div = container.find(
        "div",
        class_=lambda c: c and (
            "body-red-credito" in c
            or "body-red-creditos" in c
        )
    )
    if credit_div:
        text = clean_text(credit_div.get_text(" ", strip=True))
        m = re.search(r"\b\d{1,2}\b", text)
        if m:
            return m.group(0)

    # Fallback: buscar smalls numéricos excluyendo código y prerrequisitos
    candidatos = []
    for small in container.find_all("small"):
        if small.find_parent("div", class_=lambda c: c and "body-red-prerrequisito-item" in c):
            continue
        text = clean_text(small.get_text(" ", strip=True))
        if re.fullmatch(r"\d{1,2}", text):
            candidatos.append(text)

    if candidatos:
        return candidatos[0]

    # Último fallback: texto del contenedor
    text = clean_text(container.get_text(" ", strip=True))
    pattern = rf"{re.escape(codigo)}\s+(\d{{1,2}})\s+{re.escape(nombre)}"
    m = re.search(pattern, text)
    if m:
        return m.group(1)

    return ""


def extract_tipo(container: Tag) -> str:
    tipo_div = container.find("div", class_=lambda c: c and "body-red-diplomado" in c)
    if not tipo_div:
        return ""

    dot = tipo_div.select_one("svg.bi-dot")
    if dot:
        return "OBLIGATORIO"

    return "OPCIONAL"


def extract_prerrequisitos(container: Tag) -> List[str]:
    prereqs = []

    prereq_items = container.find_all(
        "div",
        class_=lambda c: c and "body-red-prerrequisito-item" in c
    )

    for item in prereq_items:
        text = clean_text(item.get_text(" ", strip=True)).upper().replace(" ", "")
        if text:
            prereqs.append(text)

    return prereqs


def detect_semester_text(text: str) -> Optional[int]:
    normalized = clean_text(text).upper()
    return SEMESTRES.get(normalized)


def build_semester_map(soup: BeautifulSoup) -> Dict[int, int]:
    """
    Mapa id(container) -> semestre.
    Recorre el DOM en orden y conserva el semestre actual.
    """
    semester_map: Dict[int, int] = {}
    current_semester: Optional[int] = None
    seen = set()

    # Recorremos candidatos visuales en orden documento
    for desc_div in soup.find_all("div", class_=lambda c: c and "body-red-descripcion" in c):
        container = find_course_container(desc_div)
        if not container:
            continue

        cid = id(container)
        if cid in seen:
            continue
        seen.add(cid)

        # Buscar encabezado de semestre cercano hacia atrás en texto del documento no es trivial.
        # Entonces intentamos extraer del propio texto del contenedor y ancestros.
        for parent in [container] + list(container.parents)[:5]:
            text = clean_text(parent.get_text(" ", strip=True))
            for sem_name, sem_num in SEMESTRES.items():
                if sem_name in text.upper():
                    current_semester = sem_num
                    break
            if current_semester is not None:
                break

        if current_semester is not None:
            semester_map[cid] = current_semester

    return semester_map


def extract_courses_from_html(soup: BeautifulSoup) -> List[Dict[str, str]]:
    rows: List[Dict[str, str]] = []
    seen = set()

    semester_map = build_semester_map(soup)

    for desc_div in soup.find_all("div", class_=lambda c: c and "body-red-descripcion" in c):
        container = find_course_container(desc_div)
        if not container:
            continue

        cid = id(container)
        if cid in seen:
            continue
        seen.add(cid)

        nombre = extract_nombre(container)
        codigo = extract_codigo(container)
        creditos = extract_creditos(container, codigo, nombre)
        tipo = extract_tipo(container)
        semestre = semester_map.get(cid, "")

        if not codigo or not nombre:
            continue

        prereqs = extract_prerrequisitos(container)

        if prereqs:
            for pr in prereqs:
                rows.append({
                    "CODIGO": codigo,
                    "NOMBRE": nombre,
                    "CREDITOS": creditos,
                    "SEMESTRE": str(semestre),
                    "CODIGO_PRERREQUISITO": pr,
                    "TIPO": tipo,
                })
        else:
            rows.append({
                "CODIGO": codigo,
                "NOMBRE": nombre,
                "CREDITOS": creditos,
                "SEMESTRE": str(semestre),
                "CODIGO_PRERREQUISITO": "",
                "TIPO": tipo,
            })

    return rows


def save_csv(rows: List[Dict[str, str]], output_path: str) -> None:
    fieldnames = [
        "CODIGO",
        "NOMBRE",
        "CREDITOS",
        "SEMESTRE",
        "CODIGO_PRERREQUISITO",
        "TIPO",
    ]

    with open(output_path, "w", newline="", encoding="utf-8-sig") as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(rows)


def main():
    html = fetch_html(URL, verify=False)
    soup = BeautifulSoup(html, "html.parser")

    rows = extract_courses_from_html(soup)
    save_csv(rows, OUTPUT_CSV)

    print(f"CSV generado: {OUTPUT_CSV}")
    print(f"Filas generadas: {len(rows)}")

    for row in rows[:20]:
        print(row)


if __name__ == "__main__":
    main()