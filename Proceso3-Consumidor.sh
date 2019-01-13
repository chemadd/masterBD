clear
echo "Practica entrega - Apartado D --> Proceso 3: Consumidor"
echo "Busca si la cola miFifo.fifo existe y si es así va leyendo mensajes cada 6 segundos."

urlQueue=$(aws --profile SQS sqs get-queue-url --queue-name miFifo.fifo 2>> error.log)
if [ -z "$urlQueue" ]; then
  echo "No se puede leer de la cola puesto que no existe";
else
  # limpiamos la url:
  urlQueue=$(echo $urlQueue | cut -d'"' -f 4)
  echo "Leemos de la cola: $urlQueue"
  hayMensajes=1
  while [ $hayMensajes -eq 1 ] 
  do
    # Leemos mensajes cada 6 segundos mientras haya mensajes en la cola
    mensaje=$(aws --profile SQS sqs receive-message --queue-url $urlQueue \
                  --visibility-timeout 30 | jq '.Messages')

    if [ -z "$mensaje" ]; then
      echo "Ya se han leido todos los mensajes de la cola";
      hayMensajes=0
    else
      fecha_hora=$(date '+%d/%m/%Y %H:%M:%S')
      echo "$fecha_hora: Mensaje leido:" 
      # Puesto que devuelvo formato JSON usamos jq para obtener sus atributos:
      echo "$mensaje" | jq '.[]' | jq '.Body'
      # Recuperamos el handler para poder eliminar el mensaje de la cola
      mensajeHandle=$(echo $mensaje | jq '.[]' | jq '.ReceiptHandle')
      # No se bien por qué, pero si no se hace el borrado con eval siempre da error de handler 
      # desconocido aunque el comando ejecutado sea correcto ejecutándolo a mano.
      cmd_borrado="aws --profile SQS sqs delete-message --queue-url $urlQueue --receipt-handle $mensajeHandle"
      eval $cmd_borrado
      sleep 6
    fi
  done
fi
