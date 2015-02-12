#!/bin/bash
#Script para automatizar la descarga de subtítulos, metadatos y conversión de archivos mkv en mp4 para ser vistos en AppleTV
#Desarrollado por Marcel Caraballo
#maqndon @ gmail.com
#https://github.com/maqndon/AutoVideo
#eliminar el .spa en los subtitulos srt
#https://www.filebot.net/forums/viewtopic.php?f=4&t=5#p204 metadata

#Primero que todo debe asignar permisos de ejecución al script
#chmod +x video.sh
#para ejecutar el script debe escribir ./videos.sh en la consola

#Lipiamos la pantalla
clear

#imprimimos en pantalla que el script se está ejecutando
echo -e "Script Automatizado para Convertir archivos MKV en MP4 y Descargar Subtítulos y Metadatos"
sleep 1

#directorio en donde se encuentran almacenados los videos
#este parámetro se le pasa al script ./video.sh /ruta/absoluta/de/la/carpeta/de/videos/
#Este valor es por si ingresa el directorio por consola
DIR=$1
#Descomentar este valor es si se quiere definir directorio de las películas/series directamente en el script
#DIR="/home/marcel/Vídeos/"

#verificamos de qué Sistema Operativo estamos ejecutando el script
OS=`uname`

#Versión de Java para cumplir con las dependencias
JAVAVER=18

#extensión de los archivos que vamos a manipular
#FILES=.mkv
FILES=*.mkv

#extensión a la que vamos a convertir los archivos
NEWEXT=mp4

#para el patrón de búsqueda de mp4
NEWE=*.mp4

#extensión de los subtitulos
SUBEXT=srt

#para el patrón de búsqueda de subtítulos
SUBS=*.srt

#Contador de archivos
COUNT=0

#archivo xml con el cual vamos a sacar los primeros metadatos
NFO=*.nfo

#Idioma por defecto en el sistema
idioma="es"

#API KEY para poder conectarse a tvdb.com
api="E711EDF968A31678"

#nombre del programa con que se esta haciendo el encoding
encoder="autovideo"

#verificamos las dependencias del script
#filebot 32bits http://hivelocity.dl.sourceforge.net/project/filebot/filebot/FileBot_4.5.6/filebot_4.5.6_i386.deb
#filebot 64bits http://hivelocity.dl.sourceforge.net/project/filebot/filebot/FileBot_4.5.6/filebot_4.5.6_amd64.deb 
#ffmpeg
#homebrew Instalación
#ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
#Cask Instalación
#brew install caskroom/cask/brew-cask
#filebot osx
#brew cask install filebot 

function log {
	
	if [ -f video.log ];then
		rm video.log
		LOG=`touch video.log`
	else
		LOG=`touch video.log`	
	fi
	
}

#añado pausa entre los procesos que quiera depurar o mostrar algún mensaje opcional
function pausa {
	
	sleep 0
	
	}

function dependencias {
	
	JAVA_VER=$(java -version 2>&1 | sed 's/.*version "\(.*\)\.\(.*\)\..*"/\1\2/; 1q')
	
	if [ $OS = Linux ];then
		if [ ! -f /usr/bin/ffmpeg ];then
			echo -e "No está instalado ffmpeg, pruebe instalándolo con apt-get install -y ffmpeg"|tee video.log
			echo -e "Puede ver el archivo video.log para mas información"
			exit
		fi
		if [ ! -f /usr/bin/filebot ];then
			echo -e "No está instalado filebot"|tee -a video.log
			echo -e "Puede ver el archivo video.log para mas información"
			exit
		fi
		if [ $JAVA_VER -lt $JAVAVER ]; then
			echo -e "Debe instalar la Versión 8 de Java"|tee -a video.log
			echo -e "Puede ver el archivo video.log para mas información"
			exit
		fi
	clear
	echo -e "Todas las dependencias instaladas"
	pausa
	else
		if [ ! -f /usr/local/bin/ffmpeg ];then
			echo -e "Debe instalar ffmpeg para OSX"|tee video.log
			echo -e "Puede ver el archivo video.log para mas información"
			exit
		fi
		if [ ! -f /usr/local/bin/brew ];then
			echo -e "Debe instalar homebrew, pruebe instalándola desde el Terminal con:"|tee -a video.log
			echo -e "ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)""|tee -a video.log
			echo -e "Puede ver el archivo video.log para mas información"			
			exit
		fi
		if [ ! -f /usr/local/bin/brew-cask ];then
			echo -e "Debe instalar cask"|tee -a video.log
			echo -e "Puede ver el archivo video.log para mas información"
			exit
		fi
		if [ ! -f /usr/local/bin/filebot ];then
			echo -e "Debe instalar filebot"|tee -a video.log
			echo -e "Puede ver el archivo video.log para mas información"
			exit
		fi
		if [ $JAVA_VER -lt $JAVAVER ]; then
			echo -e "Debe instalar la Versión 8 de Java"|tee -a video.log
			echo -e "Puede ver el archivo video.log para mas información"
			exit
		fi
	clear
	echo -e "Todas las dependencias instaladas"|tee -a video.log
	pausa	
	fi
}

