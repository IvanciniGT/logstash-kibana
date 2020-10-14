ElasticSearch: INDEXAR información
    ¿Qué indexa elasticsearch?
        Solo JSON
        PDF, WORD -> 1- Extraer todo el texto del documento
                     2- Generar un JSON con el texto incrustado dentro
    ¿Cómo indexa?
        Terminos??? No está mal, pero....
        Por abajo usa Lucene <- Shards: Fragmentos
    Usos:
        1- Backend de una aplicación para la realización de Búsquedas de contenidos:
            Aplicación para la GESTION de Incidencias: Alta, baja, modificación, control del estado
            Asociado a la incidencia hay documentos adjuntos: PDF, WORD, Metadatos (JSON)
                Búsquedas dentro de mi app de GESTION, pero búsquedas 'FULLTEXT'
                    Usamos ElasticSearch
            Los datos los guardamos en un BBDD tradicional: 
                Relacional: Oracle, MariaDB, MySQL,...
                Objetos:    Mongo
            En paralelo, los datos los indexo con ElasticSearch para poder hacer búsquedas.
        2- Repositorio de información <- Secundario
            Usar Elastic como una Base de Datos -> Sustituyendo a un MongoDB (objetos)
            Si adicionalmente quiero hacer búsquedas 'FULLTEXT' dentro de los datos.
            Datos sencillos
            Gracias a una característica que tiene Elastic:
                A la hora de indexar un documento, permite OPCIONALMENTE guardar una copia del original
            
            2.a-> Monización de sistemas informáticos <--- ES EL USO MAYORITARIO de un elasticSearch
                Utilizar Elasticsearch para guardar datos de EVENTOS que ocurren en un sistema informático:
                    Hardware
                    Software
                Búsquedas FULLTEXT sobre los EVENTOS
                    - Explotar los datos que hay se encuentren <- NO LA HACE ELASTICSEARCH: LA HACE KIBANA
                Los datos los alimentamos de forma automática, normalmente desde un 'LOGSTASH' (KAFKA)
                
                Stack ELK: 
                    B->L->(Kf)->E->K
                        B:  Recoge información
                        L:  Condensar y transformar la información
                                - Recoger información  <- Normalmente esto lo haremos con BEATS
                                -> Procesar/Transformar la información (Algunas de ellas, otras en Elastic)
                                -> Distribuir la información -> ACTIVA
                        Kf: Garantizar la entrega de la información (asíncrona)
                                -> Gestionar colas con la información (Pueden ser PERSISTENTES)-> High Availability
                                -> Transformación de datos <- No lo vamos a usar mucho
                                -> Distribuir la información <- PASIVA (asincronismo)
                        E:  Almacenar, indexar y recuperar información
                                -> Todo tipo de Tranformaciones (pero no siempre interesa hacer TODO en elastic)
                                -> Indexación
                                -> Búsquedas/Recuperación de información
                        K:  Explotar la información
Logstash
    INGESTA (Parseo, filtrado, agregación, enriquecimiento)
Kibana
    Visualizr los datos, Explotarlos (estadísticas, ML, ...)
    Administración - Monitorización del cluster
Beats: Es otro producto de Elastic
    ProgramITAS que recogen información:
        FileBeat        Leer ficheros
        HeartBeat       Determinar el estado de un maquina/Servicio      
        AuditBeat       Registro de eventos de máquinas Linux
        WinlogBeat      Registro de eventos de máquinas Windows
        MetricBeat      Estadísticas de la máquina (CPU, RAM, HDD, ....)
-> Opcional: Kafka



Cluster de servidores físicos/virtuales:
    Maquina 1   <- MetricBeat
    Maquina 2   <- MetricBeat
    Maquina 3   <- MetricBeat
    ...
    Maquina 10  <- MetricBeat:
                      A: Leer los datos del servidor (CPU, RAM, HDD) según una escala de tiempo (5 seg)
                      B: Enviar la información a LOGSTASH. ¿Cómo se hace, cómo funciona?
                            Comunicación, protocolo??? TCP/IP + BEATS
                            Se va a conectar un logstash en un puerto
                            ¿Cómo se envían los datos? LOS DATOS ( eventos ) SE ENVIAN UNO A UNO

    Maquina A: Logstash --> Puerto de escucha (BEAT) H.A. <- Docker + Kubernetes
    Maquina B: Logstash --> Puerto de escucha (BEAT) H.A. <- Docker + Kubernetes
    Maquina C: Kafka   <--- Docker
    Maquina D: Kafka   <--- Docker
