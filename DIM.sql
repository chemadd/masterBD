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
insert into D_Geografia (id_codigo_postal, no_poblacion, no_provincia, no_pais)
select distinct cp, poblacion, provincia, 
                case when provincia <> 'EXTRANJERO' then 'España' else 'Extranjero' end
from TMP_Auditoria Aud
  left join D_Geografia Dim
    on Aud.cp        = Dim.id_codigo_postal
   and Aud.poblacion = Dim.no_poblacion
where Dim.id_codigo_postal IS NULL;

select *
-- select count(*)
from TMP_Auditoria


select *
from D_Geografia;