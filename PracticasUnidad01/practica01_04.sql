CREATE TABLE Institutos(Nombre_Inst CHAR(35), Area CHAR(35), Plazas INTEGER,
PRIMARY KEY ( Nombre_Inst ));

CREATE TABLE Estudiantes(ID INTEGER, Nombre_Est CHAR(35), Puntos REAL, Valor INTEGER,
PRIMARY KEY ( ID ),
UNIQUE ( ID ) );

CREATE TABLE Solicitudes(ID INTEGER, Nombre_Inst CHAR(35), Via CHAR(35), Decision CHAR(35),
PRIMARY KEY ( ID, Nombre_Inst, Via ),
FOREIGN KEY ( ID ) REFERENCES Estudiantes ( ID ),
FOREIGN KEY ( Nombre_Inst ) REFERENCES
Institutos ( Nombre_Inst ),
UNIQUE ( ID, Nombre_Inst, Via ) );

/*
    Obtener los nombres y notas de los estudiantes, así como el resultado de su solicitud, de manera que tengan un valor de corrección menor que 1000 y hayan solicitado la vía de “Tecnología” en el “Instituto Ramiro de Maeztu”.
*/
select Est.Nombre_Est, Est.Puntos, Sol.Decision
from Estudiantes Est
  inner join Solicitudes Sol
    on Est.ID = Sol.ID
where Est.Valor < 1000
  and Sol.Via   = 'Tecnologia'
  and Sol.Nombre_Inst = 'Instituto Ramiro de Maeztu'
  ;
/*
    Obtener la información sobre todas las solicitudes: ID y nombre del estudiante, nombre del instituto, puntos y plazas, ordenadas de forma decreciente por los puntos y en orden creciente de plazas.
*/
select Est.ID, Est.Nombre_Est, Sol.Nombre_Inst, Est.Puntos, Ins.Plazas
from Estudiantes Est
  inner join Solicitudes Sol
    on Est.ID = Sol.ID
  inner join Institutos Ins
    on Sol.Nombre_Inst = Ins.Nombre_Inst
order by Est.Puntos desc, Ins.Plazas asc
;
/*
    Obtener todas las solicitudes a vías denominadas como “Ciencias” o “Ciencias Sociales”.
*/

/*    Obtener los estudiantes cuya puntuación ponderada cambia en más de un punto respecto a la puntuación original.
*/

/*    Borrar a todos los estudiantes que solicitaron más de 2 vías diferentes.
*/

/*    Obtener las vías en las que la puntuación máxima de las solicitudes está por debajo de la media.
*/

/*    Obtener los nombres de los estudiantes y las vías que han solicitado.
*/

/*    Obtener el nombre de los estudiantes y la puntuación con valor de ponderación menor de 1000 que hayan solicitado la vía de “Tecnología” en el “Instituto San Isidro”.
*/