Qué quiero???
    1- Monitorizar las máquinas físicas: CPU, RAM, HDD
        a: Extraer los datos: BEATS: MetricBeat
            Instalación de los MetricBeats: Docker, Automatizar la instalación con Puppet, Ansible, Chef
            Ventajas de los beats:
                Facilidad de configuración
                Descargo los servidores donde se ejecutan: No es necesario almacenar información en las propias máquinas 
                Muy ligeros
        b: Procesamiento en Logstash
            Tranformación
                Parseo de Datos:            Determinar los datos concretos que me están llegando (Linea de texto -> campos)
                            "10-10-2020  13:47  192.167.23.54   Ubuntu   CPU: 50%|RAM:6Gbs(75%)|HDD:234Gb(10%)"
                                Parseado:
                                    Fecha:   "10-10-2020"
                                    Hora:    "13:47"
                                    SO:      "Ubuntu"
                                    CPU:     "50%"
                                    HDD:     "236Gbs"
                                    HDD_Ptc: "10%"
                Agregación/Enriquecimiento:
                    -> IP <- Geolocalizarla (Extraer datos de una BD de geolocalización)
                Conversión de datos
                    Fecha:   "10-10-2020"   ->  número: 10-10-2020
                    Hora -> número
                    CPU: -> número
                Filtrado
                    -> Eventos: Algunos eventos no los quiero procesar: En base a la información de algunos campos, ignoro datos
                    -> Datos:   Algunos datos no los quiero procesar: RAM no me interesa
            Distribuirlos:
                -> Kafka  -> GUAY. La comunicación entre Logstash y Elastic a través de un Kafka es Asíncrona.
                                    Si elastic no responde, está caido, está al 100%....
                                    Kafka gurda temporalmente la información 
                -> Elastic <- FEO. La comunicación entre Logstash y Elastic es SINCRONA. Si elastic no responde .... problema
        c: La información llega a ElasticSearch (Bien desde logstash, bien desde Kafka)
                Elastic debe indexar esa información (Formato de entrada JSON):
                Previamente puede ser necesario transformar (preparar) la información
        d: Kibana: Para hacer estudio de los datos: 
            Dashboards -> Cuadros de mando
            Búsquedas, Informes
            Algoritmos de Machine learning y de datamining <-
                

-------------------------------------------------------------------------------
Diferencia entre Almacenar información e Indexar Información

Almacenar información: Es guardarla tal cual
Indexar información:   Acelerar búsquedas

