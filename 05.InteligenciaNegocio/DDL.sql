-- drop table TMP_Auditoria;
-- -----------------------------------------------------------------------------
create table TMP_Auditoria (
-- -----------------------------------------------------------------------------
  COD_LOC             varchar(100) NULL,
  NOMBRE_LOC          varchar(100) NULL,
  CP                  integer      NULL,
  POBLACION           varchar(100) NULL,
  OFICINA             varchar(100) NULL,
  PROVINCIA           varchar(100) NULL,
  COD_PROY            varchar(100) NULL,
  ID_EVALUACION       integer      NULL,
  Fecha_jecucion      date         NULL,
  COD_AUDITOR         varchar(100) NULL,
  RESULTADO           double       NULL,
  TITULO_CUESTIONARIO varchar(100) NULL
);


-- drop table D_Auditor;
-- -----------------------------------------------------------------------------
create table D_Auditor (
-- -----------------------------------------------------------------------------
  id_auditor int        NOT NULL auto_increment,
  id_oficina varchar(3) NULL,
  co_auditor varchar(25)NULL,
  PRIMARY KEY (id_auditor),
  UNIQUE KEY UK01_D_Auditor (id_auditor),
  UNIQUE KEY UK02_D_Auditor (id_oficina,co_auditor)
);

-- drop table D_Geografia;
-- -----------------------------------------------------------------------------
create table D_Geografia (
-- -----------------------------------------------------------------------------
  id_geografia     int          NOT NULL auto_increment,
  id_codigo_postal int          NULL,
  no_poblacion     varchar(100) NULL,
  no_provincia     varchar(100) NULL,
  no_pais          varchar(100) NULL,
  PRIMARY KEY (id_geografia),
  UNIQUE KEY UK01_D_Geografia (id_geografia),
  UNIQUE KEY UK02_D_Geografia (id_codigo_postal)
);
insert into D_Geografia (id_codigo_postal, no_poblacion, no_provincia, no_pais)
select 99999, 'N/A', 'N/A', 'N/A';

-- drop table D_Local;
-- -----------------------------------------------------------------------------
create table D_Local (
-- -----------------------------------------------------------------------------
  id_local     int          NOT NULL auto_increment,
  co_local     varchar(50)  NULL,
  no_local     varchar(200) NULL,
  id_geografia int          NULL,  -- FK a D_Geografia
  PRIMARY KEY (id_local),
  UNIQUE KEY UK01_D_Local (id_local),
  UNIQUE KEY UK02_D_Local (co_local),
  CONSTRAINT FOREIGN KEY FK01_D_Local (id_geografia)
    REFERENCES D_Geografia(id_geografia)
);

-- drop table D_Fecha;
-- -----------------------------------------------------------------------------
create table D_Fecha (
-- -----------------------------------------------------------------------------
  id_fecha     int         NOT NULL auto_increment,
  dt_fecha     date        NOT NULL,
  id_mes       tinyint     NOT NULL,
  no_mes       varchar(20) NULL, 
  id_ano       smallint    NOT NULL,
  no_dia       varchar(20) NULL, 
  id_trimestre tinyint     NOT NULL,
  no_trimestre varchar(2)  NOT NULL,
  PRIMARY KEY (id_fecha),
  UNIQUE KEY UK01_D_Local (id_fecha),
  UNIQUE KEY UK02_D_Local (dt_fecha)
);

delimiter ;;
drop procedure if exists proc_rellenar_dias;;
create procedure proc_rellenar_dias(in cantdias int) 
begin
  select coalesce(max(dt_fecha), date('2012-12-31')) into @maximodia from D_Fecha;
  set @totaldias := cantdias;
  set @numdias := 1;
  set lc_time_names = 'es_ES';
  
	while (@numdias <= @totaldias) do
      insert into D_Fecha (dt_fecha, id_mes, no_mes, id_ano, no_dia, id_trimestre,no_trimestre)
      select date_add(@maximodia, interval @numdias day) as dt_fecha,
         date_format(date_add(@maximodia, interval @numdias day), '%c') as id_mes,
         date_format(date_add(@maximodia, interval @numdias day), '%M') as no_mes,
         date_format(date_add(@maximodia, interval @numdias day), '%Y') as id_ano,
         date_format(date_add(@maximodia, interval @numdias day), '%W') as no_dia,
         case when date_format(date_add(@maximodia, interval @numdias day), '%c') <= 3 then 1
              when date_format(date_add(@maximodia, interval @numdias day), '%c') > 3 
			   and date_format(date_add(@maximodia, interval @numdias day), '%c')<= 6 then 2
              when date_format(date_add(@maximodia, interval @numdias day), '%c') > 6
               and date_format(date_add(@maximodia, interval @numdias day), '%c')<= 9 then 3
              when date_format(date_add(@maximodia, interval @numdias day), '%c') > 9 then 4
		 end as id_trimestre,
         case when date_format(date_add(@maximodia, interval @numdias day), '%c') <= 3 then 'Q1'
              when date_format(date_add(@maximodia, interval @numdias day), '%c') > 3 
               and date_format(date_add(@maximodia, interval @numdias day), '%c')<= 6 then 'Q2'
              when date_format(date_add(@maximodia, interval @numdias day), '%c') > 6 
               and date_format(date_add(@maximodia, interval @numdias day), '%c')<= 9 then 'Q3'
              when date_format(date_add(@maximodia, interval @numdias day), '%c') > 9 then 'Q4'
		 end as no_trimestre
		
      ;
      set @numdias := @numdias + 1;
	end while;
end
;;
delimiter ;
call proc_rellenar_dias(800);
select *
from D_Fecha
;
-- drop table D_Cuestionario;
-- -----------------------------------------------------------------------------
create table D_Cuestionario (
-- -----------------------------------------------------------------------------
  id_cuestionario int          NOT NULL auto_increment,
  no_cuestionario varchar(200) NOT NULL, 
  co_proyecto     varchar(10)  NOT NULL,
  PRIMARY KEY (id_cuestionario),
  UNIQUE KEY UK01_D_Cuestionario (id_cuestionario),
  UNIQUE KEY UK02_D_Cuestionario (no_cuestionario)
);

-- drop table F_Evaluacion;
-- -----------------------------------------------------------------------------
create table F_Evaluacion (
-- -----------------------------------------------------------------------------
  id_evaluacion   int    NOT NULL,
  id_fecha        int    NOT NULL,
  id_auditor      int    NOT NULL,
  id_geografia    int    NOT NULL,
  id_local        int    NOT NULL, 
  id_cuestionario int    NOT NULL, 
  vl_resultado    double NOT NULL,
  PRIMARY KEY (id_fecha),
  UNIQUE KEY UK01_F_Evaluacion (id_evaluacion)
);
