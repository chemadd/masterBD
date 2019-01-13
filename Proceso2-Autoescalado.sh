clear
echo "Practica entrega - Apartado D --> Proceso 2: Autoescalado"
echo "Busca si la cola miFifo.fifo existe y si es así comprueba cada 15 segundos los mensajes encolados"
echo "para aumentar o disminuir la cantidad de instancias ec2 disponibles, hasta un maximo de 5"

urlQueue=$(aws --profile SQS sqs get-queue-url --queue-name miFifo.fifo 2>> error.log)
if [ -z "$urlQueue" ]; then
  echo "No hay que escalar: la cola no existe.";
else
  # limpiamos la url:
  urlQueue=$(echo $urlQueue | cut -d'"' -f 4)
  echo "Leemos de la cola: $urlQueue"

  numMensajes=1
  instancias_activas=1
  while [ $numMensajes -gt 0 ] || [ $instancias_activas -gt 0 ] 
  do
    # Obtenemos la cantidad de mensajes en la cola y actuamos en consecuencia
    json_numMensajes=$(aws --profile SQS sqs get-queue-attributes --queue-url $urlQueue \
                           --attribute-names ApproximateNumberOfMessages)
    # Obtenemos la cantidad de instancias activas
    instancias_activas=$(aws --profile EC2 ec2 describe-instances \
                             --filters "Name=instance-state-name,Values=running" \
                             --query 'Reservations[*].Instances[*].InstanceId' --output text | wc -l)
    numMensajes=$(echo "$json_numMensajes" | jq '.Attributes.ApproximateNumberOfMessages')
    eval "numMensajes=$numMensajes"
    if [ -z "$numMensajes" ]; then
      numMensajes=0
    fi
    echo "Quedan $numMensajes mensajes en la cola y tenemos $instancias_activas instancias activas"
    
    # Obtenemos indicador de escalado y actuamos segun algoritmo:
    numMensajes_aux=$numMensajes+9
    numMensajes_aux=$(echo "$numMensajes_aux/10" | bc )
    escalado=$(expr $numMensajes_aux - $instancias_activas)
    fecha_hora=$(date '+%d/%m/%Y %H:%M:%S')
    echo "$fecha_hora: El valor del algoritmo de escalado es: $escalado"
    if [ $escalado -lt 0 ] || [ $instancias_activas -gt 5 ]; then
      # Podemos tener mas de 5 instancias debido a que, al tardar un tiempo en crearse, no contabilizan como 'running',
      # por ello, si tenemos más, destruimos hasta quedarnos con 5
      idinstancia=$(aws --profile EC2 ec2 describe-instances --filters "Name=instance-state-name,Values=running" \
                        --query 'Reservations[0].Instances[*].InstanceId' --output text)
      echo "------ Destruimos una instancia:"
      echo "aws --profile EC2 ec2 terminate-instances --instance-ids $idinstancia"
      aws --profile EC2 ec2 terminate-instances --instance-ids $idinstancia
    elif [ $escalado -gt 0 ] && [ $instancias_activas -lt 5 ]; then
      echo "------ Creamos una instancia:"
      echo "aws --profile EC2 ec2 run-instances --image-id ami-1b791862 --count 1 --instance-type t2.micro"
      aws --profile EC2 ec2 run-instances --image-id ami-1b791862 --count 1 --instance-type t2.micro >> createinstances.log
    elif [ $escalado -eq 0 ]; then
      echo "--> No hacer nada"
    else
      echo "...Esperar a que se consuman mensajes..."
    fi
    echo "Esperamos 15 segundos........"
    sleep 15
  done
fi


