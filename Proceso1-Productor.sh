clear
echo "Practica entrega - Apartado D --> Proceso 1: Productor"
echo "Proceso que creará la cola si no existe, o la vaciará en caso contrario."
echo "Después de esto la rellenará con 100 mensajes"

urlQueue=$(aws --profile SQS sqs get-queue-url --queue-name miFifo.fifo 2> error.log)
if [ -z "$urlQueue" ]; then
  urlQueue=$(aws --profile SQS sqs create-queue --queue-name miFifo.fifo --attributes \
	{\"FifoQueue\":\"true\"} 2>> error.log)
  echo "Creamos la cola porque no existia. Su url es: $urlQueue";
fi

# limpiamos la url:
urlQueue=$(echo $urlQueue | cut -d'"' -f 4)
echo "La cola es: $urlQueue"

echo "Purgamos la cola"
aws --profile SQS sqs purge-queue --queue-url $urlQueue

echo "Una vez creada o vaciada la cola le vamos enviando mensajes cada segundo hasta alcanzar 100"
for i in {1..100}
do
  fecha_hora=$(date '+%d/%m/%Y %H:%M:%S');
  echo "$fecha_hora: Mensaje $i enviado a cola $urlQueue"
  aws --profile SQS sqs send-message --queue-url $urlQueue \
      --message-body "$fecha_hora: Mensaje $i en cola $urlQueue" \
      --message-group-id "COLA1" \
      --message-deduplication-id "$i"
done
