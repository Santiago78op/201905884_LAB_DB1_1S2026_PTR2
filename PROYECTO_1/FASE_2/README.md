# Prompts de ejemplo para usar el agente:

1. Valida estas 5 consultas Oracle contra el DDL y corrige joins/FK inconsistentes.
2. Revisa si esta consulta cumple el requerimiento funcional y documenta cada bloque con comentarios técnicos.
3. Corrige esta consulta para Oracle SQL puro, sin cambiar DDL y explicando cada supuesto aplicado.
4. Personalizaciones relacionadas que te recomiendo crear después:

# Una instrucción de estilo SQL para imponer formato y convenciones de alias/comentarios en todo el repo.
1. Un prompt reutilizable para validar consultas por lote con parámetros de semestre y carnet.
2. Un agente de solo auditoría (read/search sin edit) para revisión previa antes de aplicar cambios.
3. No ejecuté las consultas en una base Oracle real desde aquí, así que la validación fue estructural/lógica contra el DDL y sintaxis