function comprobar_directorio {

	if [ "$DIR" ]; then
		if [ ! -d "$DIR" ]; then
			echo -e "El directorio $1 no existe o la ruta especificada no es válida"|tee -a video.log
			exit
		fi
	else
		echo -e "Debe ingresar el directorio en donde estan almacenados los videos"|tee -a video.log
		echo -e "./autovideo.sh /ruta/absoluta/de/la/carpeta/de/videos/"|tee -a video.log
		exit
	fi

}

#descargar los subtitulos de la película/serie
function subtitulos {
	
	#for i in $( ls -R $DIR |grep $FILES ); do
	#Revisar cualquier error que pueda dar que la variable $FILES no este entre '': '$FILES'
	find "$DIR" -type f -name "$FILES" -print0 | while IFS= read -r -d '' i; do
		clear
		let COUNT=COUNT+1
		#mostramos sólo el nombre del archivo y no del Directorio en donde se encuentran
		SRT=$(basename "$i")
		echo -e "$COUNT) Descargando Subtítulos de "$SRT""|tee -a video.log
		pausa
		#si es necesario se coloca -r
		#echo -e "filebot -get-missing-subtitles --lang es -non-strict --output srt --encoding UTF-8 "$i""
		filebot -get-missing-subtitles --lang es -non-strict --output srt --encoding UTF-8 "$i"
		pausa
		#si ocurre algún error con filebot sale del script automáticamente
		if [ $? == 1 ];then
			clear
			echo -e "Ha ocurrido un error con filebot"|tee -a video.log
			exit
		else
            clear
            echo "     Subtítulos de "$SRT" Descargados Con Éxito"|tee -a video.log
            pausa
            clear
		fi
	done
	
	echo -e "" |tee -a video.log
	echo -e "Todos los Subtítulos han sido Descargados Correctamente"|tee -a video.log
	echo -e "" |tee -a video.log
	
}

function renombrar_subs {

	find "$DIR" -type f -name "$SUBS" -print0 | while IFS= read -r -d '' i; do
		clear
		let COUNT=COUNT+1
		#mostramos sólo el nombre del archivo y no del Directorio en donde se encuentran
		SRT=$(basename "$i")
		echo -e "$COUNT) Renombrando Subtítulos de "$SRT""|tee -a video.log
		pausa
		#renombro los subtítulos
		#echo -e "mv "$i" "${i/.spa./.}""
		mv "$i" "${i/.spa./.}"
		pausa
		#si ocurre algún error se sale del script automáticamente
		if [ $? == 1 ];then
			clear
			echo -e "Ha ocurrido un error renombrando el subtítulo"|tee -a video.log
			exit
		else
            clear
            echo "     Subtítulos Renombrados a "${SRT/.spa./.}" Con Éxito"|tee -a video.log
            pausa
            clear
		fi
	done
	
	echo -e "" |tee -a video.log
	echo -e "Todos los Subtítulos han sido Renombrados Correctamente"|tee -a video.log
	echo -e "" |tee -a video.log	
	
}
	
