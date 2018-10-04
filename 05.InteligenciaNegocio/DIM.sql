-- -----------------------------------------------------------------------------
-- Dimension Auditor: Metemos los auditores nuevos
-- -----------------------------------------------------------------------------
insert into D_Auditor (id_oficina, co_auditor)
select distinct oficina, cod_auditor
from TMP_Auditoria Aud
  left join D_Auditor Dim
    on Aud.oficina = Dim.id_oficina
   and Aud.cod_auditor = Dim.co_auditor
where Dim.co_auditor IS NULL;

-- -----------------------------------------------------------------------------
-- Dimension Geografia: Metemos las zonas geográficas nuevas.
-- -----------------------------------------------------------------------------
-- Utilizamos el nombre mas repetido como el representativo de cada nombre estandarizado.

-- Buscamos los nombres de poblacion mas usados por cada poblacion_standard
-- DROP TABLE TMP_Maximo;
-- Para evitar duplicados, ordenamos por el numero de repeticiones en orden descendente y 
-- asignamos un valor incremental. Luego nos quedamos con el menor de ellos para así quedarnos
-- con el nombre de población más repetido (y nos sirve también para evitar los duplicados
-- en el caso de que dos nombres tengan el mismo valor de repeticiones máximas)
create table TMP_Maximo(
  id_mas_repetida    int NOT NULL auto_increment,
  POBLACION_STANDARD varchar(100) NULL,
  POBLACION          varchar(100) NULL,
  qt_veces           int          NULL,
  PRIMARY KEY (id_mas_repetida)
);
insert into TMP_Maximo (POBLACION_STANDARD, POBLACION, qt_veces)
select POBLACION_STANDARD, POBLACION, COUNT(*) as qt_veces
from TMP_Auditoria
group by POBLACION_STANDARD, POBLACION
order by count(*) desc
;
-- DROP TABLE TMP_Auditoria_Geografia;
create table TMP_Auditoria_Geografia
select upper(PobMax.POBLACION_STANDARD) as poblacion_standard, 
       upper(PobMax.POBLACION) as poblacion
-- SELECT COUNT (DISTINCT PobMax.POBLACION_STANDARD)
from TMP_Maximo PobMax,
     (
      select POBLACION_STANDARD, MIN(id_mas_repetida) as mas_repetido
	  from TMP_Maximo
      group by POBLACION_STANDARD
	 ) Mas
where PobMax.poblacion_standard = Mas.poblacion_standard
  and PobMax.id_mas_repetida = Mas.mas_repetido
;

-- Insertamos en la dimensión las zonas geográficas nuevas:
-- Para cada nombre de poblacion usamos el mas repetido para insertarlo en la dimension.
insert into D_Geografia (id_codigo_postal, no_poblacion, no_poblacion_standard, no_provincia, no_pais)
select distinct cp, coalesce(upper(TMPGeo.poblacion), 'N/A') as poblacion,
       TMPGeo.poblacion_standard, 
       upper(provincia) as no_provincia, 
       case when coalesce(upper(provincia),'') <> 'EXTRANJERO' then 'España' else 'Extranjero' end
from TMP_Auditoria Aud
  left join TMP_Auditoria_Geografia TMPGeo
    on Aud.poblacion_standard = TMPGeo.poblacion_standard
  left join D_Geografia Dim
    on Aud.cp               = Dim.id_codigo_postal
   and coalesce(upper(TMPGeo.poblacion), 'N/A') = upper(Dim.no_poblacion)
   and upper(Aud.provincia) = upper(Dim.no_provincia)
where Dim.id_codigo_postal IS NULL
;
drop table TMP_Auditoria_Geografia;
drop table TMP_Maximo;

-- -----------------------------------------------------------------------------
-- Dimension Local: Metemos los locales nuevos
-- -----------------------------------------------------------------------------
insert into D_Local (co_local, no_local, id_geografia)
select distinct COD_LOC, NOMBRE_LOC, Geo.id_geografia
-- select *
from TMP_Auditoria Aud
  left join D_Local Dim
    on Aud.cod_loc = Dim.co_local
   and Aud.nombre_loc = Dim.no_local
  left join D_Geografia Geo
    on Aud.cp               = Geo.id_codigo_postal
   and upper(Aud.poblacion_standard) = upper(Geo.no_poblacion_standard)
   and upper(Aud.provincia) = upper(Geo.no_provincia)
where Dim.co_local IS NULL
;