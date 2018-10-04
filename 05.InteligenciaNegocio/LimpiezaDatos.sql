-- Limpiamos la poblacion. Buscamos un nombre estándar eliminando caracteres que se pueden
-- introducir de forma incorrecta (tildes, puntos,...)

-- Paso 1: Limpieza de caracteres extraños o nombres de provincia
update TMP_Auditoria
set POBLACION_STANDARD = replace(replace(replace(replace(replace(replace(
          replace(replace(replace(
          replace(replace(replace(
          -- Nos quedamos sólo con el nombre de la poblacion, eliminando la provincia en su caso
            substring_index(substring_index(substring_index(substring_index(
            upper(poblacion)
            , ',', 1), '-', 1), '/', 1), '(', 1),
          '.',''),'-',''),'-',''),
          ' DEL ',''),' DE ',''),' DE LA ',''),
          'Ú','U'),'Ó','O'),'Í','I'),'É','E'),'Á','A'),' ','')
where poblacion IS NOT NULL
;

-- Paso 2: Eliminamos articulos al comienzo del nombre
update TMP_Auditoria
set POBLACION_STANDARD = substring(upper(POBLACION_STANDARD), 3)
where upper(poblacion) like 'L\'%'
   or upper(poblacion) like 'O\'%'
   or upper(poblacion) like 'LA %'
   or upper(poblacion) like 'EL %'
   or upper(poblacion) like 'L´%'
;
update TMP_Auditoria
set POBLACION_STANDARD = substring(upper(POBLACION_STANDARD), 4)
where upper(poblacion) like 'LAS %'
   or upper(poblacion) like 'LOS %'
;
update TMP_Auditoria
set POBLACION_STANDARD = substring(upper(POBLACION_STANDARD), 3)
-- select POBLACION,POBLACION_STANDARD,substring(upper(POBLACION_STANDARD), 2) from TMP_Auditoria
where upper(poblacion) like 'A %'
   or upper(poblacion) like 'O %'
;
   
-- Quedarían todavía casos por tratar, que habría que verificar de uno en uno, para tratar
-- de generalizar o bien manejar de forma individual obtener un estandarizacion completa de nombres.
