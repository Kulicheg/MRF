@echo off
set makeall=1
call version.bat
echo Build: %buildnew%
call build.bat
call build-TR-AU-64.bat
call build-TR-AY-64.bat
call build-TR-AY-80.bat
call build-TR-EU-64.bat
call build-TR-ZW-64.bat
call build-TR-UN-64.bat
call build-MX-BC-80.bat
call build-TR-GZ-80.bat
call build-TR-AY-64-SMUC.bat
call build-TR-A5-64.bat
