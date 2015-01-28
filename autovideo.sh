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

#extensión de los subtitulos
SUBEXT=srt

#para el patrón de búsqueda de subtítulos
SUBS=*.srt

#Contador de archivos
COUNT=0

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

	if [ $DIR ]; then
		if [ ! -d $DIR ]; then	
			echo -e "El directorio $1 no existe o la ruta especificada no es válida"|tee -a video.log
			exit
		fi
	else
		echo -e "Debe ingresar el directorio en donde estan almacenados los videos"|tee -a video.log
		echo -e "./video.sh /ruta/absoluta/de/la/carpeta/de/videos/"|tee -a video.log
		exit
	fi

}

#descargar los subtitulos de la película/serie
function subtitulos {
	
	#for i in $( ls -R $DIR |grep $FILES ); do
	#Revisar cualquier error que pueda dar que la variable $FILES no este entre '': '$FILES'
	find $DIR -type f -name $FILES -print0 | while IFS= read -r -d '' i; do
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

	find $DIR -type f -name $SUBS -print0 | while IFS= read -r -d '' i; do
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
	find $DIR -type f -name $FILES -print0 | while IFS= read -r -d '' i; do
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

log #logs del script
comprobar_directorio #verificar si el directorio es especificado al inicio o si este existe
dependencias #comprobar que todas las dependencias esten instaladas
subtitulos #descargar los subtitulos de las peliculas/series que esten almacenad@s en el directorio especificado
renombrar_subs #renombro los subtítulos que tienen .spa.
mkvtomp4 #convertir los archivos mkv a mp4 y adjuntar los subtitulos anteriormente especificados
