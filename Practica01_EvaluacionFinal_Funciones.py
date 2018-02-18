
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