Teoria de Bases de datos básica... Nivel 1:
    Datos en una base de datos... Donde están esos datos guardados???
        Fichero(s) -> Disco (y opcionalmente en RAM)
    ¿Cómo se hace una búsqueda?
        Forma más básica: "FULL SCAN": Leer el fichero de arriba a abajo, entero, buscando los contenidos que quiera.
            -> Ventaja: Añadir palabras es muy rápido:
                    Las pongo al final
            -> Inconvenientes: LENTO a rabiar !!!!!!! Orden de complejidad del algoritmo (n). 
                Esto empeora mucho con el número de datos
        Formas de búsqueda más avanzadas:
            Tener los datos PREORDENADOS:
                Diccionario/ Enciclopedia
                    Búsqueda muy rápidas: Búsqueda binaria ->                   Van partiendo a la mitad
                                          Búsqueda basada en estadísticas ->    Van partiendo según dicten las estadísticas
                -> Ventaja: Búsqueda es muy rápida: Orden de complejidad < log(n)
                -> Inconvenientes: 
                        Actualizar el diccionario: Una palabra nueva la tengo que poner en sus sitio:
                            1. Identificar donde tengo que poner la nueva palabra
                            2. Shifting: Mover las palabras de detrás
                        ¿En base a qué campo ordeno los datos? Solo puedo elegir uno
            INDICES:
                Listado ORDENADO de tokens, con ubicaciones
                        LIBRO de recetas:
                            TOKENS      UBUCACIONES
                            ------------------------------
                            ATUN        Pag 12, 13, 17, 58
                            TERNERA     Pag 23, 98, 115
                -> Ventaja: Búsqueda es muy rápida: Orden de complejidad < log(n)
                            Podemos tener los datos ordenados por varios campos.... Tengo varios indices
                -> Inconvenientes: 
                        Lo tengo que hacer ahora para cada indice:
                            Actualizar los datos: Una palabra dato la tengo que poner en sus sitio:
                                1. Identificar donde tengo que poner la nueva palabra
                                2. Shifting: Mover las palabras de detrás
                        Necesitan mucho más espacio, porque escribo más....
                        Estos problema se hace todavía MUCHO MAYORES cuando queremos hacer búsquedas FULL TEXT
                        

Búsquedas Fulltext +- búsquedas que hacemos en google
    
    "En las casas de mis vecinas se comen lentejas muy ricas."
    Palabra: "casas de mis vecinas"

    Indices de texto: Indices invertidos:
        Separar cada palabra... ¿Cómo sabe elastic lo que una palabra? TOKENIZADOR -> Delimitadores, patrones
            En las casas de mis vecinas se comían lentejas muy ricas.
                En, las, casas, de, mis, vecinas, se, comían, lentejas, muy, ricas, .
        Eliminar los signos de puntuación u otros caracteres que no sean relevantes
            En, las, casas, de, mis, vecinas, se, comían, lentejas, muy, ricas
            BUSQUEDA: CASAS
        Normalizar los carácteres: Conctrol del case (may, min, ...) + acentos
            en, las, casas, de, mis, vecinas, se, comian, lentejas, muy, ricas
            BUSQUEDA: CASA
        Otro tipo de transformaciones: Plurales, géneros, ....
            '91-987-98-98'
    Todo el trabajo de indexación lo hace LUCENE, que son los SHARDS, que existen dentro de los nodos de DATOS.
    
    Puede ser necesario un pre-procesamiento de la información previo a indexar:
        ¿Qué recibe el nodo de ingesta? -> JSON
        Qué tiene el JSON dentro?
            Claves y valores ... muchos 
            {
                "Fecha":   "10-10-2020",
                "Hora":    "13:47",
                "SO":      "Ubuntu",
                "CPU":     "50%",
                "HDD":     "236Gbs",
                "HDD_Ptc": "10%",
            }
        Qué es lo que elastic search indexa??? Cada uno de los valores 
        Todos requieren indexación FULLTEXT??? NO, los númericos no. PERFECTO
            Y los lógicos? TRUE, FALSE: NO
            Y las fechas?  NO
            Y que pasa con las posiciones geograficas [coordenadas: latitud, longitud]
        
        Si he recibido de logstash el dato "CPU": "50%" <- Texto
        ¿Como quiero que se indexe este valor? -> Númerico: Pero lo tengo como texto.... Lo tengo que tranformar:
                    "50%" -> 50 o 0.5 <- Hay que hacer una transformación. ¿¿¿Donde la hacemos ???
                        Logstash      <--- Descargo el elastic... Que cada uno se limpie sus cosas.
                        Elasticsearch
                    "10 de Septiembre de 2020" -> Fecha... primero voy a tener que transformarlo a otro formato que Elastic reconozca
                    "10-09-2020"
            
        BUSQUEDAS: 
            Indice fulltext: EQUALS, LIKE
            Indice numerico: EQUALS, RANGE: MAYOR QUE , MENOR QUE
            Indice geoposicionamiento: EQUALS, DISTANCIA
        
        Cada campo tengo que decirle a ELASTIC SEARCH como indexarlo: MAPPINGS
            Los mappings se crean dentro de un INDICE y definen la forma en la que se deben procesar los datos para su indexado