function mkvtomp4 {

	#for i in $( ls -R $DIR |grep $FILES ); do
	#Revisar cualquier error que pueda dar que la variable $FILES no este entre '': '$FILES'
	find "$DIR" -type f -name "$FILES" -print0 | while IFS= read -r -d '' i; do
		clear
		let COUNT=COUNT+1
		echo -e "$COUNT) Convirtiendo ${i%.#*} MKV en MP4 y añadiendo los Subtítulos Descargados"|tee -a video.log
		#echo -e "ffmpeg -i "${i%.#*}" -i "${i%.*}.$SUBEXT" -c:v copy -c:a copy -c:s mov_text "${i%.*}.$NEWEXT" < /dev/null"
		ffmpeg -i "${i%.#*}" -i "${i%.*}.$SUBEXT" -c:v copy -c:a copy -c:s mov_text "${i%.*}.$NEWEXT" < /dev/null
		pausa
		#si ocurre algún error con ffmpeg sale del script automáticamente
		if [ $? == 1 ];then
			clear
			echo -e "Ha ocurrido un error con ffmpeg"|tee -a video.log
			exit
		else
            #echo $i
            clear
            MP4=${i%.#*}
            echo -e "     $(basename "$MP4") convertido con éxito"|tee -a video.log
            pausa
            clear
		fi
	done
	
	echo -e "Todos los archivos han sido convertidos correctamente"|tee -a video.log
	
}

function renombrar_mkv {

find "$DIR" -type f -name "$FILES" -print0 | while IFS= read -r -d '' i; do
    clear
    let COUNT=COUNT+1
    echo -e "$COUNT) Renombrando ${i%.#*} al Estándar de tvdb.com"|tee -a video.log
    filebot -rename -non-strict "${i%.#*}"
    pausa
    #si ocurre algún error con ffmpeg sale del script automáticamente
    if [ $? == 1 ];then
        clear
        echo -e "Ha ocurrido un error al tratar de renombrar el archivo ${i%.#*}"|tee -a video.log
        exit
    else
        #echo $i
        clear
        MP4=${i%.#*}
        echo -e "     $(basename "$MP4") convertido con éxito"|tee -a video.log
        pausa
        clear
    fi
done

echo -e "Todos los archivos han sido convertidos correctamente"|tee -a video.log

}

function serienfo {

find "$DIR" -type f -name "$FILES" -print0 | while IFS= read -r -d '' i; do
    ARCHIVO=$(basename "$i")
    #echo "$ARCHIVO"
    #Número de temporada y de episodio
    NUM=`echo $ARCHIVO |egrep -o '.[[0-9][xX][0-9][0-9]]*'|sed -e 's/ //g'`
    #Título de la serie
    TITULO=`echo $ARCHIVO |sed -e 's/ -.*//g'`
    #Nombre del archivo .nfo
    TITULONFO=`echo $TITULO |sed -e 's/ /./g'`
    #Variable (nombre de la serie) para tvdb.com
    TITULOURL=`echo $TITULO |sed -e 's/ -//g' -e 's/ /%20/g'`
    #Nombre del capítulo
    CAPITULO=${ARCHIVO/*[0-9][xX][0-9][0-9]/}
    CAPITULO=`echo $CAPITULO |sed -e 's/- //g' -e 's/.mp4//g'`
    #echo $CAPITULO
    #echo $TITULO
    #echo $TITULONFO
    #echo $TITULOURL
    #echo $NUM
    curl -o "$DIR$TITULONFO.$NUM.nfo" "http://thetvdb.com/api/GetSeries.php?seriesname="$TITULOURL"&language="$idioma""
done
}

function archivo() {

find "$DIR" -type f -name "$1" -print0 | while IFS= read -r -d '' i; do
    ARCHIVO="$i"
    echo "$ARCHIVO"
done

}

function metadata {

find "$DIR" -type f -name "$NFO" -print0 | while IFS= read -r -d '' i; do
    #ID de la serie en tvdb.com
    serieid=`xpath "$i" "(//seriesid)[1]/text()" 2> /dev/null`
    #serieid=`echo $serieidXP |sed -e 's/^<.*>\([^<].*\)<.*>$/\1/'`

    #Nombre de la serie
    seriename=`xpath "$i" "(//SeriesName)[1]/text()" 2> /dev/null`

    #Número de temporada y de episodio
    NUMTEM=`echo $i |sed -e 's/.*\.\([^x].*\)\..*/\1/' -e 's/x.*//' -e 's/0//'`
    NUMEPI=`echo $i |sed -e 's/.*\(x..\).*/\1/' -e 's/x//' -e 's/0//'`

    #Asignamos título al .zip
    TITULOZIP=`echo $(basename "$i")|sed -e 's/.nfo/.zip/' 2> /dev/null`

    xml="$DIR/${TITULOZIP%.*}/$idioma.xml"

    #Asignamos al poster .jpg
    POSTERJPG=`echo $(basename "$i")|sed -e 's/.nfo/.jpg/' 2> /dev/null`

    #bajamos el resto de los metadatos
    curl -o "$DIR$TITULOZIP" "http://thetvdb.com/api/"$api"/series/"$serieid"/all/"$idioma".zip"

    unzip "$DIR$TITULOZIP" -d "$DIR/${TITULOZIP%.*}"

    poster=`xpath "$xml" "//poster/text()" 2> /dev/null`

    portada="$DIR$POSTERJPG"

    curl -o "$portada" "http://thetvdb.com/banners/$poster"

#   creamos un archivo con los metadatos

    if [ -f "${i%nfo}txt" ]; then
        rm "${i%nfo}txt"
        touch "${i%nfo}txt"
    else
        touch "${i%nfo}txt"
    fi

    #Nombre de la serie
    nombreSerie=`xpath "$xml" "//SeriesName/text()" 2> /dev/null`
    echo "serie: $nombreSerie" | tee "${i%nfo}txt"

    #Actores de la serie
    actores=`xpath "$xml" "//Actors/text()" 2> /dev/null`
    echo "actores: $actores" | tee -a "${i%nfo}txt"
    #actores=`echo $actoresXP |sed -e 's/^<.*>\([^<].*\)<.*>$/\1/'`

    #Género de la serie
    genero=`xpath "$xml" "//Genre/text()" 2> /dev/null`
    echo "genero: $genero" | tee -a "${i%nfo}txt"
    #genero=`echo $generoXP |sed -e 's/^<.*>\([^<].*\)<.*>$/\1/'`

    #Sinopsis de la serie
    #Esta sinopsis aplica solamente si se trata de la primera temporada
    sinopsis=`xpath "$xml" "//Series/Overview/text()" 2>/dev/null`
    echo "sinopsis: $sinopsis" | tee -a "${i%nfo}txt"
    #sinopsis=`echo $sinopsisXP |sed -e 's/^<.*>\([^<].*\)<.*>$/\1/'`

    #Canal en donde transmiten la serie
    network=`xpath "$xml" "//Series/Network/text()" 2>/dev/null`
    echo "network: $network" | tee -a "${i%nfo}txt"

    #Tipo de contenido multimedia
    mediakind="TV Show"
    echo "contenido: $mediakind" | tee -a "${i%nfo}txt"

    contentrating="$(xpath "$xml" '//Series/ContentRating/text()' 2> /dev/null)"
    echo "rating: $contentrating" | tee -a "${i%nfo}txt"

    #boolean si el contenido es HD
    hdvideo=1
    echo "hdvideo: $hdvideo" | tee -a "${i%nfo}txt"

    echo "poster: $portada" | tee -a "${i%nfo}txt"

    let episodios="$(xpath "$xml" 'count(//Episode)' 2> /dev/null)"

    for j in $(seq 1 "$episodios"); do

        tempo="$(xpath "$xml" '//Episode['$j']/SeasonNumber/text()' 2> /dev/null)"
        episo="$(xpath "$xml" '//Episode['$j']/EpisodeNumber/text()' 2> /dev/null)"

        if [ $tempo = $NUMTEM ]; then

            if [ $episo = $NUMEPI ]; then

                temporada="$(xpath "$xml" '//Episode['$j']/SeasonNumber/text()' 2> /dev/null)"
                echo "temporada: $temporada" | tee -a "${i%nfo}txt"
                episodio="$(xpath "$xml" '//Episode['$j']/EpisodeNumber/text()' 2> /dev/null)"
                echo "episodio: $episodio" | tee -a "${i%nfo}txt"
                nombre="$(xpath "$xml" '//Episode['$j']/EpisodeName/text()' 2> /dev/null)"
                echo "nombre: $nombre" | tee -a "${i%nfo}txt"
                overview="$(xpath "$xml" '//Episode['$j']/Overview/text()' 2> /dev/null)"
                echo "overview: $overview" | tee -a "${i%nfo}txt"
                director="$(xpath "$xml" '//Episode['$j']/Director/text()' 2> /dev/null)"
                echo "director: $director" | tee -a "${i%nfo}txt"
                fecha="$(xpath "$xml" '//Episode['$j']/FirstAired/text()' 2> /dev/null)"
                echo "fecha: $fecha" | tee -a "${i%nfo}txt"
                episodeid="$(xpath "$xml" '//Episode['$j']/id/text()' 2> /dev/null)"
                echo "episodioId: $episodeid" | tee -a "${i%nfo}txt"

            fi

        fi

    done

done

}

function conversion {

find "$DIR" -type f -name "$FILES" -print0 | while IFS= read -r -d '' i; do
    #ARCHIVO=$(archivo "$FILES")

    mp4final=$(basename "$i")
    mp4final=`echo $mp4final | sed -e 's/ //g'`
    mp4final="${mp4final%.*}.$NEWEXT"
    mp4final="$DIR$mp4final"

    metaNombre=`echo ${i%mkv}txt |sed -e 's/ -.*//g'`
    metaEpi=`echo ${i%mkv}txt |sed -e 's/.*\(..x..\).*/\1/' -e 's/ //'`
    meta="$metaNombre.$metaEpi.txt"

    nombreSerie=`cat "$meta" |grep serie: |sed -e 's/serie: //'`
    actores=`cat "$meta" |grep actores: |sed -e 's/actores: //'`
    genero=`cat "$meta" |grep genero: |sed -e 's/genero: //'`
    sinopsis=`cat "$meta" |grep sinopsis: |sed -e 's/sinopsis: //'`
    network=`cat "$meta" |grep network: |sed -e 's/network: //'`
    mediakind=`cat "$meta" |grep contenido: |sed -e 's/contenido: //'`
    contentrating=`cat "$meta" |grep rating: |sed -e 's/rating: //'`
    hdvideo=`cat "$meta" |grep hdvideo: |sed -e 's/hdvideo: //'`
    temporada=`cat "$meta" |grep temporada: |sed -e 's/temporada: //'`
    episodio=`cat "$meta" |grep episodio: |sed -e 's/episodio: //'`
    nombre=`cat "$meta" |grep nombre: |sed -e 's/nombre: //'`
    overview=`cat "$meta" |grep overview: |sed -e 's/overview: //'`
    director=`cat "$meta" |grep director: |sed -e 's/director: //'`
    fecha=`cat "$meta" |grep fecha: |sed -e 's/fecha: //'`
    episode_id=`cat "$meta" |grep episodioId: |sed -e 's/episodioId: //'`
    portada=`cat "$meta" |grep poster: |sed -e 's/poster: //'`

    #-metadata:s:s:[stream number] language=[language code]
    # -c:a aac -ac 2 -strict -2 #cambio el audio a AAC Stereo
    ffmpeg -i "${i%.#*}" -i "${i%.*}.$SUBEXT" -map 0:0 -map 0:1 -map 1:0 -c:v copy -c:a aac -ac 2 -strict -2 -c:s mov_text \
        -metadata:s:s:0 language="spa" \
        -metadata:s:s:0 title="Spanish" \
        -metadata:s:a:0 language="eng" \
        -metadata:s:a:0 title="English" \
        -metadata:s:v:0 language="eng" \
        -metadata:s:v:0 title="English" \
        "${i%.*}.$NEWEXT" < /dev/null

SublerCLI -source "${i%.*}.$NEWEXT" -dest "$mp4final" -metadata {"TV Show":"$nombreSerie"}{"Artwork":"$portada"}{"HD Video":"$hdvideo"}{"Media Kind":"$mediakind"}{"TV Episode #":"$episodio"}{"TV Season":"$temporada"}{"Genre":"$genero"}{"Name":"$nombre"}{"Artist":"$nombreSerie"}{"Album Artist":"$nombreSerie"}{"Album":"$nombreSerie"}{"Release Date":"$fecha"}{"TV Network":"$network"}{"TV Episode ID":"$episode_id"}
done

}

#log #logs del script
#comprobar_directorio #verificar si el directorio es especificado al inicio o si este existe
#dependencias #comprobar que todas las dependencias esten instaladas
#mkvtomp4 #convertir los archivos mkv a mp4 y adjuntar los subtitulos anteriormente especificados

renombrar_mkv
subtitulos #descargar los subtitulos de las peliculas/series que esten almacenad@s en el directorio especificado
renombrar_subs #renombro los subtítulos que tienen .spa.
serienfo #busco la información básica de la serie
metadata
conversion