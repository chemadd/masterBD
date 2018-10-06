select *
from F_Evaluacion
;

insert into F_Evaluacion 
  (id_evaluacion,id_fecha,id_auditor,id_geografia,id_local,id_cuestionario,vl_resultado)
select Nue.id_evaluacion,Nue.id_fecha,Nue.id_auditor,Nue.id_geografia,Nue.id_local,Nue.id_cuestionario,Nue.vl_resultado
from 
(
  select TMP.id_evaluacion,
	   Fec.id_fecha,
	   Aud.id_auditor,
       coalesce(Geo.id_geografia,1) as id_geografia,
       Loc.id_local,
       Cue.id_cuestionario,
       TMP.RESULTADO as vl_resultado
       -- select *
from TMP_Auditoria TMP
  left join D_Fecha Fec
    on TMP.Fecha_jecucion = Fec.dt_fecha
  left join D_Auditor Aud
    on TMP.oficina = Aud.id_oficina
   and TMP.cod_auditor = Aud.co_auditor
  left join D_Geografia Geo
    on TMP.cp               = Geo.id_codigo_postal
   and coalesce(upper(TMP.poblacion_standard), 'N/A') = upper(Geo.no_poblacion_standard)
   and upper(TMP.provincia) = upper(Geo.no_provincia)
  left join D_Local Loc
    on TMP.cod_loc = Loc.co_local
   and TMP.nombre_loc = Loc.no_local
   and coalesce(Geo.id_geografia,1) = Loc.id_geografia
  left join D_Cuestionario Cue
    on TMP.TITULO_CUESTIONARIO = Cue.no_cuestionario
   and TMP.COD_PROY = Cue.co_proyecto
) Nue
  left join F_Evaluacion Vie
    on Nue.id_evaluacion = Vie.id_evaluacion
where Vie.id_evaluacion IS NULL
;