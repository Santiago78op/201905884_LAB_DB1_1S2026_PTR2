/*
* Dar el nombre de los estudiantes que han ganado algún curso con alguno de los catedráticos que han impartido alguno de los cursos de la  carrera de sistemas en alguno de los planes que se impartieron en el semestre pasado.
*/
SELECT DISTINCT
    e.nombre AS Estudiante
FROM asignacion a
JOIN estudiante e ON
    e.carnet = a.estudiante_carnet
JOIN inscripcion i ON
    i.estudiante_carnet = a.estudiante_carnet
JOIN plan p ON
    p.carrera_carrera = i.carrera_carrera
JOIN seccion s ON
    s.seccion = a.seccion_seccion
    AND s.anio = a.seccion_anio
    AND s.ciclo = a.seccion_ciclo
    AND s.curso_codigocurso = a.seccion_curso_codigocurso
JOIN catedratico c ON
    c.catedratico = s.catedratico_catedratico
JOIN pensum pe ON
    pe.curso_codigocurso = s.curso_codigocurso
    AND pe.plan_plan = p.plan
    AND pe.plan_carrera_carrera = p.carrera_carrera
WHERE i.carrera_carrera = 9
    AND a.nota >= pe.notaaprobacion
    AND a.zona >= pe.zonaminima
    AND s.anio = 2010
    AND s.ciclo = 'CICLO1';