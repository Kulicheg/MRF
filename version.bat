@echo off
For /F "Delims=" %%I In (version.txt) Do Set /a buildold=%%~I
set /a buildnew=%buildold%+1
echo %buildnew% > version.txt