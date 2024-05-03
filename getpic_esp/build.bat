"../../../tools/mingw/make.exe" -f makefile %1
if "%makeall%"=="" "../../../tools/dmimg.exe" ../../../us/sd_nedo.vhd put getpic.com /bin/getpic.com
rem if "%makeall%"=="" ..\..\..\us\emul.exe
rd /Q /S obj