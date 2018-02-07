#!/bin/bash
function ver_directorio {
  ls -l
};

function copiar_archivos {
  echo Introduzca archivo a copiar: 
  read file1
  echo Introduzca archivo destino:
  read file2
  cp $file1 $file2
};

function editar_archivo {
  echo Introduzca el archivo a editar:
  read file
  vim $file
};

function imprimir_archivo {
  echo Introduzca el archivo a imprimir:
  read file
  cat $file
  # lpr $file
};

while true 
do

echo "
Ver directorio actual....[1]
Copiar archivos..........[2]
Editar archivo...........[3]
Imprimir archivo.........[4]
Salir....................[5]
Escribir accion....
"
read opcion
clear
# echo $opcion
case $opcion in
	1) ver_directorio
	;;
        2) copiar_archivos
	;;
        3) editar_archivo
        ;;
        4) imprimir_archivo
	;;
        5) clear; break
	;;
        *) echo No hay accion para el valor $opcion
	;;
esac
# clear

done
