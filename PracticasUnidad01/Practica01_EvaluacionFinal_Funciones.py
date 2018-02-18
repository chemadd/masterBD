
# coding: utf-8

def obtenerTweetsConTexto (ficheroTweets, idioma):
    import json
    fichero = open(ficheroTweets)
    # Devuelve una lista de diccionarios solo con los elementos a analizar 
    # (aquellos que tengan key 'text') y esten en el idioma pasado como parametro
    tweetsDatos = fichero.readlines()
    # Tras leer el fichero, tenemos una lista de textos con formato JSON que podemos
    # descomponer. Asumimos que cada id de tweeter es unico por lo que puede usarse
    # como clave en un diccionario final:
    tweetsAnalizar = {}
    null = None
    for tweet in tweetsDatos:
        try: jsonDict = json.loads(tweet)
        except: jsonDict = None
        if 'text' in jsonDict.keys() and jsonDict['lang']==idioma:
            tweetsAnalizar[jsonDict['id']]=jsonDict['text'] 
    return tweetsAnalizar

def obtenerSentimientos(ficheroSentimientos):
    # Devuelve un diccionario asociando a cada sentimiento su valor
    fichero = open(ficheroSentimientos)
    listaSentimientos = fichero.readlines()
    # Basandonos en la estructura, en cada elemento de la lista hay una cadena de dos
    # palabras separadas por un tabulador \t --> Generamos un diccionario para 
    # explotarlo mejor
    sentimientosDict = {}
    for sentimiento in listaSentimientos:
        listaFila = sentimiento.split('\t')
        sentimientosDict[listaFila[0]] = int(listaFila[1])
    return sentimientosDict

def obtenerSentimientosTweets(ficheroSentimientos, ficheroTweets, idioma):
    # Devuelve un diccionario donde las claves son los ids de tweets y los valores
    # son un diccionario con 'texto', 'sentimiento' y 'valoracion'
    # Primero obtenemos los tweets en lista de diccionarios y el diccionario
    # de palabras con sus valores de sentimiento, para tweets en el idioma indicado
    tweetsAnalizar = obtenerTweetsConTexto (ficheroTweets, idioma)
    sentimientosAplicar = obtenerSentimientos(ficheroSentimientos)
    # Recorrer cada tweet buscando todos los sentimientos que pueda tener y aplicar
    # la suma de sus valores. 
    sentimientosDict = {}
    for tweet in tweetsAnalizar:
        # Dado que los sentimientos pueden contener espacios, usamos find, en lugar 
        # de splitear y buscar por keys:
        valorSentimiento = 0
        listaSentimientos = []
        for sentimiento in sentimientosAplicar:
            if (tweetsAnalizar[tweet].find(' '+sentimiento+' ') >= 0 # Palabra completa
              or tweetsAnalizar[tweet].find(sentimiento+' ') == 0 # Primera palabra
              or tweetsAnalizar[tweet].find(' '+sentimiento, len(tweetsAnalizar[tweet]) - len(' '+sentimiento), len(tweetsAnalizar[tweet])) >= 0 # Ultima palabra
               ):
                listaSentimientos = listaSentimientos + [sentimiento + ' ' + str(sentimientosAplicar[sentimiento])]
                valorSentimiento = valorSentimiento + sentimientosAplicar[sentimiento]
        # print(tweet,tweetsAnalizar[tweet], valorSentimiento, listaSentimientos)
        sentimientosDict[tweet] = { 'texto':tweetsAnalizar[tweet], 'sentimiento':valorSentimiento, 'valoracion':listaSentimientos }
    return sentimientosDict

def limpiaPalabra(palabra):
    # Proceso que elimina de las palabras los caracteres extraños y devuelve palabra 'correctas'
    # Pretende ser algo simple, se podria aplicar limpieza con la libreria unidecode y mayor logica al control
    # de eliminacion de signos de puntuacion
    # Tambien se podria devolver una palabra vacia para indicar que la cadena de caracteres no es una palabra
    # valida
    palabraLimpia = palabra.replace('#','')
    palabraLimpia = palabraLimpia.replace('!','')
    palabraLimpia = palabraLimpia.replace('?','')
    palabraLimpia = palabraLimpia.replace('.','')
    palabraLimpia = palabraLimpia.replace(',','')
    palabraLimpia = palabraLimpia.replace('(','')
    palabraLimpia = palabraLimpia.replace(')','')
    
    return palabraLimpia.lower()

def obtenerPalabrasSentimientosTweets(ficheroSentimientos, ficheroTweets, idioma):
    # Devuelve un diccionario asociando a cada palabra
    # un valor calculado de los sentimientos de los tweets en los que aparece.
    # El calculo es la media (redondeada) de los sentimientos de los tweets en 
    # los que aparecen
    resultado = obtenerSentimientosTweets(ficheroSentimientos, ficheroTweets, idioma)
    # Buscamos las palabras de tweets que no aparecen en sentimientos.
    # En resultado tenemos, para cada tweet, su texto, sentimiento y las palabras que 
    # han generado ese sentimiento. Asociamos a cada palabra que no este en 'valoracion'
    # el valor del sentimiento del tweet. Puesto que se va a hacer la media,
    # se incrementa el valor del sentimiento de cada una y tambien el contador de
    # apariciones, para poder hacer la media al final de su valoracion
    valoracionPalabras = dict()
    for idTweet in resultado:
        # 1. Descomponemos las palabras del texto del tweet
        listaPalabras = resultado[idTweet]['texto'].split()
        # 2. A la valoracion de cada palabra le incrementamos el sentimiento del tweet
        #    Incrementamos el contador de veces que aparece cada palabra para hacer
        #    la media al final.
        for palabra in listaPalabras:
            palabraTransform = limpiaPalabra(palabra)
            if palabraTransform in valoracionPalabras.keys():
                valoracionPalabras[palabraTransform]['valoracion'] = valoracionPalabras[palabraTransform]['valoracion'] + resultado[idTweet]['sentimiento']
                valoracionPalabras[palabraTransform]['conteo'] = valoracionPalabras[palabraTransform]['conteo'] + 1
            elif len(palabra) > 1:
                # Evitamos valorar signos de puntuacion o caracteres aislados
                valoracionPalabras[palabraTransform] = {'valoracion':resultado[idTweet]['sentimiento'], 'conteo':1}             
    # Ahora que ya tenemos la lista de palabras, obtenemos la media de sus sentimientos
    mediaPalabras = dict()
    for palabra in valoracionPalabras:
        if valoracionPalabras[palabra]['conteo'] == 0:
            mediaPalabras[palabra] = 0
        else:
            mediaPalabras[palabra] = round(valoracionPalabras[palabra]['valoracion']/valoracionPalabras[palabra]['conteo'])
    return mediaPalabras