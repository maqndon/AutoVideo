# AutoVideo
Script para automatizar la descarga de subtítulos, metadatos y conversión de archivos mkv en mp4 para ser vistos en AppleTV

## Requerimientos de Sistema

GNU/Linux

1. ffmpeg
2. Java 8
3. Filebot
4. SublerCli

Mac OSX

1. ffmpeg
2. Java 8
3. Homebrew
4. Homebrew-Cask
5. Filebot
6. SublerCli

## Modo de Empleo

Desde un terminal

darle permisos de ejecución

**chmod +x autovideo.sh**

para ejecutar el script

**./autovideo.sh /directorio/en/donde/estan/los/videos/**

Ejemplo:

**./autovideo.sh /Users/arnoldo/Movies/**

## Debug

Puede leer el archivo video.log que se crea en el directorio en donde tenga el script para ver algún error que pudiera estar ocurriendo o simplemente ver si todos los archivos fueron convertidos correctamente. 