-------------------------------------
Tipos de nodos en Elastic Search: Cluster
    Roles diferentes:
        Datos    <- Guardan los índices
        Maestros <- Controlan el cluster
        Ingesta  <- Recibir datos externos + PREPROCESARLOS
        Consulta <- Los que se exponen a usuarios/apps finales
        Machine Learning...
    En elastic, un nodo puede tener varios roles:
        3 Nodos maestros: Maestro
        2 Nodos maestros + 1 nodo maestro con derecho solo a votación: Maestro
        N Nodo: datos, ingesta, consulta
            Nodos solo de datos o datos+consulta y aparte nodos de ingesta
------------------

Maquina 1
    App -> Log <- filebeat ---------------BEATS----------------->                     
Maquina 2                                                         >  ElasticSearch <<<---- Kibana
    App -> Log <- filebeat ------------------------------------->                    

(es posible montarlo)
Inconvenientes:
    El procesamiento lo hace Elastic <--- UFFFF!!!!
    Sincronización: Requiere que Elastic esté operativo
    Acoplamiento de la solución
Ventajas:
    Más simple
    Las máquinas que quiero monitorizar no las sobrecargo:
        1- Filebeat es un programita muy sencillo, que hace poco y consume poco
        2- Las transformaciones las hace elastic
----

Maquina 1
    App -> Log <- logstash -------------------------------------> 
Maquina 2                                                         >   ElasticSearch <<<---- Kibana
    App -> Log <- logstash -------------------------------------> 
    
(es posible montarlo)

Ventajas:
    Flexibilidad: Elijo quien hace la transformación: Elastic o en las maquinas que monitorizo, o incluso reparto
    Un poco más complejo, pero simple dentro de todo
Inconveniente:
    Sincronización: Requiere que Elastic esté operativo
    La ejecución de logstash es algo más pesada que los beats, algo más de espacio
    Acoplamiento de la solución
----

LAS DOS SON UNA RUINA !!!!







Estas 2 soluciones solucionan algunos de los inconvenientes que teníamos antes

Maquina 1
    App -> Log <- filebeat ----------------------->                     
Maquina 2                                            >      Logstash    >  ElasticSearch <<<---- Kibana
    App -> Log <- filebeat ----------------------->                    
Inconvenientes:
    Sincronización: Requiere que Elastic esté operativo
    Más complejo
Ventajas:
    Nivel de acoplamiento bajo
    Flexibilidad: Elijo quien hace la transformación: Elastic o en las maquinas que monitorizo, o incluso reparto
-----

Maquina 1
    App -> Log <- logstash ----------------------> 
Maquina 2                                           >       Logstash    >   ElasticSearch <<<---- Kibana
    App -> Log <- logstash ----------------------> 

Ventajas:
    Flexibilidad: Elijo quien hace la transformación: Elastic o en las maquinas que monitorizo, o incluso reparto
    Nivel de acoplamiento bajo
Inconveniente:
    Más complejo
    Sincronización: Requiere que Elastic esté operativo
    La ejecución de logstash es algo más pesada que los beats, algo más de espacio


Maquina 1
    App -> Log <- filebeat ----------------------->                     
Maquina 2                                            >      Logstash    >>>>>
    App -> Log <- filebeat ----------------------->                    
                                                                                Logstash  >  ElasticSearch <<<---- Kibana
Maquina 3
    App -> Log <- filebeat ----------------------->                     
Maquina 4                                            >      Logstash    >>>>>
    App -> Log <- filebeat ----------------------->                    

Ventajas:
    Nivel de acoplamiento MUCHO MAS BAJO
-----



Maquina 1
    App -> Log <- filebeat ----------------------->                     
Maquina 2                                            >      Logstash >>> Logstash   >>>>>>  ElasticSearch <<<---- Kibana Sistemas (Errores)
    App -> Log <- filebeat ----------------------->                  >>> Logstash   >>>>>>  ElasticSearch <<<---- Kibana Usuarios (Accesos)
