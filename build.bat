@echo off
"../../tools\mingw\make.exe" nedoosevo
ren  moon.com mrfue.com
copy /Y mrfue.com ..\..\release\bin\kapps\mrfue.com
"../../tools\mingw\make.exe" nedoosatm
ren  moon.com mrfua.com
copy /Y mrfua.com ..\..\release\bin\kapps\mrfua.com
"../../tools\mingw\make.exe" nedoos
ren  moon.com mrf.com
copy /Y mrf.com ..\..\release\bin\mrf.com

copy /Y data\index.gph ..\..\release\bin\browser\index.gph
copy /Y data\logo.scr ..\..\release\bin\browser\logo.scr
copy /Y data\example.pt3 ..\..\release\bin\browser\example.pt3
copy /Y data\auth.pwd ..\..\release\bin\browser\auth.pwd

md ..\..\release\downloads

"../../tools/dmimg.exe" ../../us/sd_nedo.vhd put mrf.com /bin/mrf.com
"../../tools/dmimg.exe" ../../us/sd_nedo.vhd put mrfua.com /bin/kapps/mrfua.com
"../../tools/dmimg.exe" ../../us/sd_nedo.vhd put mrfue.com /bin/kapps/mrfue.com
"../../tools/dmimg.exe" ../../us/sd_nedo.vhd put data/index.gph /bin/browser/index.gph
"../../tools/dmimg.exe" ../../us/sd_nedo.vhd put data/logo.scr /bin/browser/logo.scr
"../../tools/dmimg.exe" ../../us/sd_nedo.vhd put data/example.pt3 /bin/browser/example.pt3
"../../tools/dmimg.exe" ../../us/sd_nedo.vhd put data/auth.pwd /bin/browser/auth.pwd
"../../tools/dmimg.exe" ../../us/sd_nedo.vhd put data/example.scr /bin/browser/example.scr

del /Q *.lst
del /Q mrf.com
del /Q mrfua.com
del /Q mrfue.com

if "%makeall%"=="" ..\..\us\emul.exe